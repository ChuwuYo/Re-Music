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
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: allowedExtensions ?? supportedExtensions,
      allowMultiple: true,
    );
    return result?.paths.whereType<String>().toList() ?? [];
  }

  static Future<String?> pickDirectory() async {
    return FilePicker.platform.getDirectoryPath();
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
    final backupPath = '$targetPath.bak';
    final backupFile = File(backupPath);

    if (!await tempFile.exists()) {
      throw FileSystemException('Temporary file not found', tempPath);
    }

    if (await backupFile.exists()) {
      await backupFile.delete();
    }

    if (await targetFile.exists()) {
      await targetFile.rename(backupPath);
    }

    try {
      await tempFile.rename(targetPath);
      if (await backupFile.exists()) {
        await backupFile.delete();
      }
    } catch (error) {
      if (await backupFile.exists()) {
        if (await targetFile.exists()) {
          await targetFile.delete();
        }
        await backupFile.rename(targetPath);
      }
      rethrow;
    }
  }
}
