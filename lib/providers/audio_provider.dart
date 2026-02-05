import 'package:flutter/material.dart';
import 'dart:io';
import 'package:audio_metadata_reader/audio_metadata_reader.dart';
import 'package:audiotags/audiotags.dart' as at;
import '../models/audio_file.dart';
import '../services/file_service.dart';
import '../services/metadata_service.dart';
import 'package:path/path.dart' as p;

enum FileFilter { all, valid, invalid }

class AudioProvider extends ChangeNotifier {
  List<AudioFile> _files = [];
  FileFilter _filter = FileFilter.all;
  String _sortCriteria = 'name';
  
  int get totalFilesCount => _files.length;
  bool get hasRenameCandidates {
    for (final file in _files) {
      if (file.status != ProcessingStatus.success) continue;
      final newName = file.newFileName;
      if (newName == null) continue;
      if (file.originalFileName != newName) return true;
    }
    return false;
  }

  List<AudioFile> get files {
    if (_filter == FileFilter.all) return _files;
    
    return _files.where((f) {
      if (f.status != ProcessingStatus.success || f.newFileName == null) return true;
      final isValid = f.originalFileName == f.newFileName;
      return _filter == FileFilter.valid ? isValid : !isValid;
    }).toList();
  }
  
  FileFilter get filter => _filter;
  String get sortCriteria => _sortCriteria;

  void setFilter(FileFilter filter) {
    _filter = filter;
    notifyListeners();
  }

  void setSortCriteria(String criteria) {
    if (_sortCriteria == criteria) return;
    _sortCriteria = criteria;
    _sortFiles(criteria);
    _updateNewFileNames();
    notifyListeners();
  }

  String _pattern = '{artist} - {title}';
  String get pattern => _pattern;

  static const List<Map<String, String>> predefinedPatterns = [
    {'name': 'Artist - Title', 'pattern': '{artist} - {title}'},
    {'name': 'Title - Artist', 'pattern': '{title} - {artist}'},
    {'name': 'Track - Title', 'pattern': '{track} - {title}'},
    {'name': 'Artist - Album - Title', 'pattern': '{artist} - {album} - {title}'},
  ];

  String _unknownArtist = 'Unknown artist';
  String _unknownTitle = 'Unknown title';
  String _unknownAlbum = 'Unknown album';
  String _untitledTrack = 'Untitled track';

  void setNamingPlaceholders({
    required String unknownArtist,
    required String unknownTitle,
    required String unknownAlbum,
    required String untitledTrack,
  }) {
    if (_unknownArtist == unknownArtist &&
        _unknownTitle == unknownTitle &&
        _unknownAlbum == unknownAlbum &&
        _untitledTrack == untitledTrack) {
      return;
    }

    _unknownArtist = unknownArtist;
    _unknownTitle = unknownTitle;
    _unknownAlbum = unknownAlbum;
    _untitledTrack = untitledTrack;
    _updateNewFileNames();
    notifyListeners();
  }

  bool _isProcessing = false;
  bool get isProcessing => _isProcessing;

  double _progress = 0;
  double get progress => _progress;

  void setPattern(String newPattern) {
    if (_pattern == newPattern) return;
    _pattern = newPattern;
    _updateNewFileNames();
    notifyListeners();
  }

  void _updateNewFileNames() {
    for (int i = 0; i < _files.length; i++) {
      final file = _files[i];
      if (file.status == ProcessingStatus.success && file.metadata != null) {
        file.newFileName = MetadataService.formatNewFileName(
          artist: file.artist,
          title: file.title,
          album: file.album,
          track: file.track,
          extension: file.extension,
          pattern: _pattern,
          unknownArtist: _unknownArtist,
          unknownTitle: _unknownTitle,
          unknownAlbum: _unknownAlbum,
          untitledTrack: _untitledTrack,
          index: i + 1,
        );
      }
    }
  }

