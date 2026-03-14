import 'package:flutter_test/flutter_test.dart';
import 'package:remusic/models/audio_probe_info.dart';
import 'package:remusic/services/probe_service.dart';

void main() {
  final service = ProbeService(ffprobeExecutablePath: 'ffprobe');

  group('ProbeService.parseProbeOutput', () {
    test('parses ALAC in m4a container', () {
      final info = service.parseProbeOutput('album-track.m4a', '''
{
  "streams": [
    {
      "codec_type": "audio",
      "codec_name": "alac",
      "sample_rate": "44100",
      "bits_per_raw_sample": "24",
      "sample_fmt": "s32p",
      "bit_rate": "921600",
      "duration": "12.5"
    }
  ],
  "format": {
    "bit_rate": "921600",
    "duration": "12.5"
  }
}
''');

      expect(info.kind, AudioEncodingKind.alac);
      expect(info.sampleRate, 44100);
      expect(info.bitDepth, 24);
      expect(info.durationSeconds, 12.5);
    });

    test('parses AAC in m4a container', () {
      final info = service.parseProbeOutput('album-track.m4a', '''
{
  "streams": [
    {
      "codec_type": "audio",
      "codec_name": "aac",
      "sample_rate": "44100",
      "sample_fmt": "fltp",
      "bit_rate": "256000"
    }
  ],
  "format": {
    "bit_rate": "256000",
    "duration": "5.0"
  }
}
''');

      expect(info.kind, AudioEncodingKind.aac);
      expect(info.bitRate, 256000);
      expect(info.durationSeconds, 5.0);
    });

    test('falls back to bits_per_sample when raw sample depth is missing', () {
      final info = service.parseProbeOutput('track.wav', '''
{
  "streams": [
    {
      "codec_type": "audio",
      "codec_name": "pcm_s24le",
      "sample_rate": "48000",
      "bits_per_sample": 24,
      "sample_fmt": "s32"
    }
  ],
  "format": {
    "duration": "30.0"
  }
}
''');

      expect(info.kind, AudioEncodingKind.wav);
      expect(info.bitDepth, 24);
      expect(info.sampleRate, 48000);
    });

    test(
      'infers 24-bit from s32 sample format when raw bit depth is missing',
      () {
        final info = service.parseProbeOutput('track.flac', '''
{
  "streams": [
    {
      "codec_type": "audio",
      "codec_name": "flac",
      "sample_rate": "48000",
      "sample_fmt": "s32"
    }
  ],
  "format": {
    "duration": "30.0"
  }
}
''');

        expect(info.kind, AudioEncodingKind.flac);
        expect(info.bitDepth, 24);
      },
    );

    test('defaults unknown sample format to 16-bit', () {
      final info = service.parseProbeOutput('track.flac', '''
{
  "streams": [
    {
      "codec_type": "audio",
      "codec_name": "flac",
      "sample_rate": "44100",
      "sample_fmt": "unknown_fmt"
    }
  ],
  "format": {
    "duration": "12.0"
  }
}
''');

      expect(info.kind, AudioEncodingKind.flac);
      expect(info.bitDepth, 16);
    });

    test('uses float sample formats for 32-bit fallback', () {
      final info = service.parseProbeOutput('track.wav', '''
{
  "streams": [
    {
      "codec_type": "audio",
      "codec_name": "pcm_f32le",
      "sample_rate": "96000",
      "sample_fmt": "fltp"
    }
  ],
  "format": {
    "duration": "42.0"
  }
}
''');

      expect(info.kind, AudioEncodingKind.wav);
      expect(info.bitDepth, 32);
      expect(info.sampleRate, 96000);
    });
  });

  group('ProbeService.parseProbeKeyValueOutput', () {
    test('parses bitrate and duration from key-value output', () {
      final info = service.parseProbeKeyValueOutput('track.mp3', '''
codec_name=mp3
sample_fmt=fltp
sample_rate=44100
bit_rate=320000
duration=123.456
''');

      expect(info.kind, AudioEncodingKind.mp3);
      expect(info.sampleRate, 44100);
      expect(info.bitRate, 320000);
      expect(info.durationSeconds, closeTo(123.456, 0.0001));
    });

    test('accepts stream/format mixed key-value lines', () {
      final info = service.parseProbeKeyValueOutput('track.mp3', '''
codec_name=mp3
sample_fmt=fltp
sample_rate=44100
bit_rate=319872
duration=12.34
bits_per_raw_sample=0
bits_per_sample=0
''');

      expect(info.kind, AudioEncodingKind.mp3);
      expect(info.bitRate, 319872);
      expect(info.durationSeconds, closeTo(12.34, 0.0001));
    });
  });

  test('probeFile requests bitrate and duration fields', () async {
    late List<String> capturedArgs;
    final probe = ProbeService(
      ffprobeExecutablePath: 'ffprobe',
      runner: (executable, arguments) async {
        capturedArgs = arguments;
        return '''
codec_name=mp3
sample_fmt=fltp
sample_rate=44100
bit_rate=320000
duration=1.0
''';
      },
    );

    await probe.probeFile('demo.mp3');
    final showEntriesIndex = capturedArgs.indexOf('-show_entries');
    expect(showEntriesIndex, greaterThanOrEqualTo(0));
    expect(capturedArgs[showEntriesIndex + 1], contains('bit_rate'));
    expect(capturedArgs[showEntriesIndex + 1], contains('duration'));
  });
}
