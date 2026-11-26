import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:path/path.dart' as p;

import '../constants.dart';

class FileService {
  static const supportedExtensions = AppConstants.supportedAudioExtensions;

  static Future<List<String>> pickFiles({
    List<String>? allowedExtensions,
  }) async {
    final files = await FilePicker.pickFiles(
      type: FileType.custom,
      allowedExtensions: allowedExtensions ?? supportedExtensions,
    );
    return files.map((f) => f.path).whereType<String>().toList();
  }

  static Future<String?> pickDirectory() async {
    return FilePicker.getDirectoryPath();
  }

  static Future<bool> isDirectory(String path) async {
    return FileSystemEntity.isDirectory(path);
  }

  static Future<List<String>> scanDirectory(
    String dirPath, {
    List<String>? allowedExtensions,
  }) async {
    final dir = Directory(dirPath);
    final files = <String>[];
    final whitelist = (allowedExtensions ?? supportedExtensions)
        .map((extension) => extension.toLowerCase())
        .toSet();

    if (await dir.exists()) {
      await for (final entity in dir.list(
        recursive: true,
        followLinks: false,
      )) {
        if (entity is! File) continue;
        final ext = p.extension(entity.path).toLowerCase().replaceAll('.', '');
        if (whitelist.contains(ext)) {
          files.add(entity.path);
        }
      }
    }
    return files;
  }

  static Future<bool> renameFile(String oldPath, String newName) async {
    try {
      final file = File(oldPath);
      final dir = p.dirname(oldPath);
      final safeName = p.basename(newName.trim());
      if (safeName.isEmpty || safeName == '.' || safeName == '..') return false;

      final newPath = p.join(dir, safeName);
      if (oldPath == newPath) return true;

      final targetType = await FileSystemEntity.type(newPath);
      if (targetType != FileSystemEntityType.notFound) {
        final sameFile = await FileSystemEntity.identical(oldPath, newPath);
        if (!sameFile) return false;
        // Handle case-only renames: move aside first so the target name frees up.
        final tempPath = p.join(
          dir,
          '.$safeName.${DateTime.now().microsecondsSinceEpoch}.tmp',
        );
        await file.rename(tempPath);
        try {
          await File(tempPath).rename(newPath);
        } catch (_) {
          await File(tempPath).rename(oldPath);
          rethrow;
        }
        return true;
      }

      await file.rename(newPath);
      return true;
    } catch (e) {
      debugPrint('Error renaming file $oldPath: $e');
      return false;
    }
  }

  static Future<void> replaceFileAtomically(
    String tempPath,
    String targetPath,
  ) async {
    final tempFile = File(tempPath);
    final targetFile = File(targetPath);
    File? backupFile;

    if (!await tempFile.exists()) {
      throw FileSystemException('Temporary file not found', tempPath);
    }

    if (await targetFile.exists()) {
      final backupPath = await _nextAvailableBackupPath(targetPath);
      backupFile = File(backupPath);
      await targetFile.rename(backupPath);
    }

    try {
      await tempFile.rename(targetPath);
      if (backupFile != null && await backupFile.exists()) {
        await backupFile.delete();
      }
    } catch (error) {
      if (backupFile != null && await backupFile.exists()) {
        if (await targetFile.exists()) {
          await targetFile.delete();
        }
        await backupFile.rename(targetPath);
      }
      rethrow;
    }
  }

  static Future<String> _nextAvailableBackupPath(String targetPath) async {
    final base = '$targetPath.bak';
    var candidate = base;
    var index = 2;
    while (await File(candidate).exists()) {
      candidate = '$base.$index';
      index++;
    }
    return candidate;
  }
}
