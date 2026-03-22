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
  String get followSystem => 'Auto';

  @override
  String get chinese => '简体中文';

  @override
  String get english => 'English';

  @override
  String get switchToDark => 'Dark mode';

  @override
  String get switchToLight => 'Light mode';

  @override
  String get themeColor => 'Theme color';

  @override
  String get themeHueLabel => 'Hue';

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
  String get patternAlbumArtistTrackTitle => 'Album Artist - Track - Title';

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
  String get metadataTrackArtist => 'Track artist';

  @override
  String get metadataAlbumArtist => 'Album artist';

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

  @override
  String get sortAscending => 'Ascending';

  @override
  String get sortDescending => 'Descending';

  @override
  String get sidebarExpand => 'Expand sidebar';

  @override
  String get sidebarCollapse => 'Collapse sidebar';

  @override
  String get sidebarTooNarrow => 'Window too narrow — resize to expand';

  @override
  String get navHome => 'Home';

  @override
  String get navSettings => 'Settings';

  @override
  String get appearance => 'Appearance';

  @override
  String get themeMode => 'Theme mode';

  @override
  String get renameSettings => 'Rename settings';

  @override
  String get singleFileAddMode => 'When adding single file';

  @override
  String get directoryAddMode => 'When scanning directory';

  @override
  String get addModeAppend => 'Append to list';

  @override
  String get addModeReplace => 'Replace existing list';

  @override
  String get artistSeparator => 'Artist separator';

  @override
  String get artistSeparatorHint => 'Separator for multiple artists';

  @override
  String get navTranscode => 'Transcode';

  @override
  String get transcodeTitle => 'Transcode';

  @override
  String get transcodeStart => 'Start transcode';

  @override
  String transcodeCompleted(int count) {
    return 'Done! Processed $count files';
  }

  @override
  String transcodeProgress(int percent) {
    return 'Processing... $percent%';
  }

  @override
  String transcodeTotalFiles(int count) {
    return 'Total $count tasks';
  }

  @override
  String get transcodeEmptyTitle => 'Add audio files to start resampling';

  @override
  String get transcodeEmptySubtitle =>
      'Probe results, skip reasons, and output paths will appear here';

  @override
  String get transcodeOutputFormat => 'Output format';

  @override
  String get transcodePreset => 'Lossless preset';

  @override
  String get transcodeMp3Bitrate => 'MP3 bitrate';

  @override
  String get transcodeAllowFormatOnly =>
      'Convert files that only need a format change';

  @override
  String get transcodeEnableDither => 'Enable triangular dither';

  @override
  String get transcodeEnableDitherSubtitle =>
      'Reduces quantization noise when lowering bit depth';

  @override
  String get transcodeConcurrency => 'Concurrency';

  @override
  String get transcodeKeepOriginal => 'Keep original';

  @override
  String get transcodeReplaceOriginal => 'Replace original';

  @override
  String get transcodeOutputDirectory => 'Output directory';

  @override
  String get transcodeChooseOutputDirectory => 'Choose output folder';

  @override
  String get transcodeOutputDirectoryRequired =>
      'Choose an output folder first';

  @override
  String get transcodeFormatFlac => 'FLAC';

  @override
  String get transcodeFormatWav => 'WAV';

  @override
  String get transcodeFormatAlac => 'ALAC (.m4a)';

  @override
  String get transcodeFormatMp3 => 'MP3';

  @override
  String get transcodePresetStudio24 => '48kHz / 24bit';

  @override
  String get transcodePresetCd24 => '44.1kHz / 24bit';

  @override
  String get transcodePresetCd16 => '44.1kHz / 16bit';

  @override
  String get transcodeTaskTarget => 'Target';

  @override
  String get transcodeTaskOutput => 'Output';

  @override
  String get transcodeTaskUnknownOutput => 'Pending output path';

  @override
  String get transcodeTaskUnknownProbe => 'Probe pending';

  @override
  String get transcodeStatusProbing => 'Probing';

  @override
  String get transcodeStatusReady => 'Ready';

  @override
  String get transcodeStatusSkipped => 'Skipped';

  @override
  String get transcodeStatusQueued => 'Queued';

  @override
  String get transcodeStatusRunning => 'Running';

  @override
  String get transcodeStatusSuccess => 'Success';

  @override
  String get transcodeStatusError => 'Error';

  @override
  String get transcodeSkipLossyToLossless =>
      'Lossy input cannot be converted to a lossless target';

  @override
  String get transcodeSkipAlreadyCompliantLossless =>
      'Already within the target lossless spec';

  @override
  String get transcodeSkipAlreadyCompliantMp3 =>
      'Already matches the target MP3 sample rate and bitrate';

  @override
  String get transcodeSkipUnsupportedSourceFormat =>
      'Source format is not supported for transcoding';

  @override
  String get transcodeSkipNoOutputDirectory =>
      'Output folder is required for this output mode';

  @override
  String get transcodeSkipBinaryMissing => 'FFmpeg binaries are missing';

  @override
  String get transcodeOpenDownloadPage => 'Open FFmpeg download page';

  @override
  String get transcodeOpenDownloadPageSuccess => 'FFmpeg download page opened';

  @override
  String get transcodeOpenDownloadPageFailed =>
      'Failed to open FFmpeg download page';

  @override
  String get transcodeOpenBinaryFolder => 'Open FFmpeg folder';

  @override
  String get transcodeOpenBinaryFolderSuccess => 'FFmpeg folder opened';

  @override
  String get transcodeOpenBinaryFolderFailed => 'Failed to open FFmpeg folder';

  @override
  String get transcodeShowAll => 'Show all';

  @override
  String get transcodeShowReady => 'Only show ready';

  @override
  String get transcodeShowSkipped => 'Only show skipped';

  @override
  String get transcodeShowSuccess => 'Only show success';

  @override
  String get transcodeShowError => 'Only show errors';

  @override
  String get transcodeSortByName => 'By file name';

  @override
  String get transcodeSortByFormat => 'By format';

  @override
  String get transcodeSortBySampleRate => 'By sample rate';

  @override
  String get transcodeSortByStatus => 'By status';

  @override
  String get transcodeNoMatchTitle => 'No tasks match the current filter';

  @override
  String get transcodeNoMatchSubtitle => 'Adjust the filter to see your tasks';

  @override
  String get transcodeSettings => 'Resample settings';
}
