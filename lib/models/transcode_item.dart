import 'package:path/path.dart' as p;

import '../constants.dart';
import 'audio_probe_info.dart';
import 'transcode_decision.dart';

class TranscodeItem {
  final String inputPath;
  // Mutable by design: this object represents task runtime state and is
  // updated across probe/queue/execute phases to keep provider updates simple.
  AudioProbeInfo? probeInfo;
  TranscodeDecision? decision;
  String? plannedOutputPath;
  String? tempOutputPath;
  String? actualOutputPath;
  TranscodeItemStatus status;
  double? progress;
  String? message;

  TranscodeItem({
    required this.inputPath,
    this.probeInfo,
    this.decision,
    this.plannedOutputPath,
    this.tempOutputPath,
    this.actualOutputPath,
    this.status = TranscodeItemStatus.pending,
    this.progress,
    this.message,
  });

  String get fileName => p.basename(inputPath);

  bool get canRun =>
      decision?.shouldTranscode == true && status == TranscodeItemStatus.ready;
}
