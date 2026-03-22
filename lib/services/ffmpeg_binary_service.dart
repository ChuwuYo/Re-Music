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
    try {
      final result = await Process.run('cmd', [
        '/c',
        'start',
        '',
        AppConstants.ffmpegWindowsDownloadUrl,
      ]);
      return result.exitCode == 0;
    } on Exception {
      return false;
    }
  }

  Future<bool> openWindowsBinaryFolder() async {
    if (!Platform.isWindows) {
      return false;
    }
    try {
      final primaryPath = windowsBinaryFolderPath();
      String folderPath;
      try {
        await Directory(primaryPath).create(recursive: true);
        folderPath = primaryPath;
      } on FileSystemException {
        // Executable directory may be read-only in installed Windows builds;
        // fall back to a user-writable application data directory.
        final localAppData = Platform.environment['LOCALAPPDATA'];
        if (localAppData != null && localAppData.isNotEmpty) {
          final fallbackPath = p.join(
            localAppData,
            AppConstants.appName,
            AppConstants.bundledToolsDirectory,
            AppConstants.bundledFfmpegDirectory,
            AppConstants.bundledWindowsDirectory,
          );
          await Directory(fallbackPath).create(recursive: true);
          folderPath = fallbackPath;
        } else {
          folderPath = primaryPath;
        }
      }

      final result = await Process.run('explorer', [folderPath]);
      // Explorer commonly returns exit code 1 even on success.
      return result.exitCode == 0 || result.exitCode == 1;
    } on Exception {
      return false;
    }
  }

  String? _resolveBinary(String executableName) {
    for (final directory in _candidateDirectories()) {
      final candidate = p.join(directory, executableName);
      if (File(candidate).existsSync()) {
        return candidate;
      }
    }
    return _resolveFromSystemPath(executableName);
  }

  String? _resolveFromSystemPath(String executableName) {
    try {
      final command = Platform.isWindows ? 'where' : 'which';
      final result = Process.runSync(command, [executableName]);
      if (result.exitCode == 0) {
        final firstLine = (result.stdout as String)
            .trim()
            .split('\n')
            .first
            .trim();
        if (firstLine.isNotEmpty && File(firstLine).existsSync()) {
          return firstLine;
        }
      }
    } catch (_) {
      // Fallback lookup is best-effort.
    }
    return null;
  }

  List<String> _candidateDirectories() {
    final exeDir = File(Platform.resolvedExecutable).parent.path;
    final currentDir = Directory.current.path;
    final dirs = [
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
    if (Platform.isWindows) {
      final localAppData = Platform.environment['LOCALAPPDATA'];
      if (localAppData != null && localAppData.isNotEmpty) {
        dirs.add(
          p.join(
            localAppData,
            AppConstants.appName,
            AppConstants.bundledToolsDirectory,
            AppConstants.bundledFfmpegDirectory,
            AppConstants.bundledWindowsDirectory,
          ),
        );
      }
    }
    return dirs;
  }
}
