import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:path/path.dart' as p;
import 'package:remusic/services/file_service.dart';

void main() {
  test(
    'renameFile strips directory components and keeps file in original dir',
    () async {
      final dir = await Directory.systemTemp.createTemp('remusic_test_');
      try {
        final oldPath = p.join(dir.path, 'a.txt');
        await File(oldPath).writeAsString('x');

        final ok = await FileService.renameFile(oldPath, '..\\evil.txt');
        expect(ok, isTrue);

        final expectedNewPath = p.join(dir.path, 'evil.txt');
        expect(await File(expectedNewPath).exists(), isTrue);
        expect(await File(oldPath).exists(), isFalse);
      } finally {
        await dir.delete(recursive: true);
      }
    },
  );

  test('renameFile rejects empty/dot names', () async {
    final dir = await Directory.systemTemp.createTemp('remusic_test_');
    try {
      final oldPath = p.join(dir.path, 'a.txt');
      await File(oldPath).writeAsString('x');

      for (final bad in [' ', '', '.', '..', '  ..  ']) {
        final ok = await FileService.renameFile(oldPath, bad);
        expect(ok, isFalse);
        expect(await File(oldPath).exists(), isTrue);
      }
    } finally {
      await dir.delete(recursive: true);
    }
  });

  test('renameFile returns true when the target path is unchanged', () async {
    final dir = await Directory.systemTemp.createTemp('remusic_test_');
    try {
      final oldPath = p.join(dir.path, 'a.txt');
      await File(oldPath).writeAsString('x');

      final ok = await FileService.renameFile(oldPath, 'a.txt');
      expect(ok, isTrue);
      expect(await File(oldPath).exists(), isTrue);
    } finally {
      await dir.delete(recursive: true);
    }
  });

  test('replaceFileAtomically keeps unrelated existing .bak file', () async {
    final dir = await Directory.systemTemp.createTemp('remusic_test_');
    try {
      final targetPath = p.join(dir.path, 'song.flac');
      final tempPath = p.join(dir.path, 'song.tmp.flac');
      final existingBackupPath = '$targetPath.bak';

      await File(targetPath).writeAsString('original');
      await File(tempPath).writeAsString('new-content');
      await File(existingBackupPath).writeAsString('do-not-touch');

      await FileService.replaceFileAtomically(tempPath, targetPath);

      expect(await File(targetPath).readAsString(), 'new-content');
      expect(await File(existingBackupPath).readAsString(), 'do-not-touch');
    } finally {
      await dir.delete(recursive: true);
    }
  });

  test('renameFile refuses to overwrite an existing different file', () async {
    final dir = await Directory.systemTemp.createTemp('remusic_test_');
    try {
      final aPath = p.join(dir.path, 'a.mp3');
      final bPath = p.join(dir.path, 'b.mp3');
      await File(aPath).writeAsString('AAA');
      await File(bPath).writeAsString('BBB');

      final ok = await FileService.renameFile(aPath, 'b.mp3');
      expect(ok, isFalse);
      expect(await File(aPath).readAsString(), 'AAA');
      expect(await File(bPath).readAsString(), 'BBB');
    } finally {
      await dir.delete(recursive: true);
    }
  });

  test('renameFile handles case-only renames', () async {
    final dir = await Directory.systemTemp.createTemp('remusic_test_');
    try {
      final oldPath = p.join(dir.path, 'a.mp3');
      await File(oldPath).writeAsString('AAA');

      final ok = await FileService.renameFile(oldPath, 'A.mp3');
      expect(ok, isTrue);
      expect(await File(p.join(dir.path, 'A.mp3')).readAsString(), 'AAA');

      final tempFiles = dir
          .listSync()
          .where((e) => e.path.endsWith('.tmp'))
          .toList();
      expect(tempFiles, isEmpty);
    } finally {
      await dir.delete(recursive: true);
    }
  });
}
