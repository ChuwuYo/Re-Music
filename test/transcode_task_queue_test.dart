import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:path/path.dart' as p;
import 'package:remusic/constants.dart';
import 'package:remusic/models/audio_probe_info.dart';
import 'package:remusic/models/transcode_decision.dart';
import 'package:remusic/models/transcode_item.dart';
import 'package:remusic/models/transcode_request.dart';
import 'package:remusic/services/probe_service.dart';
import 'package:remusic/services/transcode_command_builder.dart';
import 'package:remusic/services/transcode_task_queue.dart';

void main() {
  group('TranscodeTaskQueue', () {
    test('parses progress and marks successful jobs complete', () async {
      final dir = await Directory.systemTemp.createTemp('remusic_queue_');
      try {
        final inputPath = p.join(dir.path, 'source.flac');
        await File(inputPath).writeAsString('input');
        final outputPath = p.join(dir.path, 'source.mp3');
        final updates = <({TranscodeItemStatus status, double? progress})>[];

        final queue = TranscodeTaskQueue(
          ffmpegExecutablePath: 'ffmpeg',
          probeService: ProbeService(
            ffprobeExecutablePath: 'ffprobe',
            runner: (executable, arguments) async {
              expect(arguments.last, outputPath);
              return _probeJson(
                codecName: 'mp3',
                sampleRate: 44100,
                bitRate: 320000,
                durationSeconds: 10,
              );
            },
          ),
          commandBuilder: const TranscodeCommandBuilder(),
          processStarter: (executable, arguments) async {
            await File(arguments.last).writeAsString('output');
            return _FakeProcessHandle(
              stderr: Stream<List<int>>.fromIterable([
                utf8.encode('time=00:00:05.00 bitrate=320.0kbits/s\n'),
              ]),
              exitCode: 0,
            );
          },
        );

        final item = TranscodeItem(
          inputPath: inputPath,
          probeInfo: _inputProbe(
            path: inputPath,
            kind: AudioEncodingKind.flac,
            sampleRate: 96000,
            bitDepth: 24,
            durationSeconds: 10,
          ),
          decision: const TranscodeDecision(
            shouldTranscode: true,
            outputFormat: TranscodeOutputFormat.mp3,
            targetSampleRate: 44100,
            targetBitDepth: null,
            targetBitRateKbps: 320,
            requiresFormatChange: true,
            requiresSampleRateChange: true,
            requiresBitDepthChange: false,
          ),
          status: TranscodeItemStatus.ready,
        );

        final results = await queue.run(
          items: [item],
          request: _request(outputFormat: TranscodeOutputFormat.mp3),
          onItemUpdated: (updatedItem) {
            updates.add((
              status: updatedItem.status,
              progress: updatedItem.progress,
            ));
          },
        );

        expect(results, hasLength(1));
        expect(results.single.isSuccess, isTrue);
        expect(item.status, TranscodeItemStatus.success);
        expect(item.actualOutputPath, outputPath);
        expect(
          updates.any(
            (snapshot) =>
                snapshot.status == TranscodeItemStatus.running &&
                snapshot.progress != null &&
                snapshot.progress! > 0 &&
                snapshot.progress! < 1,
          ),
          isTrue,
        );
      } finally {
        await dir.delete(recursive: true);
      }
    });

    test(
      'accepts minor MP3 bitrate variance during output validation',
      () async {
        final dir = await Directory.systemTemp.createTemp('remusic_queue_');
        try {
          final inputPath = p.join(dir.path, 'source.flac');
          await File(inputPath).writeAsString('input');
          final outputPath = p.join(dir.path, 'source.mp3');

          final queue = TranscodeTaskQueue(
            ffmpegExecutablePath: 'ffmpeg',
            probeService: ProbeService(
              ffprobeExecutablePath: 'ffprobe',
              runner: (executable, arguments) async {
                expect(arguments.last, outputPath);
                return _probeJson(
                  codecName: 'mp3',
                  sampleRate: 44100,
                  bitRate: 319000,
                  durationSeconds: 10,
                );
              },
            ),
            commandBuilder: const TranscodeCommandBuilder(),
            processStarter: (executable, arguments) async {
              await File(arguments.last).writeAsString('output');
              return _FakeProcessHandle(
                stderr: Stream<List<int>>.fromIterable([
                  utf8.encode('time=00:00:09.00 bitrate=319.0kbits/s\n'),
                ]),
                exitCode: 0,
              );
            },
          );

          final item = TranscodeItem(
            inputPath: inputPath,
            probeInfo: _inputProbe(
              path: inputPath,
              kind: AudioEncodingKind.flac,
              sampleRate: 96000,
              bitDepth: 24,
              durationSeconds: 10,
            ),
            decision: const TranscodeDecision(
              shouldTranscode: true,
              outputFormat: TranscodeOutputFormat.mp3,
              targetSampleRate: 44100,
              targetBitDepth: null,
              targetBitRateKbps: 320,
              requiresFormatChange: true,
              requiresSampleRateChange: true,
              requiresBitDepthChange: false,
            ),
            status: TranscodeItemStatus.ready,
          );

          final results = await queue.run(
            items: [item],
            request: _request(outputFormat: TranscodeOutputFormat.mp3),
            onItemUpdated: (_) {},
          );

          expect(results.single.isSuccess, isTrue);
          expect(item.status, TranscodeItemStatus.success);
        } finally {
          await dir.delete(recursive: true);
        }
      },
    );

    test(
      'falls back to indeterminate item progress when duration is unknown',
      () async {
        final dir = await Directory.systemTemp.createTemp('remusic_queue_');
        try {
          final inputPath = p.join(dir.path, 'source.flac');
          await File(inputPath).writeAsString('input');
          final outputPath = p.join(dir.path, 'source.mp3');
          final runningProgress = <double?>[];

          final queue = TranscodeTaskQueue(
            ffmpegExecutablePath: 'ffmpeg',
            probeService: ProbeService(
              ffprobeExecutablePath: 'ffprobe',
              runner: (executable, arguments) async {
                return _probeJson(
                  codecName: 'mp3',
                  sampleRate: 44100,
                  bitRate: 320000,
                  durationSeconds: 10,
                );
              },
            ),
            commandBuilder: const TranscodeCommandBuilder(),
            processStarter: (executable, arguments) async {
              await File(arguments.last).writeAsString('output');
              return _FakeProcessHandle(
                stderr: Stream<List<int>>.fromIterable([
                  utf8.encode('time=00:00:05.00 bitrate=320.0kbits/s\n'),
                ]),
                exitCode: 0,
              );
            },
          );

          final item = TranscodeItem(
            inputPath: inputPath,
            probeInfo: _inputProbe(
              path: inputPath,
              kind: AudioEncodingKind.flac,
              sampleRate: 96000,
              bitDepth: 24,
              durationSeconds: null,
            ),
            decision: const TranscodeDecision(
              shouldTranscode: true,
              outputFormat: TranscodeOutputFormat.mp3,
              targetSampleRate: 44100,
              targetBitDepth: null,
              targetBitRateKbps: 320,
              requiresFormatChange: true,
              requiresSampleRateChange: true,
              requiresBitDepthChange: false,
            ),
            status: TranscodeItemStatus.ready,
          );

          await queue.run(
            items: [item],
            request: _request(outputFormat: TranscodeOutputFormat.mp3),
            onItemUpdated: (updatedItem) {
              if (updatedItem.status == TranscodeItemStatus.running) {
                runningProgress.add(updatedItem.progress);
              }
            },
          );

          expect(item.status, TranscodeItemStatus.success);
          expect(item.actualOutputPath, outputPath);
          expect(runningProgress, contains(isNull));
        } finally {
          await dir.delete(recursive: true);
        }
      },
    );

    test(
      'replaces original file with new extension and removes old source',
      () async {
        final dir = await Directory.systemTemp.createTemp('remusic_queue_');
        try {
          final inputPath = p.join(dir.path, 'source.wav');
          final finalOutputPath = p.join(dir.path, 'source.flac');
          await File(inputPath).writeAsString('input');

          final queue = TranscodeTaskQueue(
            ffmpegExecutablePath: 'ffmpeg',
            probeService: ProbeService(
              ffprobeExecutablePath: 'ffprobe',
              runner: (executable, arguments) async {
                expect(
                  arguments.last,
                  contains(AppConstants.replaceTempFileMarker),
                );
                return _probeJson(
                  codecName: 'flac',
                  sampleRate: 44100,
                  bitDepth: 16,
                  durationSeconds: 10,
                );
              },
            ),
            commandBuilder: const TranscodeCommandBuilder(),
            processStarter: (executable, arguments) async {
              await File(arguments.last).writeAsString('output');
              return _FakeProcessHandle(
                stderr: Stream<List<int>>.fromIterable([
                  utf8.encode('time=00:00:09.00 bitrate=1000.0kbits/s\n'),
                ]),
                exitCode: 0,
              );
            },
          );

          final item = TranscodeItem(
            inputPath: inputPath,
            probeInfo: _inputProbe(
              path: inputPath,
              kind: AudioEncodingKind.wav,
              sampleRate: 96000,
              bitDepth: 24,
              durationSeconds: 10,
            ),
            decision: const TranscodeDecision(
              shouldTranscode: true,
              outputFormat: TranscodeOutputFormat.flac,
              targetSampleRate: 44100,
              targetBitDepth: 16,
              targetBitRateKbps: null,
              requiresFormatChange: true,
              requiresSampleRateChange: true,
              requiresBitDepthChange: true,
            ),
            status: TranscodeItemStatus.ready,
          );

          final results = await queue.run(
            items: [item],
            request: _request(
              outputFormat: TranscodeOutputFormat.flac,
              outputMode: TranscodeOutputMode.replaceOriginal,
            ),
            onItemUpdated: (_) {},
          );

          expect(results.single.isSuccess, isTrue);
          expect(item.actualOutputPath, finalOutputPath);
          expect(await File(finalOutputPath).exists(), isTrue);
          expect(await File(inputPath).exists(), isFalse);
        } finally {
          await dir.delete(recursive: true);
        }
      },
    );

    test(
      'cleans up failed output when validation does not match target',
      () async {
        final dir = await Directory.systemTemp.createTemp('remusic_queue_');
        try {
          final inputPath = p.join(dir.path, 'source.flac');
          final outputPath = p.join(dir.path, 'source.wav');
          await File(inputPath).writeAsString('input');

          final queue = TranscodeTaskQueue(
            ffmpegExecutablePath: 'ffmpeg',
            probeService: ProbeService(
              ffprobeExecutablePath: 'ffprobe',
              runner: (executable, arguments) async {
                expect(arguments.last, outputPath);
                return _probeJson(
                  codecName: 'pcm_s24le',
                  sampleRate: 48000,
                  bitDepth: 24,
                  durationSeconds: 10,
                );
              },
            ),
            commandBuilder: const TranscodeCommandBuilder(),
            processStarter: (executable, arguments) async {
              await File(arguments.last).writeAsString('bad-output');
              return _FakeProcessHandle(
                stderr: Stream<List<int>>.fromIterable([
                  utf8.encode('time=00:00:09.00 bitrate=2304.0kbits/s\n'),
                ]),
                exitCode: 0,
              );
            },
          );

          final item = TranscodeItem(
            inputPath: inputPath,
            probeInfo: _inputProbe(
              path: inputPath,
              kind: AudioEncodingKind.flac,
              sampleRate: 96000,
              bitDepth: 24,
              durationSeconds: 10,
            ),
            decision: const TranscodeDecision(
              shouldTranscode: true,
              outputFormat: TranscodeOutputFormat.wav,
              targetSampleRate: 44100,
              targetBitDepth: 16,
              targetBitRateKbps: null,
              requiresFormatChange: true,
              requiresSampleRateChange: true,
              requiresBitDepthChange: true,
            ),
            status: TranscodeItemStatus.ready,
          );

          final results = await queue.run(
            items: [item],
            request: _request(outputFormat: TranscodeOutputFormat.wav),
            onItemUpdated: (_) {},
          );

          expect(results.single.isSuccess, isFalse);
          expect(item.status, TranscodeItemStatus.error);
          expect(await File(outputPath).exists(), isFalse);
        } finally {
          await dir.delete(recursive: true);
        }
      },
    );
  });
}

