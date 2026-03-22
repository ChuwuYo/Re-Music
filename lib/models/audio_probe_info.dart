import 'package:path/path.dart' as p;

import '../constants.dart';

enum AudioEncodingKind { flac, wav, alac, mp3, aac, ogg, opus, wma, unknown }

class AudioProbeInfo {
  final String path;
  final String extension;
  final String codecName;
  final String? sampleFormat;
  final AudioEncodingKind kind;
  final int? sampleRate;
  final int? bitDepth;
  final int? bitRate;
  final double? durationSeconds;

  const AudioProbeInfo({
    required this.path,
    required this.extension,
    required this.codecName,
    required this.kind,
    this.sampleFormat,
    this.sampleRate,
    this.bitDepth,
    this.bitRate,
    this.durationSeconds,
  });

  bool get isLossless => switch (kind) {
    AudioEncodingKind.flac || AudioEncodingKind.alac => true,
    AudioEncodingKind.wav => codecName.startsWith('pcm_'),
    _ => false,
  };

  bool get isLossy => switch (kind) {
    AudioEncodingKind.mp3 ||
    AudioEncodingKind.aac ||
    AudioEncodingKind.ogg ||
    AudioEncodingKind.opus ||
    AudioEncodingKind.wma => true,
    AudioEncodingKind.wav => !codecName.startsWith('pcm_'),
    _ => false,
  };

  TranscodeOutputFormat? get outputFormatEquivalent => switch (kind) {
    AudioEncodingKind.flac => TranscodeOutputFormat.flac,
    AudioEncodingKind.wav => TranscodeOutputFormat.wav,
    AudioEncodingKind.alac => TranscodeOutputFormat.alac,
    AudioEncodingKind.mp3 => TranscodeOutputFormat.mp3,
    _ => null,
  };

  String get fileName => p.basename(path);

  String get kindLabel => switch (kind) {
    AudioEncodingKind.flac => 'FLAC',
    AudioEncodingKind.wav => 'WAV',
    AudioEncodingKind.alac => 'ALAC',
    AudioEncodingKind.mp3 => 'MP3',
    AudioEncodingKind.aac => 'AAC',
    AudioEncodingKind.ogg => 'OGG',
    AudioEncodingKind.opus => 'Opus',
    AudioEncodingKind.wma => 'WMA',
    AudioEncodingKind.unknown => codecName.isEmpty ? extension : codecName,
  };

  String get summary {
    final parts = <String>[kindLabel];
    if (sampleRate != null) {
      parts.add(_formatSampleRate(sampleRate!));
    }
    if (isLossless && bitDepth != null) {
      parts.add('${bitDepth!}bit');
    }
    if (kind == AudioEncodingKind.mp3 && bitRate != null) {
      parts.add('${(bitRate! / 1000).round()}k');
    }
    return parts.join(' / ');
  }

  static String _formatSampleRate(int sampleRate) {
    if (sampleRate % 1000 == 0) {
      return '${sampleRate ~/ 1000}kHz';
    }
    return '${(sampleRate / 1000).toStringAsFixed(1)}kHz';
  }
}
