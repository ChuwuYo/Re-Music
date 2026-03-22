import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:path/path.dart' as p;

import '../constants.dart';
import '../models/audio_probe_info.dart';
import '../models/transcode_decision.dart';
import '../models/transcode_item.dart';
import '../models/transcode_request.dart';
import '../models/transcode_result.dart';
import 'file_service.dart';
import 'probe_service.dart';
import 'transcode_command_builder.dart';

abstract class TranscodeProcessHandle {
  Stream<List<int>> get stdout;
  Stream<List<int>> get stderr;
  Future<int> get exitCode;
}

class IoTranscodeProcessHandle implements TranscodeProcessHandle {
  final Process _process;

  IoTranscodeProcessHandle(this._process);

  @override
  Stream<List<int>> get stdout => _process.stdout;

  @override
  Stream<List<int>> get stderr => _process.stderr;

  @override
  Future<int> get exitCode => _process.exitCode;
}

typedef TranscodeProcessStarter =
    Future<TranscodeProcessHandle> Function(
      String executable,
      List<String> arguments,
    );

class TranscodeTaskQueue {
  final String ffmpegExecutablePath;
  final ProbeService probeService;
  final TranscodeCommandBuilder commandBuilder;
  final TranscodeProcessStarter _processStarter;
  final RegExp _progressPattern = RegExp(r'time=(\d+):(\d+):(\d+(?:\.\d+)?)');

  TranscodeTaskQueue({
    required this.ffmpegExecutablePath,
    required this.probeService,
    required this.commandBuilder,
    TranscodeProcessStarter? processStarter,
  }) : _processStarter = processStarter ?? _defaultProcessStarter;

  Future<List<TranscodeResult>> run({
    required List<TranscodeItem> items,
    required TranscodeRequest request,
    required void Function(TranscodeItem item) onItemUpdated,
  }) async {
    final runnable = items.where((item) => item.canRun).toList(growable: false);
    final results = <TranscodeResult>[];
    if (runnable.isEmpty) return results;

    final concurrency = request.concurrency
        .clamp(
          AppConstants.transcodeConcurrencyMin,
          AppConstants.transcodeConcurrencyMax,
        )
        .toInt();
    final reservedOutputPaths = <String>{};
    var nextIndex = 0;

    Future<void> worker() async {
      while (true) {
        if (nextIndex >= runnable.length) return;
        final item = runnable[nextIndex++];
        final result = await _runSingle(
          item: item,
          request: request,
          reservedOutputPaths: reservedOutputPaths,
          onItemUpdated: onItemUpdated,
        );
        results.add(result);
      }
    }

    await Future.wait(
      List.generate(
        concurrency > runnable.length ? runnable.length : concurrency,
        (_) => worker(),
      ),
    );
    return results;
  }