class _FakeProcessHandle implements TranscodeProcessHandle {
  final Stream<List<int>> _stdout;
  final Stream<List<int>> _stderr;
  final Future<int> _exitCode;

  _FakeProcessHandle({
    Stream<List<int>>? stdout,
    required Stream<List<int>> stderr,
    required int exitCode,
  }) : _stdout = stdout ?? Stream<List<int>>.empty(),
       _stderr = stderr,
       _exitCode = Future<int>.value(exitCode);

  @override
  Stream<List<int>> get stdout => _stdout;

  @override
  Stream<List<int>> get stderr => _stderr;

  @override
  Future<int> get exitCode => _exitCode;
}

AudioProbeInfo _inputProbe({
  required String path,
  required AudioEncodingKind kind,
  required int sampleRate,
  required int? bitDepth,
  required double? durationSeconds,
}) {
  return AudioProbeInfo(
    path: path,
    extension: p.extension(path).replaceFirst('.', ''),
    codecName: switch (kind) {
      AudioEncodingKind.flac => 'flac',
      AudioEncodingKind.wav => 'pcm_s16le',
      AudioEncodingKind.alac => 'alac',
      AudioEncodingKind.mp3 => 'mp3',
      AudioEncodingKind.aac => 'aac',
      AudioEncodingKind.ogg => 'vorbis',
      AudioEncodingKind.opus => 'opus',
      AudioEncodingKind.wma => 'wmav2',
      AudioEncodingKind.unknown => 'unknown',
    },
    kind: kind,
    sampleRate: sampleRate,
    bitDepth: bitDepth,
    durationSeconds: durationSeconds,
  );
}

