import 'dart:io';

import 'package:audio_metadata_reader/audio_metadata_reader.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:remusic/models/audio_file.dart';
import 'package:remusic/services/metadata_service.dart';

void main() {
  group('Artist semantics', () {
    test('namingArtist prefers track artist over album artist', () {
      final metadata = AudioMetadata(
        file: File('demo.mp3'),
        artist: 'Album Artist',
        title: 'Song',
      );
      final file = AudioFile(
        path: 'demo.mp3',
        extension: '.mp3',
        size: 1,
        modified: DateTime(2024, 1, 1),
        metadata: metadata,
        tagTrackArtist: 'Track Artist',
        tagAlbumArtist: 'Album Artist',
      );

      expect(file.trackArtist, 'Track Artist');
      expect(file.albumArtist, 'Album Artist');
      expect(file.namingArtist, 'Track Artist');
    });

    test(
      'namingArtist falls back to album artist when track artist is missing',
      () {
        final metadata = AudioMetadata(
          file: File('demo.mp3'),
          artist: 'Album Artist',
        );
        final file = AudioFile(
          path: 'demo.mp3',
          extension: '.mp3',
          size: 1,
          modified: DateTime(2024, 1, 1),
          metadata: metadata,
          tagAlbumArtist: 'Album Artist',
        );

        expect(file.trackArtist, '');
        expect(file.namingArtist, 'Album Artist');
      },
    );
  });

  test('formatNewFileName supports {albumArtist}', () {
    final newName = MetadataService.formatNewFileName(
      artist: '',
      albumArtist: 'Album Artist',
      title: 'Song',
      extension: '.mp3',
      pattern: '{albumArtist} - {title}',
      unknownArtist: 'Unknown artist',
      unknownTitle: 'Unknown title',
      unknownAlbum: 'Unknown album',
      untitledTrack: 'Untitled track',
      index: 1,
    );

    expect(newName, 'Album Artist - Song.mp3');
  });
}
