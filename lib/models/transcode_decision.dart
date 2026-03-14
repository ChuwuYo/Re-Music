import '../constants.dart';

class TranscodeDecision {
  final bool shouldTranscode;
  final String? skipReasonKey;
  final TranscodeOutputFormat outputFormat;
  final int? targetSampleRate;
  final int? targetBitDepth;
  final int? targetBitRateKbps;
  final bool requiresFormatChange;
  final bool requiresSampleRateChange;
  final bool requiresBitDepthChange;

  const TranscodeDecision({
    required this.shouldTranscode,
    required this.outputFormat,
    required this.targetSampleRate,
    required this.targetBitDepth,
    required this.targetBitRateKbps,
    required this.requiresFormatChange,
    required this.requiresSampleRateChange,
    required this.requiresBitDepthChange,
    this.skipReasonKey,
  });

  bool get isSkipped => !shouldTranscode;

  String get targetSummary {
    final parts = <String>[
      switch (outputFormat) {
        TranscodeOutputFormat.flac => 'FLAC',
        TranscodeOutputFormat.wav => 'WAV',
        TranscodeOutputFormat.alac => 'ALAC',
        TranscodeOutputFormat.mp3 => 'MP3',
      },
    ];
    if (targetSampleRate != null) {
      parts.add(_formatSampleRate(targetSampleRate!));
    }
    if (outputFormat == TranscodeOutputFormat.mp3) {
      if (targetBitRateKbps != null) {
        parts.add('${targetBitRateKbps!}k');
      }
    } else if (targetBitDepth != null) {
      parts.add('${targetBitDepth!}bit');
    }
    return parts.join(' / ');
  }

  String get conflictSuffix {
    final parts = <String>[];
    if (outputFormat == TranscodeOutputFormat.mp3) {
      parts.add('MP3');
      if (targetBitRateKbps != null) {
        parts.add('${targetBitRateKbps!}k');
      }
    } else {
      parts.addAll([
        switch (outputFormat) {
          TranscodeOutputFormat.flac => 'FLAC',
          TranscodeOutputFormat.wav => 'WAV',
          TranscodeOutputFormat.alac => 'ALAC',
          TranscodeOutputFormat.mp3 => 'MP3',
        },
        if (targetSampleRate != null) _formatSampleRate(targetSampleRate!),
        if (targetBitDepth != null) '${targetBitDepth!}bit',
      ]);
    }
    return parts.join(' ');
  }

  static String _formatSampleRate(int sampleRate) {
    if (sampleRate % 1000 == 0) {
      return '${sampleRate ~/ 1000}kHz';
    }
    return '${(sampleRate / 1000).toStringAsFixed(1)}kHz';
  }
}
