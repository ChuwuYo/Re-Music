import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:audio_metadata_reader/audio_metadata_reader.dart';
import '../constants.dart';

class MetadataService {
  static Future<AudioMetadata?> getMetadata(String filePath) async {
    try {
      return await compute(_readMetadataIsolate, filePath);
    } catch (e) {
      debugPrint('Error reading metadata for $filePath: $e');
      return null;
    }
  }

  static AudioMetadata? _readMetadataIsolate(String filePath) {
    return readMetadata(File(filePath), getImage: false);
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
    String artistSeparator = AppConstants.defaultArtistSeparator,
    int? index,
  }) {
    String baseName;
    final indexStr = index != null
        ? index.toString().padLeft(AppConstants.numberPaddingLength, '0')
        : '';

    final cleanArtist = artist
        .replaceAll(
          AppConstants.invalidFilenameChars,
          AppConstants.invalidFilenameReplacement,
        )
        .trim();
    final cleanTitle = title
        .replaceAll(
          AppConstants.invalidFilenameChars,
          AppConstants.invalidFilenameReplacement,
        )
        .trim();
    final cleanAlbum = (album ?? '')
        .replaceAll(
          AppConstants.invalidFilenameChars,
          AppConstants.invalidFilenameReplacement,
        )
        .trim();
    final cleanTrack = (track ?? '')
        .replaceAll(
          AppConstants.invalidFilenameChars,
          AppConstants.invalidFilenameReplacement,
        )
        .trim();
    final safeArtistSeparator =
        AppConstants.isValidArtistSeparator(artistSeparator)
        ? artistSeparator
        : AppConstants.defaultArtistSeparator;

    String artistValue;
    if (cleanArtist.isEmpty) {
      artistValue = unknownArtist;
    } else {
      final artistParts = cleanArtist
          .split(RegExp(r'[,;/、，]'))
          .map((s) => s.trim())
          .where((s) => s.isNotEmpty)
          .toList();
      if (artistParts.length > 1) {
        artistValue = artistParts.join(safeArtistSeparator);
      } else {
        artistValue = cleanArtist;
      }
    }

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
      baseName = cleanTitle.isNotEmpty
          ? cleanTitle
          : (cleanArtist.isNotEmpty ? cleanArtist : untitledTrack);
    }

    final ext = extension.startsWith('.') ? extension : '.$extension';
    return '$baseName$ext';
  }
}
