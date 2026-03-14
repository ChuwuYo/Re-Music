import '../constants.dart';
import 'audio_probe_info.dart';

class TranscodeResult {
  final String inputPath;
  final String? outputPath;
  final TranscodeItemStatus status;
  final String? errorMessage;
  final AudioProbeInfo? outputProbeInfo;

  const TranscodeResult({
    required this.inputPath,
    required this.status,
    this.outputPath,
    this.errorMessage,
    this.outputProbeInfo,
  });

  bool get isSuccess => status == TranscodeItemStatus.success;
}
