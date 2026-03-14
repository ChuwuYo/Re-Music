import 'package:flutter_test/flutter_test.dart';
import 'package:remusic/constants.dart';
import 'package:remusic/models/audio_probe_info.dart';
import 'package:remusic/models/transcode_request.dart';
import 'package:remusic/services/transcode_rule_engine.dart';

void main() {
  const engine = TranscodeRuleEngine();

  group('TranscodeRuleEngine', () {
    test('skips lossy input when targeting lossless output', () {
      final decision = engine.evaluate(
        probeInfo: _probe(
          kind: AudioEncodingKind.aac,
          sampleRate: 44100,
          bitRate: 256000,
        ),
        request: _request(outputFormat: TranscodeOutputFormat.flac),
      );

      expect(decision.shouldTranscode, isFalse);
      expect(decision.skipReasonKey, AppConstants.transcodeSkipLossyToLossless);
    });

    test('transcodes high-resolution lossless input down to preset', () {
      final decision = engine.evaluate(
        probeInfo: _probe(
          kind: AudioEncodingKind.flac,
          sampleRate: 96000,
          bitDepth: 24,
        ),
        request: _request(
          outputFormat: TranscodeOutputFormat.flac,
          losslessPreset: TranscodeLosslessPreset.cd16,
        ),
      );

      expect(decision.shouldTranscode, isTrue);
      expect(decision.targetSampleRate, 44100);
      expect(decision.targetBitDepth, 16);
      expect(decision.requiresSampleRateChange, isTrue);
      expect(decision.requiresBitDepthChange, isTrue);
    });

    test(
      'skips compliant lossless input when no format-only conversion is allowed',
      () {
        final decision = engine.evaluate(
          probeInfo: _probe(
            kind: AudioEncodingKind.flac,
            sampleRate: 44100,
            bitDepth: 16,
          ),
          request: _request(
            outputFormat: TranscodeOutputFormat.flac,
            losslessPreset: TranscodeLosslessPreset.cd16,
          ),
        );

        expect(decision.shouldTranscode, isFalse);
        expect(
          decision.skipReasonKey,
          AppConstants.transcodeSkipAlreadyCompliantLossless,
        );
      },
    );

    test('allows same-spec format conversion when setting is enabled', () {
      final decision = engine.evaluate(
        probeInfo: _probe(
          kind: AudioEncodingKind.wav,
          sampleRate: 44100,
          bitDepth: 16,
        ),
        request: _request(
          outputFormat: TranscodeOutputFormat.flac,
          losslessPreset: TranscodeLosslessPreset.cd16,
          allowFormatOnlyConversion: true,
        ),
      );

      expect(decision.shouldTranscode, isTrue);
      expect(decision.requiresFormatChange, isTrue);
      expect(decision.requiresSampleRateChange, isFalse);
      expect(decision.requiresBitDepthChange, isFalse);
    });

    test('skips already compliant mp3 input', () {
      final decision = engine.evaluate(
        probeInfo: _probe(
          kind: AudioEncodingKind.mp3,
          sampleRate: 44100,
          bitRate: 320000,
        ),
        request: _request(outputFormat: TranscodeOutputFormat.mp3),
      );

      expect(decision.shouldTranscode, isFalse);
      expect(
        decision.skipReasonKey,
        AppConstants.transcodeSkipAlreadyCompliantMp3,
      );
    });

    test('does not skip lossless input with unknown bit depth', () {
      final decision = engine.evaluate(
        probeInfo: _probe(
          kind: AudioEncodingKind.flac,
          sampleRate: 44100,
          bitDepth: null,
        ),
        request: _request(
          outputFormat: TranscodeOutputFormat.flac,
          losslessPreset: TranscodeLosslessPreset.cd16,
        ),
      );

      expect(decision.shouldTranscode, isTrue);
      expect(decision.skipReasonKey, isNull);
    });

    test(
      'skips mp3 when bitrate matches and source sample rate is below 44.1kHz',
      () {
        final decision = engine.evaluate(
          probeInfo: _probe(
            kind: AudioEncodingKind.mp3,
            sampleRate: 32000,
            bitRate: 320000,
          ),
          request: _request(outputFormat: TranscodeOutputFormat.mp3),
        );

        expect(decision.shouldTranscode, isFalse);
        expect(decision.targetSampleRate, 32000);
        expect(
          decision.skipReasonKey,
          AppConstants.transcodeSkipAlreadyCompliantMp3,
        );
      },
    );

    test('downsamples mp3 when source sample rate is above 44.1kHz', () {
      final decision = engine.evaluate(
        probeInfo: _probe(
          kind: AudioEncodingKind.mp3,
          sampleRate: 48000,
          bitRate: 320000,
        ),
        request: _request(outputFormat: TranscodeOutputFormat.mp3),
      );

      expect(decision.shouldTranscode, isTrue);
      expect(decision.targetSampleRate, 44100);
      expect(decision.requiresSampleRateChange, isTrue);
    });
  });
}

AudioProbeInfo _probe({
  required AudioEncodingKind kind,
  int? sampleRate,
  int? bitDepth,
  int? bitRate,
}) {
  return AudioProbeInfo(
    path: 'E:/music/input.${_extensionForKind(kind)}',
    extension: _extensionForKind(kind),
    codecName: _codecForKind(kind),
    kind: kind,
    sampleRate: sampleRate,
    bitDepth: bitDepth,
    bitRate: bitRate,
    durationSeconds: 120,
  );
}

TranscodeRequest _request({
  required TranscodeOutputFormat outputFormat,
  TranscodeLosslessPreset losslessPreset = TranscodeLosslessPreset.cd16,
  bool allowFormatOnlyConversion = false,
}) {
  return TranscodeRequest(
    outputFormat: outputFormat,
    losslessPreset: losslessPreset,
    mp3BitRateKbps: 320,
    allowFormatOnlyConversion: allowFormatOnlyConversion,
    enableDither: false,
    outputMode: TranscodeOutputMode.keepOriginal,
    outputDirectory: null,
    concurrency: 2,
  );
}

String _extensionForKind(AudioEncodingKind kind) {
  return switch (kind) {
    AudioEncodingKind.flac => 'flac',
    AudioEncodingKind.wav => 'wav',
    AudioEncodingKind.alac => 'm4a',
    AudioEncodingKind.mp3 => 'mp3',
    AudioEncodingKind.aac => 'aac',
    AudioEncodingKind.ogg => 'ogg',
    AudioEncodingKind.opus => 'opus',
    AudioEncodingKind.wma => 'wma',
    AudioEncodingKind.unknown => 'bin',
  };
}

String _codecForKind(AudioEncodingKind kind) {
  return switch (kind) {
    AudioEncodingKind.flac => 'flac',
    AudioEncodingKind.wav => 'pcm_s16le',
    AudioEncodingKind.alac => 'alac',
    AudioEncodingKind.mp3 => 'mp3',
    AudioEncodingKind.aac => 'aac',
    AudioEncodingKind.ogg => 'vorbis',
    AudioEncodingKind.opus => 'opus',
    AudioEncodingKind.wma => 'wmav2',
    AudioEncodingKind.unknown => 'unknown',
  };
}
