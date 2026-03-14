import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:path/path.dart' as p;
import 'package:remusic/constants.dart';
import 'package:remusic/models/audio_probe_info.dart';
import 'package:remusic/models/transcode_decision.dart';
import 'package:remusic/models/transcode_request.dart';
import 'package:remusic/services/transcode_command_builder.dart';

void main() {
  const builder = TranscodeCommandBuilder();

  group('TranscodeCommandBuilder', () {
    test('builds mp3 command with fixed bitrate and compatible resampler', () {
      final plan = builder.build(
        probeInfo: _probe('E:/music/source.flac', AudioEncodingKind.flac),
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
        request: _request(outputFormat: TranscodeOutputFormat.mp3),
      );

      expect(plan.finalOutputPath, p.join('E:/music', 'source.mp3'));
      expect(
        plan.arguments,
        containsAllInOrder([
          '-af',
          'aresample=osr=44100',
          '-ar',
          '44100',
          '-c:a',
          'libmp3lame',
          '-b:a',
          '320k',
        ]),
      );
    });

    test(
      'uses temporary target path and final extension in replace mode',
      () async {
        final dir = await Directory.systemTemp.createTemp('remusic_builder_');
        try {
          final inputPath = p.join(dir.path, 'source.wav');
          await File(inputPath).writeAsString('input');

          final plan = builder.build(
            probeInfo: _probe(inputPath, AudioEncodingKind.wav),
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
            request: _request(
              outputFormat: TranscodeOutputFormat.flac,
              outputMode: TranscodeOutputMode.replaceOriginal,
            ),
          );

          expect(plan.commandOutputPath, isNot(equals(inputPath)));
          expect(plan.commandOutputPath, endsWith('.flac'));
          expect(
            p.basename(plan.commandOutputPath),
            contains(AppConstants.replaceTempFileMarker),
          );
          expect(plan.finalOutputPath, p.join(dir.path, 'source.flac'));
        } finally {
          await dir.delete(recursive: true);
        }
      },
    );

    test(
      'replace mode keeps input path as final target when formats match',
      () async {
        final dir = await Directory.systemTemp.createTemp('remusic_builder_');
        try {
          final inputPath = p.join(dir.path, 'source.wav');
          await File(inputPath).writeAsString('input');

          final plan = builder.build(
            probeInfo: _probe(inputPath, AudioEncodingKind.wav),
            decision: const TranscodeDecision(
              shouldTranscode: true,
              outputFormat: TranscodeOutputFormat.wav,
              targetSampleRate: 48000,
              targetBitDepth: 24,
              targetBitRateKbps: null,
              requiresFormatChange: false,
              requiresSampleRateChange: true,
              requiresBitDepthChange: true,
            ),
            request: _request(
              outputFormat: TranscodeOutputFormat.wav,
              outputMode: TranscodeOutputMode.replaceOriginal,
            ),
          );

          expect(plan.commandOutputPath, isNot(equals(inputPath)));
          expect(plan.finalOutputPath, equals(inputPath));
        } finally {
          await dir.delete(recursive: true);
        }
      },
    );

    test(
      'replace mode avoids overwriting existing sibling output files',
      () async {
        final dir = await Directory.systemTemp.createTemp('remusic_builder_');
        try {
          final inputPath = p.join(dir.path, 'source.wav');
          final existingSiblingPath = p.join(dir.path, 'source.flac');
          await File(inputPath).writeAsString('input');
          await File(existingSiblingPath).writeAsString('existing-output');

          final plan = builder.build(
            probeInfo: _probe(inputPath, AudioEncodingKind.wav),
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
            request: _request(
              outputFormat: TranscodeOutputFormat.flac,
              outputMode: TranscodeOutputMode.replaceOriginal,
            ),
          );

          expect(plan.commandOutputPath, isNot(equals(inputPath)));
          expect(plan.finalOutputPath, isNot(equals(existingSiblingPath)));
          expect(
            p.basename(plan.finalOutputPath),
            startsWith('source [FLAC 44.1kHz 16bit]'),
          );
        } finally {
          await dir.delete(recursive: true);
        }
      },
    );

    test(
      'appends conflict suffix only when target path already exists',
      () async {
        final dir = await Directory.systemTemp.createTemp('remusic_builder_');
        try {
          final inputPath = p.join(dir.path, 'song.flac');
          await File(inputPath).writeAsString('input');
          await File(p.join(dir.path, 'song.mp3')).writeAsString('existing');

          final plan = builder.build(
            probeInfo: _probe(inputPath, AudioEncodingKind.flac),
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
            request: _request(outputFormat: TranscodeOutputFormat.mp3),
          );

          expect(p.basename(plan.finalOutputPath), 'song [MP3 320k].mp3');
        } finally {
          await dir.delete(recursive: true);
        }
      },
    );

    test('reserves names across same-batch planning', () async {
      final dir = await Directory.systemTemp.createTemp('remusic_builder_');
      try {
        final firstInput = p.join(dir.path, 'song.flac');
        final secondInput = p.join(dir.path, 'song.wav');
        await File(firstInput).writeAsString('input-1');
        await File(secondInput).writeAsString('input-2');
        final reserved = <String>{};

        final firstPlan = builder.build(
          probeInfo: _probe(firstInput, AudioEncodingKind.flac),
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
          request: _request(outputFormat: TranscodeOutputFormat.mp3),
          reservedOutputPaths: reserved,
        );

        final secondPlan = builder.build(
          probeInfo: _probe(secondInput, AudioEncodingKind.wav),
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
          request: _request(outputFormat: TranscodeOutputFormat.mp3),
          reservedOutputPaths: reserved,
        );

        expect(
          firstPlan.finalOutputPath,
          isNot(equals(secondPlan.finalOutputPath)),
        );
      } finally {
        await dir.delete(recursive: true);
      }
    });

    test(
      'builds ALAC command with metadata copy and bit depth sample format',
      () {
        final plan = builder.build(
          probeInfo: _probe('E:/music/source.flac', AudioEncodingKind.flac),
          decision: const TranscodeDecision(
            shouldTranscode: true,
            outputFormat: TranscodeOutputFormat.alac,
            targetSampleRate: 48000,
            targetBitDepth: 24,
            targetBitRateKbps: null,
            requiresFormatChange: true,
            requiresSampleRateChange: true,
            requiresBitDepthChange: false,
          ),
          request: _request(
            outputFormat: TranscodeOutputFormat.alac,
            losslessPreset: TranscodeLosslessPreset.studio24,
          ),
        );

        expect(
          plan.arguments,
          containsAllInOrder([
            '-map',
            '0:v?',
            '-c:v',
            'copy',
            '-c:a',
            'alac',
            '-movflags',
            'use_metadata_tags',
            '-sample_fmt',
            's32p',
          ]),
        );
      },
    );
  });
}

AudioProbeInfo _probe(String path, AudioEncodingKind kind) {
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
    sampleRate: 96000,
    bitDepth: 24,
    durationSeconds: 60,
  );
}

TranscodeRequest _request({
  required TranscodeOutputFormat outputFormat,
  TranscodeLosslessPreset losslessPreset = TranscodeLosslessPreset.cd16,
  TranscodeOutputMode outputMode = TranscodeOutputMode.keepOriginal,
}) {
  return TranscodeRequest(
    outputFormat: outputFormat,
    losslessPreset: losslessPreset,
    mp3BitRateKbps: 320,
    allowFormatOnlyConversion: false,
    enableDither: false,
    outputMode: outputMode,
    outputDirectory: null,
    concurrency: 2,
  );
}
