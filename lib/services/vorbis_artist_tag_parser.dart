import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';

import '../constants.dart';
import 'artist_name_service.dart';

class _OggPageData {
  final Uint8List data;
  final int headerType;

  const _OggPageData({required this.data, required this.headerType});
}

class VorbisArtistTagParser {
  VorbisArtistTagParser._();

  static const List<int> _vorbisCommentPrefix = [
    0x03,
    0x76,
    0x6F,
    0x72,
    0x62,
    0x69,
    0x73,
  ];

  static Map<String, List<String>> readStructuredArtists(String filePath) {
    return readArtists(filePath);
  }

  static Map<String, List<String>> readArtists(String filePath) {
    final file = File(filePath);
    if (!file.existsSync()) {
      return _emptyArtistMap();
    }

    final reader = file.openSync();
    try {
      final signature = reader.readSync(4);
      if (signature.length < 4) {
        return _emptyArtistMap();
      }

      final marker = String.fromCharCodes(signature);
      if (marker == 'fLaC') {
        return _readFlacVorbisArtists(reader);
      }
      if (marker == 'OggS') {
        reader.setPositionSync(0);
        return _readOggVorbisArtists(reader);
      }
    } catch (e) {
      debugPrint('Error reading Vorbis artists for $filePath: $e');
    } finally {
      reader.closeSync();
    }

    return _emptyArtistMap();
  }

  static Map<String, List<String>> parseCommentBlockForTest(
    Uint8List bytes, {
    int headerOffset = 0,
  }) {
    return _parseVorbisCommentBlock(bytes, headerOffset: headerOffset);
  }

  static Map<String, List<String>> _readFlacVorbisArtists(
    RandomAccessFile reader,
  ) {
    while (true) {
      final header = reader.readSync(4);
      if (header.length < 4) {
        break;
      }

      final isLastBlock = (header[0] & 0x80) != 0;
      final blockType = header[0] & 0x7F;
      final blockLength = header[3] | (header[2] << 8) | (header[1] << 16);

      if (blockType == 4) {
        final bytes = reader.readSync(blockLength);
        return _parseVorbisCommentBlock(bytes);
      }

      reader.setPositionSync(reader.positionSync() + blockLength);
      if (isLastBlock) {
        break;
      }
    }

    return _emptyArtistMap();
  }

  static Map<String, List<String>> _readOggVorbisArtists(
    RandomAccessFile reader,
  ) {
    while (true) {
      final page = _readOggPage(reader);
      if (page == null) {
        break;
      }

      final content = page.data;
      if (content.length >= 8 &&
          String.fromCharCodes(content.sublist(0, 8)) == 'OpusTags') {
        return _parseVorbisCommentBlock(
          content,
          headerOffset: 8,
          readAdditionalData: () => _readOggPage(reader)?.data,
        );
      }

      if (content.length >= _vorbisCommentPrefix.length &&
          listEquals(
            content.sublist(0, _vorbisCommentPrefix.length),
            _vorbisCommentPrefix,
          )) {
        return _parseVorbisCommentBlock(
          content,
          headerOffset: 7,
          readAdditionalData: () => _readOggPage(reader)?.data,
        );
      }

      if ((page.headerType & 0x04) != 0) {
        break;
      }
    }

    return _emptyArtistMap();
  }

  static _OggPageData? _readOggPage(RandomAccessFile reader) {
    final header = reader.readSync(27);
    if (header.length < 27) return null;

    if (String.fromCharCodes(header.sublist(0, 4)) != 'OggS') {
      return null;
    }

    final headerType = header[5];
    final segmentCount = header[26];
    final segmentSizes = reader.readSync(segmentCount);
    if (segmentSizes.length < segmentCount) return null;

    final data = <int>[];
    for (final size in segmentSizes) {
      final segment = reader.readSync(size);
      if (segment.length < size) return null;
      data.addAll(segment);
    }

    return _OggPageData(data: Uint8List.fromList(data), headerType: headerType);
  }

  static Map<String, List<String>> _parseVorbisCommentBlock(
    Uint8List bytes, {
    int headerOffset = 0,
    Uint8List? Function()? readAdditionalData,
  }) {
    final data = List<int>.from(bytes.sublist(headerOffset));
    var offset = 0;

    bool ensureLength(int length) {
      while (data.length - offset < length) {
        final nextChunk = readAdditionalData?.call();
        if (nextChunk == null || nextChunk.isEmpty) {
          return false;
        }
        data.addAll(nextChunk);
      }
      return true;
    }

    if (!ensureLength(4)) {
      return _emptyArtistMap();
    }

    final vendorLength = _decodeLittleEndianInt(
      data.sublist(offset, offset + 4),
    );
    offset += 4;
    if (!ensureLength(vendorLength + 4)) {
      return _emptyArtistMap();
    }

    offset += vendorLength;
    final commentCount = _decodeLittleEndianInt(
      data.sublist(offset, offset + 4),
    );
    offset += 4;

    final trackArtists = <String>[];
    final albumArtists = <String>[];

    for (var index = 0; index < commentCount; index++) {
      if (!ensureLength(4)) break;
      final commentLength = _decodeLittleEndianInt(
        data.sublist(offset, offset + 4),
      );
      offset += 4;
      if (!ensureLength(commentLength)) break;

      final comment = utf8.decode(data.sublist(offset, offset + commentLength));
      offset += commentLength;

      final separatorIndex = comment.indexOf('=');
      if (separatorIndex <= 0) continue;

      final key = comment.substring(0, separatorIndex).toUpperCase();
      final value = comment.substring(separatorIndex + 1);
      if (key == AppConstants.vorbisTrackArtistCommentKey) {
        trackArtists.add(value);
      } else if (key == AppConstants.vorbisAlbumArtistCommentKey) {
        albumArtists.add(value);
      }
    }

    return {
      AppConstants.tagArtistTrackKey: ArtistNameService.mergeArtistSources(
        rawValues: trackArtists,
      ),
      AppConstants.tagArtistAlbumKey: ArtistNameService.mergeArtistSources(
        rawValues: albumArtists,
      ),
    };
  }

  static int _decodeLittleEndianInt(List<int> bytes) {
    return ByteData.sublistView(
      Uint8List.fromList(bytes),
    ).getUint32(0, Endian.little);
  }

  static Map<String, List<String>> _emptyArtistMap() {
    return const {
      AppConstants.tagArtistTrackKey: <String>[],
      AppConstants.tagArtistAlbumKey: <String>[],
    };
  }
}
