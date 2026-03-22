import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';

import '../constants.dart';
import 'artist_name_service.dart';

class Mp3ArtistTagParser {
  Mp3ArtistTagParser._();

  static Map<String, List<String>> readStructuredArtists(
    String filePath, {
    String? leadPerformer,
    String? bandOrOrchestra,
    Map<String, String> customMetadata = const {},
  }) {
    final rawId3Artists = readArtists(filePath);
    return {
      AppConstants.tagArtistTrackKey: ArtistNameService.mergeArtistSources(
        rawValues: [leadPerformer],
        collections: [
          rawId3Artists[AppConstants.tagArtistTrackKey] ?? const <String>[],
        ],
      ),
      AppConstants.tagArtistAlbumKey: ArtistNameService.mergeArtistSources(
        rawValues: [bandOrOrchestra, _findCustomAlbumArtist(customMetadata)],
        collections: [
          rawId3Artists[AppConstants.tagArtistAlbumKey] ?? const <String>[],
        ],
      ),
    };
  }

  static Map<String, List<String>> readArtists(String filePath) {
    final trackArtists = <String>[];
    final albumArtists = <String>[];
    final file = File(filePath);
    if (!file.existsSync()) {
      return _buildArtistMap(trackArtists, albumArtists);
    }

    final reader = file.openSync();
    try {
      final header = reader.readSync(10);
      if (header.length < 10 ||
          String.fromCharCodes(header.sublist(0, 3)) != 'ID3') {
        return _buildArtistMap(trackArtists, albumArtists);
      }

      final majorVersion = header[3];
      if (majorVersion != 3 && majorVersion != 4) {
        return _buildArtistMap(trackArtists, albumArtists);
      }
      final tagUnsynchronization = (header[5] & 0x80) != 0;

      final tagSize = _decodeSyncSafeInt(header.sublist(6, 10));
      final tagEnd = 10 + tagSize;
      var offset = 10;

      if ((header[5] & 0x40) != 0) {
        final extendedHeaderBytes = reader.readSync(4);
        final extendedHeaderSize = majorVersion == 4
            ? _decodeSyncSafeInt(extendedHeaderBytes)
            : _decodeBigEndianInt(extendedHeaderBytes);
        reader.setPositionSync(10 + extendedHeaderSize);
        offset = 10 + extendedHeaderSize;
      }

      while (offset + 10 <= tagEnd) {
        reader.setPositionSync(offset);
        final frameHeader = reader.readSync(10);
        if (frameHeader.length < 10 ||
            frameHeader.every((value) => value == 0)) {
          break;
        }

        final frameId = String.fromCharCodes(frameHeader.sublist(0, 4));
        final frameSize = majorVersion == 4
            ? _decodeSyncSafeInt(frameHeader.sublist(4, 8))
            : _decodeBigEndianInt(frameHeader.sublist(4, 8));
        if (frameSize <= 0 || offset + 10 + frameSize > tagEnd) {
          break;
        }

        final frameData = reader.readSync(frameSize);
        final normalizedFrameData = _normalizeId3FrameData(
          frameData,
          majorVersion: majorVersion,
          formatFlags: frameHeader[9],
          tagUnsynchronization: tagUnsynchronization,
        );
        if (normalizedFrameData == null) {
          offset += 10 + frameSize;
          continue;
        }

        final frameArtists = _decodeId3TextFrameValues(normalizedFrameData);
        if (frameId == AppConstants.mp3TrackArtistFrameId) {
          trackArtists.addAll(frameArtists);
        } else if (frameId == AppConstants.mp3AlbumArtistFrameId) {
          albumArtists.addAll(frameArtists);
        }

        offset += 10 + frameSize;
      }
    } catch (e) {
      debugPrint('Error reading MP3 ID3 artists for $filePath: $e');
    } finally {
      reader.closeSync();
    }

    return _buildArtistMap(trackArtists, albumArtists);
  }

  static List<String> decodeId3TextFrameValuesForTest(
    List<int> frameData, {
    required int majorVersion,
    int formatFlags = 0,
    bool tagUnsynchronization = false,
  }) {
    final normalized = _normalizeId3FrameData(
      frameData,
      majorVersion: majorVersion,
      formatFlags: formatFlags,
      tagUnsynchronization: tagUnsynchronization,
    );
    if (normalized == null) return const [];
    return _decodeId3TextFrameValues(normalized);
  }

  static Map<String, List<String>> _buildArtistMap(
    List<String> trackArtists,
    List<String> albumArtists,
  ) {
    return {
      AppConstants.tagArtistTrackKey: ArtistNameService.mergeArtistSources(
        collections: [trackArtists],
      ),
      AppConstants.tagArtistAlbumKey: ArtistNameService.mergeArtistSources(
        collections: [albumArtists],
      ),
    };
  }

  static String? _findCustomAlbumArtist(Map<String, String> customMetadata) {
    for (final entry in customMetadata.entries) {
      final normalizedKey = entry.key.toLowerCase().replaceAll(' ', '');
      if (normalizedKey == AppConstants.normalizedAlbumArtistMetadataKey) {
        return entry.value;
      }
    }
    return null;
  }