TranscodeRequest _request({
  required TranscodeOutputFormat outputFormat,
  TranscodeOutputMode outputMode = TranscodeOutputMode.keepOriginal,
}) {
  return TranscodeRequest(
    outputFormat: outputFormat,
    losslessPreset: TranscodeLosslessPreset.cd16,
    mp3BitRateKbps: 320,
    allowFormatOnlyConversion: false,
    enableDither: false,
    outputMode: outputMode,
    outputDirectory: null,
    concurrency: AppConstants.transcodeConcurrencyMax + 2,
  );
}

String _probeJson({
  required String codecName,
  required int sampleRate,
  int? bitDepth,
  int? bitRate,
  required double durationSeconds,
}) {
  final stream = <String, dynamic>{
    'codec_type': 'audio',
    'codec_name': codecName,
    'sample_rate': '$sampleRate',
    'sample_fmt': codecName == 'mp3' ? 'fltp' : 's16',
    'duration': '$durationSeconds',
    if (bitDepth != null) 'bits_per_raw_sample': '$bitDepth',
    if (bitRate != null) 'bit_rate': '$bitRate',
  };
  return jsonEncode({
    'streams': [stream],
    'format': {
      'duration': '$durationSeconds',
      if (bitRate != null) 'bit_rate': '$bitRate',
    },
  });
}
