import '../constants.dart';

class TranscodeRequest {
  final TranscodeOutputFormat outputFormat;
  final TranscodeLosslessPreset losslessPreset;
  final int mp3BitRateKbps;
  final bool allowFormatOnlyConversion;
  final bool enableDither;
  final TranscodeOutputMode outputMode;
  final String? outputDirectory;
  final int concurrency;

  const TranscodeRequest({
    required this.outputFormat,
    required this.losslessPreset,
    required this.mp3BitRateKbps,
    required this.allowFormatOnlyConversion,
    required this.enableDither,
    required this.outputMode,
    required this.outputDirectory,
    required this.concurrency,
  });

  int get requestedSampleRate => outputFormat == TranscodeOutputFormat.mp3
      ? 44100
      : losslessPreset.sampleRate;

  int? get requestedBitDepth => outputFormat == TranscodeOutputFormat.mp3
      ? null
      : losslessPreset.bitDepth;
}
