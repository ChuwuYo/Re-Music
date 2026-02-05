// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'Re:Music';

  @override
  String get clearList => 'Clear list';

  @override
  String get language => 'Language';

  @override
  String get followSystem => 'Follow system';

  @override
  String get chinese => '中文';

  @override
  String get english => 'English';

  @override
  String get switchToDark => 'Switch to dark mode';

  @override
  String get switchToLight => 'Switch to light mode';

  @override
  String get themeColor => 'Theme color';

  @override
  String get themeColorTeal => 'Teal';

  @override
  String get themeColorBlue => 'Blue';

  @override
  String get themeColorIndigo => 'Indigo';

  @override
  String get themeColorPurple => 'Purple';

  @override
  String get themeColorPink => 'Pink';

  @override
  String get themeColorOrange => 'Orange';

  @override
  String get themeColorGreen => 'Green';

  @override
  String get themeColorRed => 'Red';

  @override
  String get addFiles => 'Add files';

  @override
  String get scanDirectory => 'Scan folder';

  @override
  String get namingMode => 'Naming pattern';

  @override
  String namingModeHint(Object artist, Object title) {
    return 'Choose or enter a custom pattern (e.g. $artist - $title)';
  }

  @override
  String get patternArtistTitle => 'Artist - Title';

  @override
  String get patternTitleArtist => 'Title - Artist';

  @override
  String get patternTrackTitle => 'Track - Title';

  @override
  String get patternArtistAlbumTitle => 'Artist - Album - Title';

  @override
  String get customPattern => 'Custom pattern';

  @override
  String get filter => 'Filter';

  @override
  String get showAll => 'Show all';

  @override
  String get showNoRenameNeeded => 'Only show no-rename-needed';

  @override
  String get showNeedRename => 'Only show needs rename';

  @override
  String get sort => 'Sort';

  @override
  String get sortByName => 'By file name';

  @override
  String get sortByArtist => 'By artist';

  @override
  String get sortByTitle => 'By title';

  @override
  String get sortBySize => 'By size';

  @override
  String get sortByModifiedTime => 'By modified time';

  @override
  String get emptyTitle => 'Drop files here or click Add';

  @override
  String get emptySubtitle => 'Supports MP3, FLAC, M4A and more';

  @override
  String get noMatchTitle => 'No files match the current filter';

  @override
  String get noMatchSubtitle => 'Adjust the filter to see your files';

  @override
  String processingProgress(int percent) {
    return 'Processing... $percent%';
  }

  @override
  String totalFiles(int count) {
    return 'Total $count files';
  }

  @override
  String get startRename => 'Start';

  @override
  String renameCompleted(int count) {
    return 'Done! Renamed $count files';
  }

  @override
  String get readingMetadata => 'Reading metadata...';

  @override
  String get readFailed => 'Read failed';

  @override
  String get nameMatches => 'Name matches';

  @override
  String get renameToPrefix => 'Rename to: ';

  @override
  String get unknownArtist => 'Unknown artist';

  @override
  String get unknownTitle => 'Unknown title';

  @override
  String get unknownAlbum => 'Unknown album';

  @override
  String get untitledTrack => 'Untitled track';

  @override
  String get metadataReadFailed => 'Failed to read metadata';

  @override
  String get unknownError => 'Unknown error';

  @override
  String get editTags => 'Edit tags';

  @override
  String get metadataEditorTitle => 'Edit metadata';

  @override
  String get metadataTitle => 'Title';

  @override
  String get metadataArtist => 'Artist';

  @override
  String get metadataAlbum => 'Album';

  @override
  String get metadataTrackNumber => 'Track No.';

  @override
  String get metadataTrackTotal => 'Total tracks';

  @override
  String get metadataYear => 'Year';

  @override
  String get metadataGenre => 'Genre';

  @override
  String get metadataLanguage => 'Language';

  @override
  String get metadataComment => 'Comment';

  @override
  String get apply => 'Apply';

  @override
  String get confirm => 'Confirm';

  @override
  String get cancel => 'Cancel';

  @override
  String get close => 'Close';

  @override
  String get invalidNumber => 'Please enter a valid number';
}
