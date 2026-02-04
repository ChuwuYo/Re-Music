import 'package:audio_metadata_reader/audio_metadata_reader.dart';

enum ProcessingStatus { pending, success, error }

class AudioFile {
  final String path;
  final String extension;
  final int size;
  final DateTime modified;
  AudioMetadata? metadata;
  String? newFileName;
  ProcessingStatus status;
  String? errorMessage;

  AudioFile({
    required this.path,
    required this.extension,
    required this.size,
    required this.modified,
    this.metadata,
    this.newFileName,
    this.status = ProcessingStatus.pending,
    this.errorMessage,
  });

  String get originalFileName => path.split('\\').last;

  String get artist => (metadata?.artist ?? '').trim();

  String get title => (metadata?.title ?? '').trim();

  String get album => (metadata?.album ?? '').trim();

  String get track => (metadata?.trackNumber?.toString() ?? '').trim();
}
