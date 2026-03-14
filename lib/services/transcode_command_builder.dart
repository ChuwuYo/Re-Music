import 'dart:io';

import 'package:path/path.dart' as p;

import '../constants.dart';
import '../models/audio_probe_info.dart';
import '../models/transcode_decision.dart';
import '../models/transcode_request.dart';

class TranscodeCommandPlan {
  final List<String> arguments;
  final String commandOutputPath;
  final String finalOutputPath;

  const TranscodeCommandPlan({
    required this.arguments,
    required this.commandOutputPath,
    required this.finalOutputPath,
  });
}

class TranscodeCommandBuilder {
  const TranscodeCommandBuilder();

  TranscodeCommandPlan build({
    required AudioProbeInfo probeInfo,
    required TranscodeDecision decision,
    required TranscodeRequest request,
  }) {
    final outputPaths = _resolveOutputPaths(
      inputPath: probeInfo.path,
      decision: decision,
      request: request,
    );
    final arguments = <String>[
      '-y',
      '-hide_banner',
      '-nostdin',
      '-i',
      probeInfo.path,
      '-map',
      '0:a:0',
      '-map_metadata',
      '0',
    ];

    if (decision.outputFormat != TranscodeOutputFormat.wav) {
      arguments.addAll(['-map', '0:v?', '-c:v', 'copy']);
    }

    final audioFilter = _buildAudioFilter(decision: decision, request: request);
    if (audioFilter != null) {
      arguments.addAll(['-af', audioFilter]);
    }

    if (decision.targetSampleRate != null) {
      arguments.addAll(['-ar', '${decision.targetSampleRate}']);
    }

    if (decision.outputFormat == TranscodeOutputFormat.flac) {
      arguments.addAll(['-c:a', 'flac']);
      if (decision.targetBitDepth != null) {
        arguments.addAll([
          '-sample_fmt',
          decision.targetBitDepth! <= 16 ? 's16' : 's32',
        ]);
      }
    } else if (decision.outputFormat == TranscodeOutputFormat.wav) {
      arguments.addAll([
        '-c:a',
        decision.targetBitDepth != null && decision.targetBitDepth! <= 16
            ? 'pcm_s16le'
            : 'pcm_s24le',
      ]);
    } else if (decision.outputFormat == TranscodeOutputFormat.alac) {
      arguments.addAll(['-c:a', 'alac', '-movflags', 'use_metadata_tags']);
      if (decision.targetBitDepth != null) {
        arguments.addAll([
          '-sample_fmt',
          decision.targetBitDepth! <= 16 ? 's16p' : 's32p',
        ]);
      }
    } else {
      arguments.addAll([
        '-c:a',
        'libmp3lame',
        '-b:a',
        '${decision.targetBitRateKbps ?? request.mp3BitRateKbps}k',
      ]);
    }

    arguments.add(outputPaths.commandOutputPath);

    return TranscodeCommandPlan(
      arguments: arguments,
      commandOutputPath: outputPaths.commandOutputPath,
      finalOutputPath: outputPaths.finalOutputPath,
    );
  }

  _ResolvedOutputPaths _resolveOutputPaths({
    required String inputPath,
    required TranscodeDecision decision,
    required TranscodeRequest request,
  }) {
    final outputExtension = _outputExtension(decision.outputFormat);
    final baseName = p.basenameWithoutExtension(inputPath);
    final inputDirectory = p.dirname(inputPath);
    final outputDirectory =
        request.outputMode == TranscodeOutputMode.outputDirectory
        ? request.outputDirectory!
        : inputDirectory;

    if (request.outputMode == TranscodeOutputMode.replaceOriginal) {
      final finalPath = p.join(inputDirectory, '$baseName$outputExtension');
      final tempPath = _uniqueTempPath(
        directory: inputDirectory,
        baseName: baseName,
        extension: outputExtension,
      );
      return _ResolvedOutputPaths(
        commandOutputPath: tempPath,
        finalOutputPath: finalPath,
      );
    }

    final desiredPath = p.join(outputDirectory, '$baseName$outputExtension');
    if (!_isConflictingPath(desiredPath, inputPath)) {
      return _ResolvedOutputPaths(
        commandOutputPath: desiredPath,
        finalOutputPath: desiredPath,
      );
    }

    var candidate = p.join(
      outputDirectory,
      '$baseName [${decision.conflictSuffix}]$outputExtension',
    );
    var index = 2;
    while (_isConflictingPath(candidate, inputPath)) {
      candidate = p.join(
        outputDirectory,
        '$baseName [${decision.conflictSuffix}] ($index)$outputExtension',
      );
      index++;
    }
    return _ResolvedOutputPaths(
      commandOutputPath: candidate,
      finalOutputPath: candidate,
    );
  }

  bool _isConflictingPath(String candidate, String inputPath) {
    final normalizedCandidate = p.normalize(candidate).toLowerCase();
    final normalizedInput = p.normalize(inputPath).toLowerCase();
    return normalizedCandidate == normalizedInput ||
        File(candidate).existsSync();
  }

  String _uniqueTempPath({
    required String directory,
    required String baseName,
    required String extension,
  }) {
    var candidate = p.join(
      directory,
      '$baseName${AppConstants.replaceTempFileMarker}$extension',
    );
    var index = 2;
    while (File(candidate).existsSync()) {
      candidate = p.join(
        directory,
        '$baseName${AppConstants.replaceTempFileMarker}-$index$extension',
      );
      index++;
    }
    return candidate;
  }

  String _outputExtension(TranscodeOutputFormat outputFormat) {
    return switch (outputFormat) {
      TranscodeOutputFormat.flac => '.flac',
      TranscodeOutputFormat.wav => '.wav',
      TranscodeOutputFormat.alac => '.m4a',
      TranscodeOutputFormat.mp3 => '.mp3',
    };
  }

  String? _buildAudioFilter({
    required TranscodeDecision decision,
    required TranscodeRequest request,
  }) {
    if (decision.targetSampleRate == null &&
        !(request.enableDither && decision.requiresBitDepthChange)) {
      return null;
    }

    // Do not force soxr: some Windows ffmpeg builds do not include it.
    final options = <String>[];
    if (decision.targetSampleRate != null) {
      options.add('osr=${decision.targetSampleRate}');
    }
    if (request.enableDither &&
        decision.requiresBitDepthChange &&
        decision.targetBitDepth != null &&
        decision.targetBitDepth! <= 16) {
      options.add('dither_method=triangular');
    }
    return 'aresample=${options.join(':')}';
  }
}

class _ResolvedOutputPaths {
  final String commandOutputPath;
  final String finalOutputPath;

  const _ResolvedOutputPaths({
    required this.commandOutputPath,
    required this.finalOutputPath,
  });
}
