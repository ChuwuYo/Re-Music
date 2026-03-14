import 'dart:convert';
import 'dart:io';

import 'package:path/path.dart' as p;

import '../constants.dart';
import '../models/audio_probe_info.dart';

typedef ProbeCommandRunner =
    Future<String> Function(String executable, List<String> arguments);

class ProbeService {
  final String ffprobeExecutablePath;
  final ProbeCommandRunner _runner;

  ProbeService({
    required this.ffprobeExecutablePath,
    ProbeCommandRunner? runner,
  }) : _runner = runner ?? _defaultRunner;

  Future<AudioProbeInfo> probeFile(String filePath) async {
    final probeText = await _runner(ffprobeExecutablePath, [
      '-v',
      'error',
      '-select_streams',
      'a:0',
      '-show_entries',
      'stream=codec_name,sample_fmt,sample_rate,bits_per_raw_sample,bits_per_sample,bit_rate,duration:format=bit_rate,duration',
      '-of',
      'default=noprint_wrappers=1:nokey=0',
      filePath,
    ]);
    try {
      // Writer-aware parsing: prefer explicit format detection over
      // exception-driven fallback for predictable control flow.
      return _looksLikeJson(probeText)
          ? parseProbeOutput(filePath, probeText)
          : parseProbeKeyValueOutput(filePath, probeText);
    } catch (error) {
      _appendProbeErrorLog(
        filePath: filePath,
        stage: 'parse',
        message: '$error',
        rawOutput: probeText,
      );
      rethrow;
    }
  }

  static bool _looksLikeJson(String output) {
    final trimmed = output.trimLeft();
    return trimmed.startsWith('{') || trimmed.startsWith('[');
  }

  AudioProbeInfo parseProbeKeyValueOutput(String filePath, String text) {
    final values = <String, String>{};
    for (final rawLine in text.split(RegExp(r'\r?\n'))) {
      final line = rawLine.trim();
      if (line.isEmpty) continue;
      final separatorIndex = line.indexOf('=');
      if (separatorIndex <= 0) continue;
      final key = line.substring(0, separatorIndex).trim();
      final value = line.substring(separatorIndex + 1).trim();
      if (key.isEmpty) continue;
      values[key] = value;
    }

    if (values.isEmpty) {
      throw const FormatException(
        'No key-value fields found in ffprobe output',
      );
    }

    final extension = p.extension(filePath).toLowerCase().replaceAll('.', '');
    final codecName = (values['codec_name'] ?? '').toLowerCase();
    final sampleFormat = values['sample_fmt'];
    final sampleRate = _parseIntField(values['sample_rate']);
    final bitRate = _parseIntField(values['bit_rate']);
    final durationSeconds = _parseDoubleField(values['duration']);
    final bitDepth = _resolveBitDepth(
      bitsPerRawSample: values['bits_per_raw_sample'],
      bitsPerSample: values['bits_per_sample'],
      sampleFormat: sampleFormat,
    );

    return AudioProbeInfo(
      path: filePath,
      extension: extension,
      codecName: codecName,
      sampleFormat: sampleFormat,
      kind: _resolveKind(extension: extension, codecName: codecName),
      sampleRate: sampleRate,
      bitDepth: bitDepth,
      bitRate: bitRate,
      durationSeconds: durationSeconds,
    );
  }

  AudioProbeInfo parseProbeOutput(String filePath, String jsonText) {
    final sanitizedText = _sanitizeProbeJson(jsonText);
    final decoded = jsonDecode(sanitizedText);
    if (decoded is! Map<String, dynamic>) {
      throw const FormatException('Invalid ffprobe output');
    }

    final streams = decoded['streams'];
    final format = decoded['format'];
    if (streams is! List) {
      throw const FormatException('Missing streams in ffprobe output');
    }

    Map<String, dynamic>? audioStream;
    for (final candidate in streams) {
      if (candidate is Map<String, dynamic> &&
          candidate['codec_type'] == 'audio') {
        audioStream = candidate;
        break;
      }
    }
    if (audioStream == null) {
      throw const FormatException('No audio stream found in ffprobe output');
    }

    final extension = p.extension(filePath).toLowerCase().replaceAll('.', '');
    final codecName = (audioStream['codec_name'] as String? ?? '')
        .toLowerCase();
    final sampleFormat = audioStream['sample_fmt'] as String?;
    final sampleRate = _parseIntField(audioStream['sample_rate']);
    final bitRate = _parseIntField(
      audioStream['bit_rate'] ??
          (format is Map<String, dynamic> ? format['bit_rate'] : null),
    );
    final durationSeconds = _parseDoubleField(
      audioStream['duration'] ??
          (format is Map<String, dynamic> ? format['duration'] : null),
    );
    final bitDepth = _resolveBitDepth(
      bitsPerRawSample: audioStream['bits_per_raw_sample'],
      bitsPerSample: audioStream['bits_per_sample'],
      sampleFormat: sampleFormat,
    );

    return AudioProbeInfo(
      path: filePath,
      extension: extension,
      codecName: codecName,
      sampleFormat: sampleFormat,
      kind: _resolveKind(extension: extension, codecName: codecName),
      sampleRate: sampleRate,
      bitDepth: bitDepth,
      bitRate: bitRate,
      durationSeconds: durationSeconds,
    );
  }

