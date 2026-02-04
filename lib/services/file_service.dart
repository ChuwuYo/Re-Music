import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:path/path.dart' as p;

class FileService {
  static const supportedExtensions = [
    'mp3', 'flac', 'ogg', 'm4a', 'aac', 'wma', 'wv', 'opus', 'dsf', 'dff'
  ];

  static Future<List<String>> pickFiles() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: supportedExtensions,
      allowMultiple: true,
    );
    return result?.paths.whereType<String>().toList() ?? [];
  }

  static Future<String?> pickDirectory() async {
    return await FilePicker.platform.getDirectoryPath();
  }

  static Future<bool> isDirectory(String path) async {
    return await FileSystemEntity.isDirectory(path);
  }

  static Future<List<String>> scanDirectory(String dirPath) async {
    final dir = Directory(dirPath);
    final files = <String>[];
    
    if (await dir.exists()) {
      await for (final entity in dir.list(recursive: true, followLinks: false)) {
        if (entity is File) {
          final ext = p.extension(entity.path).toLowerCase().replaceAll('.', '');
          if (supportedExtensions.contains(ext)) {
            files.add(entity.path);
          }
        }
      }
    }
    return files;
  }

  static Future<bool> renameFile(String oldPath, String newName) async {
    try {
      final file = File(oldPath);
      final dir = p.dirname(oldPath);
      final newPath = p.join(dir, newName);
      
      if (oldPath == newPath) return true;
      
      await file.rename(newPath);
      return true;
    } catch (e) {
      debugPrint('Error renaming file $oldPath: $e');
      return false;
    }
  }
}
