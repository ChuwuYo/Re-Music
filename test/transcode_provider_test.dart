import 'package:flutter_test/flutter_test.dart';
import 'package:remusic/providers/transcode_provider.dart';

void main() {
  group('numeric setting input', () {
    test('accepts allowed MP3 bitrate and ignores invalid values', () {
      final provider = TranscodeProvider();

      expect(provider.trySetMp3BitRateKbps('192'), isTrue);
      expect(provider.mp3BitRateKbps, 192);

      expect(provider.trySetMp3BitRateKbps('160'), isFalse);
      expect(provider.trySetMp3BitRateKbps('abc'), isFalse);
      expect(provider.mp3BitRateKbps, 192);
    });

    test('accepts concurrency in range and rejects out-of-range values', () {
      final provider = TranscodeProvider();

      expect(provider.trySetConcurrency(' 4 '), isTrue);
      expect(provider.concurrency, 4);

      expect(provider.trySetConcurrency('0'), isFalse);
      expect(provider.trySetConcurrency('6'), isFalse);
      expect(provider.concurrency, 4);
    });
  });
}
