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

class ExtendedTagDetails {
  final TagArtists? artists;
  final int? discNumber;
  final int? discTotal;
  final double? bpm;
  final String? lyrics;
  final String? composer;
  final String? lyricist;
  final String? publisher;
  final String? comment;
  final Map<String, String> customTags;

  const ExtendedTagDetails({
    this.artists,
    this.discNumber,
    this.discTotal,
    this.bpm,
    this.lyrics,
    this.composer,
    this.lyricist,
    this.publisher,
    this.comment,
    this.customTags = const {},
  });
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
    final metadata = readMetadata(File(filePath), getImage: false);
    // Fix third-party bug in audio_metadata_reader 1.4.2 where FlacParser & OggParser
    // copy artist.firstOrNull into language.
    final ext = filePath.toLowerCase();
    final isVorbisContainer =
        ext.endsWith('.flac') || ext.endsWith('.ogg') || ext.endsWith('.oga');
    if (isVorbisContainer &&
        metadata.language != null &&
        metadata.language == metadata.artist) {
      metadata.language = null;
    }
    return metadata;
  }

  static Future<TagArtists?> getTagArtists(String filePath) async {
    final details = await getTagDetails(filePath);
    return details?.artists;
  }

  static Future<ExtendedTagDetails?> getTagDetails(String filePath) async {
    try {
      final parsed = await compute(_readStructuredMetadataIsolate, filePath);
      final tags = await at.AudioTags.read(filePath);

      final structuredArtists =
          (parsed['artists'] as Map<dynamic, dynamic>?)
              ?.cast<String, List<String>>() ??
          {};
      final trackArtists = ArtistNameService.mergeArtistSources(
        rawValues: [tags?.trackArtist],
        collections: [
          structuredArtists[AppConstants.tagArtistTrackKey] ?? const <String>[],
        ],
      );
      final albumArtists = ArtistNameService.mergeArtistSources(
        rawValues: [tags?.albumArtist],
        collections: [
          structuredArtists[AppConstants.tagArtistAlbumKey] ?? const <String>[],
        ],
      );

      TagArtists? artists;
      if (trackArtists.isNotEmpty || albumArtists.isNotEmpty) {
        artists = TagArtists(
          trackArtist: ArtistNameService.joinArtists(trackArtists),
          albumArtist: ArtistNameService.joinArtists(albumArtists),
        );
      }

      return ExtendedTagDetails(
        artists: artists,
        discNumber: tags?.discNumber ?? parsed['discNumber'] as int?,
        discTotal: tags?.discTotal ?? parsed['discTotal'] as int?,
        bpm: tags?.bpm,
        lyrics: tags?.lyrics ?? parsed['lyrics'] as String?,
        composer: parsed['composer'] as String?,
        lyricist: parsed['lyricist'] as String?,
        publisher: parsed['publisher'] as String?,
        comment: parsed['comment'] as String?,
        customTags:
            (parsed['customTags'] as Map<dynamic, dynamic>?)
                ?.cast<String, String>() ??
            const {},
      );
    } catch (e) {
      debugPrint('Error reading tag details for $filePath: $e');
      return null;
    }
  }

  static Map<String, dynamic> _readStructuredMetadataIsolate(String filePath) {
    try {
      final parserTag = readAllMetadata(File(filePath), getImage: false);
      String? composer;
      String? lyricist;
      String? publisher;
      String? comment;
      int? discNumber;
      int? discTotal;
      String? lyrics;
      Map<String, String> customTags = {};
      Map<String, List<String>> structuredArtists = {};

      switch (parserTag) {
        case Mp3Metadata metadata:
          structuredArtists = Mp3ArtistTagParser.readStructuredArtists(
            filePath,
            leadPerformer: metadata.leadPerformer,
            bandOrOrchestra: metadata.bandOrOrchestra,
            customMetadata: metadata.customMetadata,
          );
          composer = metadata.composer;
          lyricist = metadata.textWriter;
          publisher = metadata.publisher;
          comment = metadata.comments.isNotEmpty
              ? metadata.comments.first.text
              : null;
          lyrics = metadata.lyric;
          customTags = Map<String, String>.from(metadata.customMetadata);
          break;
        case VorbisMetadata metadata:
          structuredArtists = VorbisArtistTagParser.readStructuredArtists(
            filePath,
          );
          composer = metadata.composer.isNotEmpty
              ? metadata.composer.join(', ')
              : null;
          lyricist =
              metadata.unknowns['LYRICIST'] ?? metadata.unknowns['TEXTWRITER'];
          publisher = metadata.organization.isNotEmpty
              ? metadata.organization.join(', ')
              : null;
          comment = metadata.comment.isNotEmpty
              ? metadata.comment.join('\n')
              : null;
          discNumber = metadata.discNumber;
          discTotal = metadata.discTotal;
          lyrics = metadata.lyric;
          customTags = Map<String, String>.from(metadata.unknowns);
          break;
        case Mp4Metadata metadata:
          structuredArtists = _buildStructuredArtists(
            trackArtists: ArtistNameService.splitArtists(metadata.artist),
          );
          discNumber = metadata.discNumber;
          discTotal = metadata.totalDiscs;
          lyrics = metadata.lyrics;
          break;
        case RiffMetadata metadata:
          structuredArtists = _buildStructuredArtists(
            trackArtists: ArtistNameService.splitArtists(metadata.artist),
          );
          break;
      }

      return {
        'artists': structuredArtists,
        'composer': composer,
        'lyricist': lyricist,
        'publisher': publisher,
        'comment': comment,
        'discNumber': discNumber,
        'discTotal': discTotal,
        'lyrics': lyrics,
        'customTags': customTags,
      };
    } catch (e) {
      debugPrint('Error reading structured metadata for $filePath: $e');
      return {
        'artists': _buildStructuredArtists(),
        'customTags': <String, String>{},
      };
    }
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
    Iterable<String>? allowedArtistSeparators,
    String? currentFileName,
    int? index,
  }) {
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
    final titleValue = cleanTitle.isEmpty ? unknownTitle : cleanTitle;
    final albumValue = cleanAlbum.isEmpty ? unknownAlbum : cleanAlbum;
    final trackValue = cleanTrack.isEmpty ? indexStr : cleanTrack;
    final ext = extension.startsWith('.') ? extension : '.$extension';

    final artistParts = ArtistNameService.splitArtists(
      artist,
    ).map(cleanValue).toList();
    final albumArtistParts = ArtistNameService.splitArtists(
      albumArtist,
    ).map(cleanValue).toList();

    String buildWithSeparator(String sep) {
      final safeArtistSeparator = AppConstants.isValidArtistSeparator(sep)
          ? sep
          : AppConstants.defaultArtistSeparator;

      final artistValue = ArtistNameService.joinArtists(
        artistParts,
        separator: safeArtistSeparator,
        fallback: unknownArtist,
      );
      final albumArtistValue = ArtistNameService.joinArtists(
        albumArtistParts,
        separator: safeArtistSeparator,
        fallback: unknownArtist,
      );

      String baseName;
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

      return '$baseName$ext';
    }

    final candidateSeparators =
        allowedArtistSeparators != null && allowedArtistSeparators.isNotEmpty
        ? AppConstants.sanitizeAllowedArtistSeparators(allowedArtistSeparators)
        : [
            AppConstants.isValidArtistSeparator(artistSeparator)
                ? artistSeparator
                : AppConstants.defaultArtistSeparator,
          ];

    final primaryName = buildWithSeparator(candidateSeparators.first);
    if (currentFileName != null) {
      if (currentFileName == primaryName) {
        return primaryName;
      }
      for (final sep in candidateSeparators.skip(1)) {
        final candidate = buildWithSeparator(sep);
        if (currentFileName == candidate) {
          return candidate;
        }
      }
    }

    return primaryName;
  }
}
