import '../constants.dart';
import '../models/audio_probe_info.dart';
import '../models/transcode_decision.dart';
import '../models/transcode_request.dart';

class TranscodeRuleEngine {
  const TranscodeRuleEngine();

  TranscodeDecision evaluate({
    required AudioProbeInfo probeInfo,
    required TranscodeRequest request,
  }) {
    if (request.outputMode == TranscodeOutputMode.outputDirectory &&
        (request.outputDirectory == null ||
            request.outputDirectory!.trim().isEmpty)) {
      return _skip(
        outputFormat: request.outputFormat,
        targetSampleRate: request.requestedSampleRate,
        targetBitDepth: request.requestedBitDepth,
        targetBitRateKbps: request.outputFormat == TranscodeOutputFormat.mp3
            ? request.mp3BitRateKbps
            : null,
        skipReasonKey: AppConstants.transcodeSkipNoOutputDirectory,
      );
    }

    if (!probeInfo.isLossless && !probeInfo.isLossy) {
      return _skip(
        outputFormat: request.outputFormat,
        targetSampleRate: request.requestedSampleRate,
        targetBitDepth: request.requestedBitDepth,
        targetBitRateKbps: request.outputFormat == TranscodeOutputFormat.mp3
            ? request.mp3BitRateKbps
            : null,
        skipReasonKey: AppConstants.transcodeSkipUnsupportedSourceFormat,
      );
    }

    if (request.outputFormat == TranscodeOutputFormat.mp3) {
      return _evaluateMp3(probeInfo: probeInfo, request: request);
    }

    if (!probeInfo.isLossless) {
      return _skip(
        outputFormat: request.outputFormat,
        targetSampleRate: request.requestedSampleRate,
        targetBitDepth: request.requestedBitDepth,
        targetBitRateKbps: null,
        skipReasonKey: AppConstants.transcodeSkipLossyToLossless,
      );
    }

    final requestedSampleRate = request.requestedSampleRate;
    final requestedBitDepth = request.requestedBitDepth!;
    final effectiveSampleRate =
        probeInfo.sampleRate != null &&
            probeInfo.sampleRate! < requestedSampleRate
        ? probeInfo.sampleRate!
        : requestedSampleRate;
    final effectiveBitDepth =
        probeInfo.bitDepth != null && probeInfo.bitDepth! < requestedBitDepth
        ? probeInfo.bitDepth!
        : requestedBitDepth;
    final requiresFormatChange =
        probeInfo.outputFormatEquivalent != request.outputFormat;
    final requiresSampleRateChange =
        probeInfo.sampleRate != null &&
        probeInfo.sampleRate! > effectiveSampleRate;
    final requiresBitDepthChange =
        probeInfo.bitDepth != null && probeInfo.bitDepth! > effectiveBitDepth;
    final isWithinTarget =
        probeInfo.sampleRate != null &&
        probeInfo.sampleRate! <= effectiveSampleRate &&
        probeInfo.bitDepth != null &&
        probeInfo.bitDepth! <= effectiveBitDepth;

    if (requiresSampleRateChange || requiresBitDepthChange) {
      return TranscodeDecision(
        shouldTranscode: true,
        outputFormat: request.outputFormat,
        targetSampleRate: effectiveSampleRate,
        targetBitDepth: effectiveBitDepth,
        targetBitRateKbps: null,
        requiresFormatChange: requiresFormatChange,
        requiresSampleRateChange: requiresSampleRateChange,
        requiresBitDepthChange: requiresBitDepthChange,
      );
    }

    if (requiresFormatChange && request.allowFormatOnlyConversion) {
      return TranscodeDecision(
        shouldTranscode: true,
        outputFormat: request.outputFormat,
        targetSampleRate: effectiveSampleRate,
        targetBitDepth: effectiveBitDepth,
        targetBitRateKbps: null,
        requiresFormatChange: true,
        requiresSampleRateChange: false,
        requiresBitDepthChange: false,
      );
    }

    if (isWithinTarget) {
      return _skip(
        outputFormat: request.outputFormat,
        targetSampleRate: effectiveSampleRate,
        targetBitDepth: effectiveBitDepth,
        targetBitRateKbps: null,
        skipReasonKey: AppConstants.transcodeSkipAlreadyCompliantLossless,
        requiresFormatChange: requiresFormatChange,
      );
    }

    return TranscodeDecision(
      shouldTranscode: true,
      outputFormat: request.outputFormat,
      targetSampleRate: effectiveSampleRate,
      targetBitDepth: effectiveBitDepth,
      targetBitRateKbps: null,
      requiresFormatChange: requiresFormatChange,
      requiresSampleRateChange: false,
      requiresBitDepthChange: false,
    );
  }

  TranscodeDecision _evaluateMp3({
    required AudioProbeInfo probeInfo,
    required TranscodeRequest request,
  }) {
    final requestedSampleRate = request.requestedSampleRate;
    final effectiveSampleRate =
        probeInfo.sampleRate != null &&
            probeInfo.sampleRate! < requestedSampleRate
        ? probeInfo.sampleRate!
        : requestedSampleRate;
    final requiresFormatChange =
        probeInfo.outputFormatEquivalent != TranscodeOutputFormat.mp3;
    final requiresSampleRateChange =
        probeInfo.sampleRate != null &&
        probeInfo.sampleRate! > effectiveSampleRate;
    final inputBitRateKbps = _normalizeBitRateKbps(probeInfo.bitRate);
    final isAlreadyCompliant =
        !requiresFormatChange &&
        probeInfo.sampleRate == effectiveSampleRate &&
        inputBitRateKbps != null &&
        inputBitRateKbps == request.mp3BitRateKbps;

    if (isAlreadyCompliant) {
      return _skip(
        outputFormat: TranscodeOutputFormat.mp3,
        targetSampleRate: effectiveSampleRate,
        targetBitDepth: null,
        targetBitRateKbps: request.mp3BitRateKbps,
        skipReasonKey: AppConstants.transcodeSkipAlreadyCompliantMp3,
      );
    }

    return TranscodeDecision(
      shouldTranscode: true,
      outputFormat: TranscodeOutputFormat.mp3,
      targetSampleRate: effectiveSampleRate,
      targetBitDepth: null,
      targetBitRateKbps: request.mp3BitRateKbps,
      requiresFormatChange: requiresFormatChange,
      requiresSampleRateChange: requiresSampleRateChange,
      requiresBitDepthChange: false,
    );
  }

  int? _normalizeBitRateKbps(int? bitRate) {
    if (bitRate == null || bitRate <= 0) return null;
    return (bitRate / 1000).round();
  }

  TranscodeDecision _skip({
    required TranscodeOutputFormat outputFormat,
    required int? targetSampleRate,
    required int? targetBitDepth,
    required int? targetBitRateKbps,
    required String skipReasonKey,
    bool requiresFormatChange = false,
  }) {
    return TranscodeDecision(
      shouldTranscode: false,
      skipReasonKey: skipReasonKey,
      outputFormat: outputFormat,
      targetSampleRate: targetSampleRate,
      targetBitDepth: targetBitDepth,
      targetBitRateKbps: targetBitRateKbps,
      requiresFormatChange: requiresFormatChange,
      requiresSampleRateChange: false,
      requiresBitDepthChange: false,
    );
  }
}
