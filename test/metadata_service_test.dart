import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:audio_metadata_reader/audio_metadata_reader.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:remusic/constants.dart';
import 'package:remusic/models/audio_file.dart';
import 'package:remusic/services/artist_name_service.dart';
import 'package:remusic/services/metadata_service.dart';
import 'package:remusic/services/mp3_artist_tag_parser.dart';

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

  test(
    'formatNewFileName preserves current name when matching any allowed separator',
    () {
      // 1. Matches ';'
      final nameWithSemicolon = MetadataService.formatNewFileName(
        artist: 'Artist A; Artist B',
        title: 'Song',
        extension: '.mp3',
        pattern: '{artist} - {title}',
        unknownArtist: 'Unknown artist',
        unknownTitle: 'Unknown title',
        unknownAlbum: 'Unknown album',
        untitledTrack: 'Untitled track',
        allowedArtistSeparators: ['_', ';', '、'],
        currentFileName: 'Artist A;Artist B - Song.mp3',
      );
      expect(nameWithSemicolon, 'Artist A;Artist B - Song.mp3');

      // 2. Matches '、'
      final nameWithDunhao = MetadataService.formatNewFileName(
        artist: 'Artist A; Artist B',
        title: 'Song',
        extension: '.mp3',
        pattern: '{artist} - {title}',
        unknownArtist: 'Unknown artist',
        unknownTitle: 'Unknown title',
        unknownAlbum: 'Unknown album',
        untitledTrack: 'Untitled track',
        allowedArtistSeparators: ['_', ';', '、'],
        currentFileName: 'Artist A、Artist B - Song.mp3',
      );
      expect(nameWithDunhao, 'Artist A、Artist B - Song.mp3');

      // 3. Does not match any allowed separator (e.g. used '/'), falls back to primary allowed separator '_'
      final nameNeedsRename = MetadataService.formatNewFileName(
        artist: 'Artist A; Artist B',
        title: 'Song',
        extension: '.mp3',
        pattern: '{artist} - {title}',
        unknownArtist: 'Unknown artist',
        unknownTitle: 'Unknown title',
        unknownAlbum: 'Unknown album',
        untitledTrack: 'Untitled track',
        allowedArtistSeparators: ['_', ';', '、'],
        currentFileName: 'Artist A/Artist B - Song.mp3',
      );
      expect(nameNeedsRename, 'Artist A_Artist B - Song.mp3');
    },
  );

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

  test('decodeId3TextFrameValues returns empty for encrypted frames', () {
    // ID3v2.4 encryption flag (0x04)
    final v4Encrypted = MetadataService.decodeId3TextFrameValuesForTest(
      [0, 65, 66],
      majorVersion: 4,
      formatFlags: 0x04,
    );
    expect(v4Encrypted, isEmpty);

    // ID3v2.3 encryption flag (0x40)
    final v3Encrypted = MetadataService.decodeId3TextFrameValuesForTest(
      [0, 65, 66],
      majorVersion: 3,
      formatFlags: 0x40,
    );
    expect(v3Encrypted, isEmpty);
  });

  test(
    'decodeId3TextFrameValues removes unsynchronization before decompression in correct order',
    () {
      // Create raw text payload: encoding 0 + text
      final rawText = [0, ...latin1.encode('UnsyncCompressedArtist')];
      final compressed = zlib.encode(rawText);

      // Apply unsynchronization to compressed bytes (insert 0x00 after any 0xFF)
      final unsynced = <int>[];
      for (final b in compressed) {
        unsynced.add(b);
        if (b == 0xFF) {
          unsynced.add(0x00);
        }
      }

      // ID3v2.3 formatFlags 0x80 (compression) with 4-byte uncompressed size header + tagUnsynchronization true
      final v3Payload = [
        (rawText.length >> 24) & 0xFF,
        (rawText.length >> 16) & 0xFF,
        (rawText.length >> 8) & 0xFF,
        rawText.length & 0xFF,
        ...unsynced,
      ];

      final values = MetadataService.decodeId3TextFrameValuesForTest(
        v3Payload,
        majorVersion: 3,
        formatFlags: 0x80,
        tagUnsynchronization: true,
      );

      expect(values, ['UnsyncCompressedArtist']);
    },
  );

  test(
    'Mp3ArtistTagParser skips ID3v2.3 extended header with 4-byte size adjustment',
    () async {
      final dir = await Directory.systemTemp.createTemp('remusic_id3_ext_');
      try {
        final file = File('${dir.path}/test.mp3');
        final builder = BytesBuilder();

        // Frame data to write
        final text = [0, ...latin1.encode('Pink Floyd')];

        // Frame header (10 bytes): 'TPE1' + 4 bytes size + 2 bytes flags
        final frameBytes = [
          0x54, 0x50, 0x45, 0x31, // TPE1
          0, 0, 0, text.length, // size
          0, 0, // flags
          ...text,
        ];

        // Extended header in ID3v2.3:
        // 4 bytes size: 6 (size of subsequent data, excluding 4 bytes length)
        // 2 bytes flags: 0, 0
        // 4 bytes padding: 0, 0, 0, 0
        final extHeader = [0, 0, 0, 6, 0, 0, 0, 0, 0, 0]; // 10 bytes total

        final tagDataSize = extHeader.length + frameBytes.length;

        // ID3v2.3 header (10 bytes): 'ID3', v2.3, flags 0x40 (extended header), syncsafe size
        builder.add([
          0x49, 0x44, 0x33, // 'ID3'
          3, 0, // major 3, revision 0
          0x40, // extended header flag
          (tagDataSize >> 21) & 0x7F,
          (tagDataSize >> 14) & 0x7F,
          (tagDataSize >> 7) & 0x7F,
          tagDataSize & 0x7F,
        ]);

        builder.add(extHeader);
        builder.add(frameBytes);

        file.writeAsBytesSync(builder.toBytes());

        final parsed = Mp3ArtistTagParser.readArtists(file.path);
        expect(parsed[AppConstants.tagArtistTrackKey], ['Pink Floyd']);
      } finally {
        await dir.delete(recursive: true);
      }
    },
  );

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

  test(
    'parseVorbisCommentBlock handles invalid UTF-8 gracefully without dropping all artists',
    () {
      final bytes = BytesBuilder();
      final vendor = utf8.encode('ReMusic');
      bytes.add([vendor.length, 0, 0, 0]);
      bytes.add(vendor);
      bytes.add([2, 0, 0, 0]); // 2 comments

      // Comment 1: invalid UTF-8 sequence [0xFF, 0xFE] in artist name
      final invalidComment = [
        ...utf8.encode('ARTIST=ValidPrefix'),
        0xFF,
        0xFE,
        ...utf8.encode('Suffix'),
      ];
      bytes.add([
        invalidComment.length & 0xFF,
        (invalidComment.length >> 8) & 0xFF,
        (invalidComment.length >> 16) & 0xFF,
        (invalidComment.length >> 24) & 0xFF,
      ]);
      bytes.add(invalidComment);

      // Comment 2: standard second artist
      final normalComment = utf8.encode('ARTIST=Second Artist');
      bytes.add([
        normalComment.length & 0xFF,
        (normalComment.length >> 8) & 0xFF,
        (normalComment.length >> 16) & 0xFF,
        (normalComment.length >> 24) & 0xFF,
      ]);
      bytes.add(normalComment);

      final parsed = MetadataService.parseVorbisCommentBlockForTest(
        bytes.toBytes(),
      );

      // Should not throw FormatException and should successfully retain artists
      expect(parsed['trackArtist'], contains('Second Artist'));
      expect(parsed['trackArtist']?.length, 2);
    },
  );
}