  static Future<String> _defaultRunner(
    String executable,
    List<String> arguments,
  ) async {
    final result = await Process.run(
      executable,
      arguments,
      stdoutEncoding: null,
      stderrEncoding: null,
    );
    final stdoutText = _decodeProcessOutput(result.stdout);
    final stderrText = _decodeProcessOutput(result.stderr).trim();
    if (result.exitCode != 0) {
      final filePath = arguments.isNotEmpty ? arguments.last : '<unknown>';
      _appendProbeErrorLog(
        filePath: filePath,
        stage: 'ffprobe',
        message: 'Exit code ${result.exitCode}',
        rawOutput: stderrText,
      );
      throw ProcessException(
        executable,
        arguments,
        stderrText,
        result.exitCode,
      );
    }
    return stdoutText;
  }

  static String _decodeProcessOutput(Object? raw) {
    if (raw == null) return '';
    if (raw is String) return raw;
    if (raw is List<int>) {
      // ffprobe/ffmpeg may emit non-UTF8 bytes on localized Windows systems.
      return utf8.decode(raw, allowMalformed: true);
    }
    return '$raw';
  }

  static String _sanitizeProbeJson(String jsonText) {
    final withoutControlChars = jsonText.replaceAll(RegExp(r'[\x00-\x1F]'), '');

    final withoutTags = withoutControlChars.replaceAll(
      RegExp(r'"tags"\s*:\s*\{[\s\S]*?\}\s*,?'),
      '',
    );

    final repairedEscapes = withoutTags.replaceAllMapped(
      RegExp(r'\\(?!["\\/bfnrtu])'),
      (_) => r'\\\\',
    );

    // Remove filename to avoid both privacy leakage and invalid escape issues from raw paths.
    final withoutFilename = repairedEscapes.replaceAll(
      RegExp(r'"filename"\s*:\s*"(?:\\.|[^"\\])*"\s*,?'),
      '',
    );

    return withoutFilename
        .replaceAll(RegExp(r',\s*([}\]])'), r'$1')
        .replaceAll(RegExp(r'([\[{])\s*,'), r'$1');
  }

  static void _appendProbeErrorLog({
    required String filePath,
    required String stage,
    required String message,
    required String rawOutput,
  }) {
    try {
      final logDir = Directory(
        p.join(Directory.current.path, AppConstants.logsDirectoryName),
      );
      if (!logDir.existsSync()) {
        logDir.createSync(recursive: true);
      }
      final logFile = File(
        p.join(logDir.path, AppConstants.probeErrorLogFileName),
      );
      final timestamp = DateTime.now().toIso8601String();
      final preview = rawOutput.length > 4000
          ? '${rawOutput.substring(0, 4000)}\n...[truncated]'
          : rawOutput;
      final content = StringBuffer()
        ..writeln('[$timestamp] stage=$stage')
        ..writeln('file=$filePath')
        ..writeln('message=$message')
        ..writeln('output=')
        ..writeln(preview)
        ..writeln('---');
      logFile.writeAsStringSync(content.toString(), mode: FileMode.append);
    } catch (_) {
      // Keep probe flow resilient; logging must never break user flow.
    }
  }

  static void resetProbeErrorLog() {
    try {
      final logFile = File(
        p.join(
          Directory.current.path,
          AppConstants.logsDirectoryName,
          AppConstants.probeErrorLogFileName,
        ),
      );
      if (logFile.existsSync()) {
        logFile.writeAsStringSync('');
      }
    } catch (_) {
      // Best effort only.
    }
  }

  static int? _parseIntField(Object? raw) {
    return switch (raw) {
      int value => value,
      num value => value.round(),
      String value => int.tryParse(value),
      _ => null,
    };
  }

  static double? _parseDoubleField(Object? raw) {
    return switch (raw) {
      double value => value,
      num value => value.toDouble(),
      String value => double.tryParse(value),
      _ => null,
    };
  }

  static int? _resolveBitDepth({
    required Object? bitsPerRawSample,
    required Object? bitsPerSample,
    required String? sampleFormat,
  }) {
    final direct = _parseIntField(bitsPerRawSample);
    if (direct != null && direct > 0) return direct;

    final fallbackBitsPerSample = _parseIntField(bitsPerSample);
    if (fallbackBitsPerSample != null && fallbackBitsPerSample > 0) {
      return fallbackBitsPerSample;
    }

    final normalized = (sampleFormat ?? '').toLowerCase();
    return switch (normalized) {
      'u8' || 'u8p' => 8,
      's16' || 's16p' => 16,
      's24' || 's24p' => 24,
      // Ambiguous without bits_per_* metadata: may be 24-bit-in-32-container or true 32-bit.
      's32' || 's32p' => null,
      'flt' || 'fltp' => 32,
      'dbl' || 'dblp' => 64,
      _ => null,
    };
  }

  static AudioEncodingKind _resolveKind({
    required String extension,
    required String codecName,
  }) {
    if (codecName == 'flac') return AudioEncodingKind.flac;
    if (codecName == 'alac') return AudioEncodingKind.alac;
    if (codecName == 'mp3') return AudioEncodingKind.mp3;
    if (codecName == 'aac') return AudioEncodingKind.aac;
    if (codecName == 'opus') return AudioEncodingKind.opus;
    if (codecName == 'vorbis') return AudioEncodingKind.ogg;
    if (codecName.startsWith('wm')) return AudioEncodingKind.wma;
    if (codecName.startsWith('pcm_')) return AudioEncodingKind.wav;

    return switch (extension) {
      'flac' => AudioEncodingKind.flac,
      'wav' => AudioEncodingKind.wav,
      'm4a' => AudioEncodingKind.aac,
      'aac' => AudioEncodingKind.aac,
      'ogg' => AudioEncodingKind.ogg,
      'opus' => AudioEncodingKind.opus,
      'wma' => AudioEncodingKind.wma,
      'mp3' => AudioEncodingKind.mp3,
      _ => AudioEncodingKind.unknown,
    };
  }
}
