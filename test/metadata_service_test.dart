import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:audio_metadata_reader/audio_metadata_reader.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:remusic/models/audio_file.dart';
import 'package:remusic/services/artist_name_service.dart';
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

    test('formatNewFileName supports Windows multi-value text frames', () {
      final newName = MetadataService.formatNewFileName(
        artist: 'Artist A\u0000Artist B',
        title: 'Song',
        extension: '.mp3',
        pattern: '{artist} - {title}',
        unknownArtist: 'Unknown artist',
        unknownTitle: 'Unknown title',
        unknownAlbum: 'Unknown album',
        untitledTrack: 'Untitled track',
        artistSeparator: ';',
      );

      expect(newName, 'Artist A;Artist B - Song.mp3');
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

  test(
    'formatNewFileName splits artist by slash before sanitizing separators',
    () {
      final newName = MetadataService.formatNewFileName(
        artist: 'Artist A/Artist B',
        title: 'Song',
        extension: '.mp3',
        pattern: '{artist} - {title}',
        unknownArtist: 'Unknown artist',
        unknownTitle: 'Unknown title',
        unknownAlbum: 'Unknown album',
        untitledTrack: 'Untitled track',
        artistSeparator: ';',
      );

      expect(newName, 'Artist A;Artist B - Song.mp3');
    },
  );

  test(
    'formatNewFileName trims trailing artist delimiter after normalization',
    () {
      final newName = MetadataService.formatNewFileName(
        artist: 'Artist;',
        title: '',
        extension: '.mp3',
        pattern: '{artist}',
        unknownArtist: 'Unknown artist',
        unknownTitle: 'Unknown title',
        unknownAlbum: 'Unknown album',
        untitledTrack: 'Untitled track',
      );

      expect(newName, 'Artist.mp3');
    },
  );

  test('formatNewFileName recognizes all configured input separators', () {
    for (final rawArtist in [
      'Artist A_Artist B',
      'Artist A·Artist B',
      'Artist A、Artist B',
      'Artist A; Artist B',
    ]) {
      final newName = MetadataService.formatNewFileName(
        artist: rawArtist,
        title: 'Song',
        extension: '.mp3',
        pattern: '{artist} - {title}',
        unknownArtist: 'Unknown artist',
        unknownTitle: 'Unknown title',
        unknownAlbum: 'Unknown album',
        untitledTrack: 'Untitled track',
        artistSeparator: '·',
      );

      expect(newName, 'Artist A·Artist B - Song.mp3');
    }
  });

  test('AudioFile normalizes supported artist delimiters', () {
    final file = AudioFile(
      path: 'demo.mp3',
      extension: '.mp3',
      size: 1,
      modified: DateTime(2024, 1, 1),
      tagTrackArtist: 'Artist A·Artist B',
      tagAlbumArtist: 'Album A_Album B',
    );

    expect(file.trackArtist, 'Artist A; Artist B');
    expect(file.albumArtist, 'Album A; Album B');
  });

  test('AudioFile namingArtist falls back to normalized performers', () {
    final metadata = AudioMetadata(file: File('demo.mp3'), artist: '')
      ..performers.add('Artist A/Artist B');
    final file = AudioFile(
      path: 'demo.mp3',
      extension: '.mp3',
      size: 1,
      modified: DateTime(2024, 1, 1),
      metadata: metadata,
    );

    expect(file.namingArtist, 'Artist A; Artist B');
  });

  test('ArtistNameService splits Windows and custom multi-artist text', () {
    expect(ArtistNameService.splitArtists('Artist A\u0000Artist B'), [
      'Artist A',
      'Artist B',
    ]);
  });

  test('ArtistNameService keeps common band-name punctuation intact', () {
    expect(ArtistNameService.splitArtists('Simon & Garfunkel'), [
      'Simon & Garfunkel',
    ]);
    expect(ArtistNameService.splitArtists('Florence + The Machine'), [
      'Florence + The Machine',
    ]);
    expect(ArtistNameService.splitArtists('Tyler, The Creator'), [
      'Tyler, The Creator',
    ]);
    expect(ArtistNameService.splitArtists('Artist A feat. Artist B'), [
      'Artist A feat. Artist B',
    ]);
  });

  test('decodeId3TextFrameValues handles v2.4 unsynchronization flag', () {
    final values = MetadataService.decodeId3TextFrameValuesForTest(
      [0, 0x41, 0xFF, 0x00, 0x42],
      majorVersion: 4,
      formatFlags: 0x02,
    );

    expect(values, ['A\u00ffB']);
  });

  test('decodeId3TextFrameValues handles v2.4 data length indicator', () {
    final values = MetadataService.decodeId3TextFrameValuesForTest(
      [0, 0, 0, 3, 0, 65, 66],
      majorVersion: 4,
      formatFlags: 0x01,
    );

    expect(values, ['AB']);
  });

  test('parseVorbisCommentBlock keeps multi-value artist and album artist', () {
    Uint8List block(List<String> comments) {
      final bytes = BytesBuilder();
      final vendor = utf8.encode('ReMusic');
      bytes.add([vendor.length, 0, 0, 0]);
      bytes.add(vendor);
      bytes.add([comments.length, 0, 0, 0]);
      for (final comment in comments) {
        final encoded = utf8.encode(comment);
        bytes.add([
          encoded.length & 0xFF,
          (encoded.length >> 8) & 0xFF,
          (encoded.length >> 16) & 0xFF,
          (encoded.length >> 24) & 0xFF,
        ]);
        bytes.add(encoded);
      }
      return bytes.toBytes();
    }

    final parsed = MetadataService.parseVorbisCommentBlockForTest(
      block([
        'ARTIST=Artist A',
        'ARTIST=Artist B',
        'ALBUMARTIST=Album A',
        'ALBUMARTIST=Album B',
      ]),
    );

    expect(parsed['trackArtist'], ['Artist A', 'Artist B']);
    expect(parsed['albumArtist'], ['Album A', 'Album B']);
  });
}
