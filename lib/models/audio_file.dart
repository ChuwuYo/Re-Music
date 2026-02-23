import 'package:audio_metadata_reader/audio_metadata_reader.dart';
import 'package:path/path.dart' as p;
import '../constants.dart';

class AudioFile {
  final String path;
  final String extension;
  final int size;
  final DateTime modified;
  AudioMetadata? metadata;
  String? tagTrackArtist;
  String? tagAlbumArtist;
  String? comment;
  String? newFileName;
  ProcessingStatus status;
  String? errorMessage;

  AudioFile({
    required this.path,
    required this.extension,
    required this.size,
    required this.modified,
    this.metadata,
    this.tagTrackArtist,
    this.tagAlbumArtist,
    this.comment,
    this.newFileName,
    this.status = ProcessingStatus.pending,
    this.errorMessage,
  });

  String get originalFileName => p.basename(path);

  String get trackArtist {
    final explicitTrackArtist = (tagTrackArtist ?? '').trim();
    if (explicitTrackArtist.isNotEmpty) return explicitTrackArtist;

    final parsedArtist = (metadata?.artist ?? '').trim();
    final explicitAlbumArtist = (tagAlbumArtist ?? '').trim();

    if (explicitAlbumArtist.isNotEmpty && parsedArtist == explicitAlbumArtist) {
      return '';
    }
    return parsedArtist;
  }

  String get albumArtist {
    final explicitAlbumArtist = (tagAlbumArtist ?? '').trim();
    if (explicitAlbumArtist.isNotEmpty) return explicitAlbumArtist;

    final parsedArtist = (metadata?.artist ?? '').trim();
    final explicitTrackArtist = (tagTrackArtist ?? '').trim();
    if (explicitTrackArtist.isNotEmpty &&
        parsedArtist.isNotEmpty &&
        parsedArtist != explicitTrackArtist) {
      return parsedArtist;
    }
    return '';
  }

  String get performers {
    final list = metadata?.performers ?? const <String>[];
    return list.map((s) => s.trim()).where((s) => s.isNotEmpty).join(', ');
  }

  /// Backward compatibility for existing UI/sort logic.
  String get artist => trackArtist;

  /// Artist source for renaming: track artist > performers > album artist.
  String get namingArtist {
    final primary = trackArtist;
    if (primary.isNotEmpty) return primary;

    final guest = performers;
    if (guest.isNotEmpty) return guest;

    return albumArtist;
  }

  String get title => (metadata?.title ?? '').trim();

  String get album => (metadata?.album ?? '').trim();

  String get track => (metadata?.trackNumber?.toString() ?? '').trim();
}
