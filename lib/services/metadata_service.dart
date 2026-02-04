import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:audio_metadata_reader/audio_metadata_reader.dart';

class MetadataService {
  static Future<AudioMetadata?> getMetadata(String filePath) async {
    try {
      final metadata = readMetadata(File(filePath), getImage: false);
      return metadata;
    } catch (e) {
      debugPrint('Error reading metadata for $filePath: $e');
      return null;
    }
  }

  static String formatNewFileName({
    required String artist,
    required String title,
    String? album,
    String? track,
    required String extension,
    required String pattern,
    required String unknownArtist,
    required String unknownTitle,
    required String unknownAlbum,
    required String untitledTrack,
    int? index,
  }) {
    String baseName;
    final indexStr = index != null ? index.toString().padLeft(2, '0') : '';

    final cleanArtist = artist.replaceAll(RegExp(r'[\\/:*?"<>|]'), '_').trim();
    final cleanTitle = title.replaceAll(RegExp(r'[\\/:*?"<>|]'), '_').trim();
    final cleanAlbum = (album ?? '').replaceAll(RegExp(r'[\\/:*?"<>|]'), '_').trim();
    final cleanTrack = (track ?? '').replaceAll(RegExp(r'[\\/:*?"<>|]'), '_').trim();

    final artistValue = cleanArtist.isEmpty ? unknownArtist : cleanArtist;
    final titleValue = cleanTitle.isEmpty ? unknownTitle : cleanTitle;
    final albumValue = cleanAlbum.isEmpty ? unknownAlbum : cleanAlbum;
    final trackValue = cleanTrack.isEmpty ? indexStr : cleanTrack;

    if (pattern.contains('{')) {
      baseName = pattern
          .replaceAll('{artist}', artistValue)
          .replaceAll('{title}', titleValue)
          .replaceAll('{album}', albumValue)
          .replaceAll('{track}', trackValue)
          .replaceAll('{index}', indexStr);
    } else {
      switch (pattern) {
        case 'title-artist':
          baseName = '$titleValue - $artistValue';
          break;
        case 'indexed-artist-title':
          baseName = '$indexStr. $artistValue - $titleValue';
          break;
        case 'indexed-title-artist':
          baseName = '$indexStr. $titleValue - $artistValue';
          break;
        case 'artist-title':
        default:
          baseName = '$artistValue - $titleValue';
          break;
      }
    }

    baseName = baseName.trim();
    if (baseName.isEmpty) {
      baseName = cleanTitle.isNotEmpty ? cleanTitle : (cleanArtist.isNotEmpty ? cleanArtist : untitledTrack);
    }

    final ext = extension.startsWith('.') ? extension : '.$extension';
    return '$baseName$ext';
  }
}
