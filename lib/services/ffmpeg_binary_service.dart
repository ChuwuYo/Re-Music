import 'dart:io';

import 'package:path/path.dart' as p;

import '../constants.dart';

class FfmpegBinaryPaths {
  final String ffmpegPath;
  final String ffprobePath;

  const FfmpegBinaryPaths({
    required this.ffmpegPath,
    required this.ffprobePath,
  });
}

class FfmpegBinaryService {
  const FfmpegBinaryService();

  FfmpegBinaryPaths? resolve() {
    final ffmpeg = _resolveBinary(AppConstants.ffmpegExecutableName);
    final ffprobe = _resolveBinary(AppConstants.ffprobeExecutableName);
    if (ffmpeg == null || ffprobe == null) {
      return null;
    }
    return FfmpegBinaryPaths(ffmpegPath: ffmpeg, ffprobePath: ffprobe);
  }

  String windowsBinaryFolderPath() {
    final exeDir = File(Platform.resolvedExecutable).parent.path;
    return p.join(
      exeDir,
      AppConstants.bundledToolsDirectory,
      AppConstants.bundledFfmpegDirectory,
      AppConstants.bundledWindowsDirectory,
    );
  }

  Future<bool> openWindowsDownloadPage() async {
    if (!Platform.isWindows) {
      return false;
    }
    final result = await Process.run('cmd', [
      '/c',
      'start',
      '',
      AppConstants.ffmpegWindowsDownloadUrl,
    ]);
    return result.exitCode == 0;
  }

  Future<bool> openWindowsBinaryFolder() async {
    if (!Platform.isWindows) {
      return false;
    }

    final folderPath = windowsBinaryFolderPath();
    await Directory(folderPath).create(recursive: true);

    final result = await Process.run('explorer', [folderPath]);
    return result.exitCode == 0;
  }

  String? _resolveBinary(String executableName) {
    for (final directory in _candidateDirectories()) {
      final candidate = p.join(directory, executableName);
      if (File(candidate).existsSync()) {
        return candidate;
      }
    }
    return null;
  }

  List<String> _candidateDirectories() {
    final exeDir = File(Platform.resolvedExecutable).parent.path;
    final currentDir = Directory.current.path;
    return [
      exeDir,
      p.join(
        exeDir,
        AppConstants.bundledToolsDirectory,
        AppConstants.bundledFfmpegDirectory,
        AppConstants.bundledWindowsDirectory,
      ),
      p.join(
        currentDir,
        AppConstants.bundledToolsDirectory,
        AppConstants.bundledFfmpegDirectory,
        AppConstants.bundledWindowsDirectory,
      ),
    ];
  }
}
