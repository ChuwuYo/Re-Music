import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:audio_metadata_reader/audio_metadata_reader.dart';
import 'package:audiotags/audiotags.dart' as at;
import '../constants.dart';
import 'artist_name_service.dart';
import 'mp3_artist_tag_parser.dart';
import 'vorbis_artist_tag_parser.dart';

class TagArtists {
  final String? trackArtist;
  final String? albumArtist;

  const TagArtists({this.trackArtist, this.albumArtist});
}

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

  static Future<TagArtists?> getTagArtists(String filePath) async {
    try {
      final parsedArtists = await compute(
        _readStructuredArtistsIsolate,
        filePath,
      );
      final tags = await at.AudioTags.read(filePath);
      final trackArtists = ArtistNameService.mergeArtistSources(
        rawValues: [tags?.trackArtist],
        collections: [
          (parsedArtists[AppConstants.tagArtistTrackKey] as List<dynamic>)
              .cast<String>(),
        ],
      );
      final albumArtists = ArtistNameService.mergeArtistSources(
        rawValues: [tags?.albumArtist],
        collections: [
          (parsedArtists[AppConstants.tagArtistAlbumKey] as List<dynamic>)
              .cast<String>(),
        ],
      );

      if (trackArtists.isEmpty && albumArtists.isEmpty) {
        return null;
      }

      return TagArtists(
        trackArtist: ArtistNameService.joinArtists(trackArtists),
        albumArtist: ArtistNameService.joinArtists(albumArtists),
      );
    } catch (e) {
      debugPrint('Error reading tag artists for $filePath: $e');
      return null;
    }
  }

  static Map<String, List<String>> _readStructuredArtistsIsolate(
    String filePath,
  ) {
    try {
      final parserTag = readAllMetadata(File(filePath), getImage: false);

      switch (parserTag) {
        case Mp3Metadata metadata:
          return Mp3ArtistTagParser.readStructuredArtists(
            filePath,
            leadPerformer: metadata.leadPerformer,
            bandOrOrchestra: metadata.bandOrOrchestra,
            customMetadata: metadata.customMetadata,
          );
        case VorbisMetadata _:
          return VorbisArtistTagParser.readStructuredArtists(filePath);
        case Mp4Metadata metadata:
          return _buildStructuredArtists(
            trackArtists: ArtistNameService.splitArtists(metadata.artist),
          );
        case RiffMetadata metadata:
          return _buildStructuredArtists(
            trackArtists: ArtistNameService.splitArtists(metadata.artist),
          );
      }
    } catch (e) {
      debugPrint('Error reading structured artists for $filePath: $e');
    }

    return _buildStructuredArtists();
  }

  static Map<String, List<String>> _buildStructuredArtists({
    Iterable<String> trackArtists = const [],
    Iterable<String> albumArtists = const [],
  }) {
    return {
      AppConstants.tagArtistTrackKey: ArtistNameService.mergeArtistSources(
        collections: [trackArtists],
      ),
      AppConstants.tagArtistAlbumKey: ArtistNameService.mergeArtistSources(
        collections: [albumArtists],
      ),
    };
  }

  @visibleForTesting
  static Map<String, List<String>> parseVorbisCommentBlockForTest(
    Uint8List bytes, {
    int headerOffset = 0,
  }) {
    return VorbisArtistTagParser.parseCommentBlockForTest(
      bytes,
      headerOffset: headerOffset,
    );
  }

  @visibleForTesting
  static List<String> decodeId3TextFrameValuesForTest(
    List<int> frameData, {
    required int majorVersion,
    int formatFlags = 0,
    bool tagUnsynchronization = false,
  }) {
    return Mp3ArtistTagParser.decodeId3TextFrameValuesForTest(
      frameData,
      majorVersion: majorVersion,
      formatFlags: formatFlags,
      tagUnsynchronization: tagUnsynchronization,
    );
  }

  static String formatNewFileName({
    required String artist,
    String? albumArtist,
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
    String cleanValue(String value) {
      return value
          .replaceAll(
            AppConstants.invalidFilenameChars,
            AppConstants.invalidFilenameReplacement,
          )
          .trim();
    }

    final cleanArtist = cleanValue(artist);
    final cleanAlbumArtist = cleanValue(albumArtist ?? '');
    final cleanTitle = cleanValue(title);
    final cleanAlbum = cleanValue(album ?? '');
    final cleanTrack = cleanValue(track ?? '');
    final safeArtistSeparator =
        AppConstants.isValidArtistSeparator(artistSeparator)
        ? artistSeparator
        : AppConstants.defaultArtistSeparator;

    final artistValue = ArtistNameService.joinArtists(
      ArtistNameService.splitArtists(artist).map(cleanValue),
      separator: safeArtistSeparator,
      fallback: unknownArtist,
    );
    final albumArtistValue = ArtistNameService.joinArtists(
      ArtistNameService.splitArtists(albumArtist).map(cleanValue),
      separator: safeArtistSeparator,
      fallback: unknownArtist,
    );
    final titleValue = cleanTitle.isEmpty ? unknownTitle : cleanTitle;
    final albumValue = cleanAlbum.isEmpty ? unknownAlbum : cleanAlbum;
    final trackValue = cleanTrack.isEmpty ? indexStr : cleanTrack;

    if (pattern.contains('{')) {
      baseName = pattern
          .replaceAll('{artist}', artistValue)
          .replaceAll('{albumArtist}', albumArtistValue)
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
          : (cleanArtist.isNotEmpty
                ? cleanArtist
                : (cleanAlbumArtist.isNotEmpty
                      ? cleanAlbumArtist
                      : untitledTrack));
    }

    final ext = extension.startsWith('.') ? extension : '.$extension';
    return '$baseName$ext';
  }
}