  static List<int>? _normalizeId3FrameData(
    List<int> frameData, {
    required int majorVersion,
    required int formatFlags,
    required bool tagUnsynchronization,
  }) {
    if (frameData.isEmpty) return null;

    var bytes = Uint8List.fromList(frameData);
    var offset = 0;

    if (majorVersion == 4) {
      final groupingIdentity = (formatFlags & 0x40) != 0;
      final compression = (formatFlags & 0x08) != 0;
      final encryption = (formatFlags & 0x04) != 0;
      final unsynchronization = (formatFlags & 0x02) != 0;
      final dataLengthIndicator = (formatFlags & 0x01) != 0;

      if (groupingIdentity) offset += 1;
      if (encryption) offset += 1;
      if (dataLengthIndicator) offset += 4;
      if (offset > bytes.length) return null;

      var payload = Uint8List.fromList(bytes.sublist(offset));
      if (compression) {
        try {
          payload = Uint8List.fromList(ZLibDecoder().convert(payload));
        } catch (_) {
          return null;
        }
      }
      if (unsynchronization || tagUnsynchronization) {
        payload = _removeUnsynchronization(payload);
      }
      return payload;
    }

    if (majorVersion == 3) {
      final compression = (formatFlags & 0x80) != 0;
      final encryption = (formatFlags & 0x40) != 0;
      final groupingIdentity = (formatFlags & 0x20) != 0;

      if (compression) offset += 4;
      if (encryption) offset += 1;
      if (groupingIdentity) offset += 1;
      if (offset > bytes.length) return null;

      var payload = Uint8List.fromList(bytes.sublist(offset));
      if (compression) {
        try {
          payload = Uint8List.fromList(ZLibDecoder().convert(payload));
        } catch (_) {
          return null;
        }
      }
      if (tagUnsynchronization) {
        payload = _removeUnsynchronization(payload);
      }
      return payload;
    }

    return bytes;
  }

  static Uint8List _removeUnsynchronization(Uint8List payload) {
    final normalized = <int>[];
    for (var index = 0; index < payload.length; index++) {
      final current = payload[index];
      if (current == 0xFF &&
          index + 1 < payload.length &&
          payload[index + 1] == 0x00) {
        normalized.add(0xFF);
        index++;
        continue;
      }
      normalized.add(current);
    }
    return Uint8List.fromList(normalized);
  }

  static int _decodeSyncSafeInt(List<int> bytes) {
    return (bytes[3] & 0x7F) |
        ((bytes[2] & 0x7F) << 7) |
        ((bytes[1] & 0x7F) << 14) |
        ((bytes[0] & 0x7F) << 21);
  }

  static int _decodeBigEndianInt(List<int> bytes) {
    return ByteData.sublistView(Uint8List.fromList(bytes)).getUint32(0);
  }

  static List<String> _decodeId3TextFrameValues(List<int> frameData) {
    if (frameData.length <= 1) return const [];

    final encoding = frameData.first;
    final content = Uint8List.fromList(frameData.sublist(1));

    switch (encoding) {
      case 0:
        return _decodeSingleByteSegments(content, latin1: true);
      case 1:
        return _decodeDoubleByteSegments(content, withBom: true);
      case 2:
        return _decodeDoubleByteSegments(
          content,
          withBom: false,
          bigEndian: true,
        );
      case 3:
        return _decodeSingleByteSegments(content, latin1: false);
      default:
        return const [];
    }
  }

  static List<String> _decodeSingleByteSegments(
    Uint8List content, {
    required bool latin1,
  }) {
    final values = <String>[];
    var start = 0;
    for (var index = 0; index <= content.length; index++) {
      if (index == content.length || content[index] == 0) {
        if (index > start) {
          final segment = content.sublist(start, index);
          final decoded = latin1
              ? String.fromCharCodes(segment)
              : utf8.decode(segment, allowMalformed: true);
          values.addAll(ArtistNameService.splitArtists(decoded));
        }
        start = index + 1;
      }
    }
    return values;
  }

  static List<String> _decodeDoubleByteSegments(
    Uint8List content, {
    required bool withBom,
    bool bigEndian = false,
  }) {
    final values = <String>[];
    var start = 0;
    for (var index = 0; index + 1 < content.length; index += 2) {
      if (content[index] == 0 && content[index + 1] == 0) {
        if (index > start) {
          final segment = content.sublist(start, index);
          final decoded = _decodeUtf16Segment(
            segment,
            withBom: withBom,
            bigEndian: bigEndian,
          );
          values.addAll(ArtistNameService.splitArtists(decoded));
        }
        start = index + 2;
      }
    }

    if (start < content.length) {
      final decoded = _decodeUtf16Segment(
        content.sublist(start),
        withBom: withBom,
        bigEndian: bigEndian,
      );
      values.addAll(ArtistNameService.splitArtists(decoded));
    }

    return values;
  }

  static String _decodeUtf16Segment(
    Uint8List segment, {
    required bool withBom,
    required bool bigEndian,
  }) {
    if (segment.isEmpty) return '';

    var start = 0;
    var endian = bigEndian ? Endian.big : Endian.little;
    if (withBom && segment.length >= 2) {
      if (segment[0] == 0xFE && segment[1] == 0xFF) {
        endian = Endian.big;
        start = 2;
      } else if (segment[0] == 0xFF && segment[1] == 0xFE) {
        endian = Endian.little;
        start = 2;
      }
    }

    final bytes = segment.sublist(start);
    final data = ByteData.sublistView(Uint8List.fromList(bytes));
    final codeUnits = <int>[];
    for (var offset = 0; offset + 1 < data.lengthInBytes; offset += 2) {
      codeUnits.add(data.getUint16(offset, endian));
    }
    return String.fromCharCodes(codeUnits).trim();
  }
}