  Future<TranscodeResult> _runSingle({
    required TranscodeItem item,
    required TranscodeRequest request,
    required Set<String> reservedOutputPaths,
    required void Function(TranscodeItem item) onItemUpdated,
  }) async {
    final probeInfo = item.probeInfo;
    final decision = item.decision;
    if (probeInfo == null || decision == null) {
      item.status = TranscodeItemStatus.error;
      item.message = 'Transcode task is missing probe info or decision.';
      onItemUpdated(item);
      return TranscodeResult(
        inputPath: item.inputPath,
        status: item.status,
        errorMessage: item.message,
      );
    }

    TranscodeCommandPlan? plan;
    try {
      plan = commandBuilder.build(
        probeInfo: probeInfo,
        decision: decision,
        request: request,
        reservedOutputPaths: reservedOutputPaths,
      );
      item.plannedOutputPath = plan.finalOutputPath;
      item.tempOutputPath = plan.commandOutputPath;
      item.status = TranscodeItemStatus.queued;
      item.progress = 0.0;
      item.message = null;
      onItemUpdated(item);

      final process = await _processStarter(
        ffmpegExecutablePath,
        plan.arguments,
      );
      item.status = TranscodeItemStatus.running;
      onItemUpdated(item);

      final stdoutDone = process.stdout.drain<void>();
      final stderrDone = Completer<void>();
      final stderrBuffer = StringBuffer();

      final stderrSubscription = process.stderr.listen(
        (chunk) {
          final text = utf8.decode(chunk, allowMalformed: true);
          stderrBuffer.write(text);
          _updateProgressFromChunk(item, text, probeInfo.durationSeconds);
          onItemUpdated(item);
        },
        onDone: () => stderrDone.complete(),
        onError: stderrDone.completeError,
      );

      final exitCode = await process.exitCode;
      await stdoutDone;
      await stderrDone.future;
      await stderrSubscription.cancel();

      if (exitCode != 0) {
        await _cleanupOutput(
          plan.commandOutputPath,
          keepIfMatches: item.inputPath,
        );
        _unreservePaths(plan, reservedOutputPaths);
        item.status = TranscodeItemStatus.error;
        item.message = _trimMessage(stderrBuffer.toString());
        _appendTranscodeErrorLog(
          item: item,
          stage: 'ffmpeg',
          message: item.message ?? 'ffmpeg exited with an error',
          rawOutput: stderrBuffer.toString(),
        );
        onItemUpdated(item);
        return TranscodeResult(
          inputPath: item.inputPath,
          status: item.status,
          errorMessage: item.message,
        );
      }

      try {
        final outputProbe = await probeService.probeFile(
          plan.commandOutputPath,
        );
        final validationError = _validateOutput(outputProbe, decision);
        if (validationError != null) {
          await _cleanupOutput(
            plan.commandOutputPath,
            keepIfMatches: item.inputPath,
          );
          _unreservePaths(plan, reservedOutputPaths);
          item.status = TranscodeItemStatus.error;
          item.message = validationError;
          _appendTranscodeErrorLog(
            item: item,
            stage: 'validate',
            message: validationError,
            rawOutput:
                'output=${plan.commandOutputPath}\nexpected=${decision.outputFormat}/${decision.targetSampleRate}/${decision.targetBitDepth}/${decision.targetBitRateKbps}',
          );
          onItemUpdated(item);
          return TranscodeResult(
            inputPath: item.inputPath,
            status: item.status,
            errorMessage: validationError,
          );
        }

        if (request.outputMode == TranscodeOutputMode.replaceOriginal) {
          await FileService.replaceFileAtomically(
            plan.commandOutputPath,
            plan.finalOutputPath,
          );
          await _deleteSupersededInput(
            inputPath: item.inputPath,
            outputPath: plan.finalOutputPath,
          );
        }

        item.actualOutputPath = plan.finalOutputPath;
        item.progress = 1.0;
        item.status = TranscodeItemStatus.success;
        item.message = null;
        onItemUpdated(item);
        return TranscodeResult(
          inputPath: item.inputPath,
          outputPath: item.actualOutputPath,
          status: item.status,
          outputProbeInfo: outputProbe,
        );
      } catch (error) {
        await _cleanupOutput(
          plan.commandOutputPath,
          keepIfMatches: item.inputPath,
        );
        _unreservePaths(plan, reservedOutputPaths);
        item.status = TranscodeItemStatus.error;
        item.message = '$error';
        _appendTranscodeErrorLog(
          item: item,
          stage: 'exception',
          message: item.message ?? 'Unexpected transcode exception',
          rawOutput: 'output=${plan.commandOutputPath}',
        );
        onItemUpdated(item);
        return TranscodeResult(
          inputPath: item.inputPath,
          status: item.status,
          errorMessage: item.message,
        );
      }
    } catch (error) {
      if (plan != null) {
        await _cleanupOutput(
          plan.commandOutputPath,
          keepIfMatches: item.inputPath,
        );
        _unreservePaths(plan, reservedOutputPaths);
      }
      item.status = TranscodeItemStatus.error;
      item.message = '$error';
      _appendTranscodeErrorLog(
        item: item,
        stage: 'prepare',
        message: item.message ?? 'Failed before ffmpeg execution',
        rawOutput: 'ffmpeg=$ffmpegExecutablePath\ninput=${item.inputPath}',
      );
      onItemUpdated(item);
      return TranscodeResult(
        inputPath: item.inputPath,
        status: item.status,
        errorMessage: item.message,
      );
    }
  }

  void _updateProgressFromChunk(
    TranscodeItem item,
    String chunk,
    double? durationSeconds,
  ) {
    if (durationSeconds == null || durationSeconds <= 0) {
      item.progress = null;
      return;
    }

    for (final match in _progressPattern.allMatches(chunk)) {
      final hours = int.parse(match.group(1)!);
      final minutes = int.parse(match.group(2)!);
      final seconds = double.parse(match.group(3)!);
      final totalSeconds = hours * 3600 + minutes * 60 + seconds;
      item.progress = (totalSeconds / durationSeconds)
          .clamp(0.0, 0.99)
          .toDouble();
    }
  }

