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
}