  Future<void> updateMetadata(
    AudioFile file, {
    required String title,
    required String artist,
    required String album,
    required String trackNumber,
    required String trackTotal,
    required String discNumber,
    required String discTotal,
    required String year,
    required String genre,
    required String language,
    required String comment,
  }) async {
    try {
      final tags = at.Tag(
        title: _normalizeText(title),
        trackArtist: _normalizeText(artist),
        album: _normalizeText(album),
        trackNumber: _parseInt(trackNumber),
        trackTotal: _parseInt(trackTotal),
        discNumber: _parseInt(discNumber),
        discTotal: _parseInt(discTotal),
        year: _parseInt(year),
        genre: _normalizeText(genre),
        pictures: [],
      );

      await at.AudioTags.write(file.path, tags);

      // Re-read metadata to ensure consistency
      final metadata = await MetadataService.getMetadata(file.path);
      if (metadata != null) {
        file.metadata = metadata;
      } else {
        // Fallback if re-read fails
        final currentMetadata = file.metadata ?? AudioMetadata(file: File(file.path));
        currentMetadata.title = _normalizeText(title);
        currentMetadata.artist = _normalizeText(artist);
        currentMetadata.album = _normalizeText(album);
        currentMetadata.trackNumber = _parseInt(trackNumber);
        currentMetadata.trackTotal = _parseInt(trackTotal);
        currentMetadata.discNumber = _parseInt(discNumber);
        currentMetadata.totalDisc = _parseInt(discTotal);
        currentMetadata.year = _parseYear(year);
        currentMetadata.language = _normalizeText(language);
        currentMetadata.genres = _parseGenres(genre);
        file.metadata = currentMetadata;
      }
      
      file.comment = _normalizeText(comment);
      
      if (file.status != ProcessingStatus.success) {
        file.status = ProcessingStatus.success;
        file.errorMessage = null;
      }
      _updateNewFileNames();
      notifyListeners();
    } catch (e) {
      debugPrint('Error writing metadata: $e');
      file.status = ProcessingStatus.error;
      file.errorMessage = e.toString();
      notifyListeners();
      rethrow;
    }
  }

  Future<void> addFiles(List<String> paths) async {
    _isProcessing = true;
    _progress = 0;
    notifyListeners();

    final newFiles = <AudioFile>[];
    for (final path in paths) {
      final file = File(path);
      if (await file.exists()) {
        final stat = await file.stat();
        newFiles.add(AudioFile(
          path: path,
          extension: p.extension(path),
          size: stat.size,
          modified: stat.modified,
        ));
      }
    }

    _files.addAll(newFiles);
    _sortFiles(_sortCriteria);
    notifyListeners();

    await _fetchMetadata(newFiles);

    _isProcessing = false;
    notifyListeners();
  }

  Future<void> _fetchMetadata(List<AudioFile> filesToProcess) async {
    int count = 0;
    for (final file in filesToProcess) {
      final metadata = await MetadataService.getMetadata(file.path);
      if (metadata != null) {
        file.metadata = metadata;
        file.status = ProcessingStatus.success;
        file.newFileName = MetadataService.formatNewFileName(
          artist: file.artist,
          title: file.title,
          album: file.album,
          track: file.track,
          extension: file.extension,
          pattern: _pattern,
          unknownArtist: _unknownArtist,
          unknownTitle: _unknownTitle,
          unknownAlbum: _unknownAlbum,
          untitledTrack: _untitledTrack,
          index: _files.indexOf(file) + 1,
        );
      } else {
        file.status = ProcessingStatus.error;
        file.errorMessage = 'metadataReadFailed';
      }
      count++;
      _progress = count / filesToProcess.length;
      notifyListeners();
    }

    _sortFiles(_sortCriteria);
    _updateNewFileNames();
    notifyListeners();
  }

  Future<void> clearFiles() async {
    _files = [];
    notifyListeners();
  }

  Future<int> renameAll() async {
    _isProcessing = true;
    _progress = 0;
    notifyListeners();

    int successCount = 0;
    for (int i = 0; i < _files.length; i++) {
      final file = _files[i];
      if (file.status == ProcessingStatus.success && file.newFileName != null) {
        if (file.originalFileName == file.newFileName) {
          successCount++;
        } else {
          final success = await FileService.renameFile(file.path, file.newFileName!);
          if (success) {
            successCount++;
          }
        }
      }
      _progress = (i + 1) / _files.length;
      notifyListeners();
    }

    await clearFiles();
    _isProcessing = false;
    notifyListeners();
    return successCount;
  }

  void sortBy(String criteria) {
    _sortCriteria = criteria;
    _sortFiles(criteria);
    _updateNewFileNames();
    notifyListeners();
  }

  void _sortFiles(String criteria) {
    switch (criteria) {
      case 'name':
        _files.sort((a, b) => a.originalFileName.compareTo(b.originalFileName));
        return;
      case 'artist':
        _files.sort((a, b) => a.artist.compareTo(b.artist));
        return;
      case 'title':
        _files.sort((a, b) => a.title.compareTo(b.title));
        return;
      case 'size':
        _files.sort((a, b) => a.size.compareTo(b.size));
        return;
      case 'date':
        _files.sort((a, b) => a.modified.compareTo(b.modified));
        return;
    }
  }

  String? _normalizeText(String value) {
    final trimmed = value.trim();
    return trimmed.isEmpty ? null : trimmed;
  }

  int? _parseInt(String value) {
    final trimmed = value.trim();
    if (trimmed.isEmpty) return null;
    return int.tryParse(trimmed);
  }

  DateTime? _parseYear(String value) {
    final number = _parseInt(value);
    if (number == null) return null;
    return DateTime(number);
  }

  List<String> _parseGenres(String value) {
    final trimmed = value.trim();
    if (trimmed.isEmpty) return [];
    return trimmed
        .split(',')
        .map((e) => e.trim())
        .where((e) => e.isNotEmpty)
        .toList();
  }
}