  void _unreservePaths(
    TranscodeCommandPlan plan,
    Set<String> reservedOutputPaths,
  ) {
    reservedOutputPaths.remove(
      TranscodeCommandBuilder.normalizePath(plan.commandOutputPath),
    );
    reservedOutputPaths.remove(
      TranscodeCommandBuilder.normalizePath(plan.finalOutputPath),
    );
  }

  String? _validateOutput(
    AudioProbeInfo outputProbe,
    TranscodeDecision decision,
  ) {
    if (outputProbe.outputFormatEquivalent != decision.outputFormat) {
      return 'Output format does not match the requested format.';
    }
    if (decision.targetSampleRate != null &&
        outputProbe.sampleRate != decision.targetSampleRate) {
      return 'Output sample rate does not match the requested target.';
    }
    if (decision.outputFormat == TranscodeOutputFormat.mp3) {
      final bitRate = outputProbe.bitRate != null
          ? (outputProbe.bitRate! / 1000).round()
          : null;
      final targetBitRate = decision.targetBitRateKbps;
      if (bitRate != null && targetBitRate != null) {
        // ffprobe MP3 bitrate can vary slightly depending on frame stats.
        if ((bitRate - targetBitRate).abs() > 16) {
          return 'Output bitrate does not match the requested target.';
        }
      }
      return null;
    }
    if (decision.targetBitDepth != null) {
      final outputBitDepth = outputProbe.bitDepth;
      // ffprobe may omit bits_per_* for some containers and report only s32/s32p.
      // In that case the effective depth is ambiguous; do not fail hard.
      if (outputBitDepth != null && outputBitDepth != decision.targetBitDepth) {
        return 'Output bit depth does not match the requested target.';
      }
    }
    return null;
  }

  Future<void> _deleteSupersededInput({
    required String inputPath,
    required String outputPath,
  }) async {
    if (inputPath.toLowerCase() == outputPath.toLowerCase()) {
      return;
    }
    final inputFile = File(inputPath);
    if (await inputFile.exists()) {
      await inputFile.delete();
    }
  }

  Future<void> _cleanupOutput(
    String outputPath, {
    required String keepIfMatches,
  }) async {
    if (outputPath.toLowerCase() == keepIfMatches.toLowerCase()) return;
    final file = File(outputPath);
    if (await file.exists()) {
      await file.delete();
    }
  }

  String _trimMessage(String raw) {
    final trimmed = raw.trim();
    if (trimmed.isEmpty) {
      return 'ffmpeg exited with an error.';
    }
    final lines = trimmed.split(RegExp(r'\r?\n'));
    return lines.reversed.firstWhere(
      (line) => line.trim().isNotEmpty,
      orElse: () => trimmed,
    );
  }

  static Future<TranscodeProcessHandle> _defaultProcessStarter(
    String executable,
    List<String> arguments,
  ) async {
    final process = await Process.start(executable, arguments);
    return IoTranscodeProcessHandle(process);
  }

  static void resetTranscodeErrorLog() {
    try {
      final logFile = File(
        p.join(
          Directory.current.path,
          AppConstants.logsDirectoryName,
          AppConstants.transcodeErrorLogFileName,
        ),
      );
      if (logFile.existsSync()) {
        logFile.writeAsStringSync('');
      }
    } catch (_) {
      // Best effort only.
    }
  }

  static void _appendTranscodeErrorLog({
    required TranscodeItem item,
    required String stage,
    required String message,
    required String rawOutput,
  }) {
    try {
      final logDir = Directory(
        p.join(Directory.current.path, AppConstants.logsDirectoryName),
      );
      if (!logDir.existsSync()) {
        logDir.createSync(recursive: true);
      }

      final logFile = File(
        p.join(logDir.path, AppConstants.transcodeErrorLogFileName),
      );
      final timestamp = DateTime.now().toIso8601String();
      final preview = rawOutput.length > 6000
          ? '${rawOutput.substring(0, 6000)}\n...[truncated]'
          : rawOutput;
      final content = StringBuffer()
        ..writeln('[$timestamp] stage=$stage')
        ..writeln('input=${item.inputPath}')
        ..writeln('planned=${item.plannedOutputPath ?? ''}')
        ..writeln('temp=${item.tempOutputPath ?? ''}')
        ..writeln('message=$message')
        ..writeln('output=')
        ..writeln(preview)
        ..writeln('---');
      logFile.writeAsStringSync(content.toString(), mode: FileMode.append);
    } catch (_) {
      // Keep queue execution resilient.
    }
  }
}
