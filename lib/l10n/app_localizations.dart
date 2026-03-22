import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_zh.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('zh'),
  ];

  /// No description provided for @appTitle.
  ///
  /// In en, this message translates to:
  /// **'Re:Music'**
  String get appTitle;

  /// No description provided for @clearList.
  ///
  /// In en, this message translates to:
  /// **'Clear list'**
  String get clearList;

  /// No description provided for @language.
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get language;

  /// No description provided for @followSystem.
  ///
  /// In en, this message translates to:
  /// **'Auto'**
  String get followSystem;

  /// No description provided for @chinese.
  ///
  /// In en, this message translates to:
  /// **'简体中文'**
  String get chinese;

  /// No description provided for @english.
  ///
  /// In en, this message translates to:
  /// **'English'**
  String get english;

  /// No description provided for @switchToDark.
  ///
  /// In en, this message translates to:
  /// **'Dark mode'**
  String get switchToDark;

  /// No description provided for @switchToLight.
  ///
  /// In en, this message translates to:
  /// **'Light mode'**
  String get switchToLight;

  /// No description provided for @themeColor.
  ///
  /// In en, this message translates to:
  /// **'Theme color'**
  String get themeColor;

  /// No description provided for @themeHueLabel.
  ///
  /// In en, this message translates to:
  /// **'Hue'**
  String get themeHueLabel;

  /// No description provided for @addFiles.
  ///
  /// In en, this message translates to:
  /// **'Add files'**
  String get addFiles;

  /// No description provided for @scanDirectory.
  ///
  /// In en, this message translates to:
  /// **'Scan folder'**
  String get scanDirectory;

  /// No description provided for @namingMode.
  ///
  /// In en, this message translates to:
  /// **'Naming pattern'**
  String get namingMode;

  /// No description provided for @namingModeHint.
  ///
  /// In en, this message translates to:
  /// **'Choose or enter a custom pattern (e.g. {artist} - {title})'**
  String namingModeHint(Object artist, Object title);

  /// No description provided for @patternArtistTitle.
  ///
  /// In en, this message translates to:
  /// **'Artist - Title'**
  String get patternArtistTitle;

  /// No description provided for @patternTitleArtist.
  ///
  /// In en, this message translates to:
  /// **'Title - Artist'**
  String get patternTitleArtist;

  /// No description provided for @patternTrackTitle.
  ///
  /// In en, this message translates to:
  /// **'Track - Title'**
  String get patternTrackTitle;

  /// No description provided for @patternAlbumArtistTrackTitle.
  ///
  /// In en, this message translates to:
  /// **'Album Artist - Track - Title'**
  String get patternAlbumArtistTrackTitle;

  /// No description provided for @patternArtistAlbumTitle.
  ///
  /// In en, this message translates to:
  /// **'Artist - Album - Title'**
  String get patternArtistAlbumTitle;

  /// No description provided for @customPattern.
  ///
  /// In en, this message translates to:
  /// **'Custom pattern'**
  String get customPattern;

  /// No description provided for @filter.
  ///
  /// In en, this message translates to:
  /// **'Filter'**
  String get filter;

  /// No description provided for @showAll.
  ///
  /// In en, this message translates to:
  /// **'Show all'**
  String get showAll;

  /// No description provided for @showNoRenameNeeded.
  ///
  /// In en, this message translates to:
  /// **'Only show no-rename-needed'**
  String get showNoRenameNeeded;

  /// No description provided for @showNeedRename.
  ///
  /// In en, this message translates to:
  /// **'Only show needs rename'**
  String get showNeedRename;

  /// No description provided for @sort.
  ///
  /// In en, this message translates to:
  /// **'Sort'**
  String get sort;

  /// No description provided for @sortByName.
  ///
  /// In en, this message translates to:
  /// **'By file name'**
  String get sortByName;

  /// No description provided for @sortByArtist.
  ///
  /// In en, this message translates to:
  /// **'By artist'**
  String get sortByArtist;

  /// No description provided for @sortByTitle.
  ///
  /// In en, this message translates to:
  /// **'By title'**
  String get sortByTitle;

  /// No description provided for @sortBySize.
  ///
  /// In en, this message translates to:
  /// **'By size'**
  String get sortBySize;

  /// No description provided for @sortByModifiedTime.
  ///
  /// In en, this message translates to:
  /// **'By modified time'**
  String get sortByModifiedTime;

  /// No description provided for @emptyTitle.
  ///
  /// In en, this message translates to:
  /// **'Drop files here or click Add'**
  String get emptyTitle;

  /// No description provided for @emptySubtitle.
  ///
  /// In en, this message translates to:
  /// **'Supports MP3, FLAC, M4A and more'**
  String get emptySubtitle;

  /// No description provided for @noMatchTitle.
  ///
  /// In en, this message translates to:
  /// **'No files match the current filter'**
  String get noMatchTitle;

  /// No description provided for @noMatchSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Adjust the filter to see your files'**
  String get noMatchSubtitle;

  /// No description provided for @processingProgress.
  ///
  /// In en, this message translates to:
  /// **'Processing... {percent}%'**
  String processingProgress(int percent);

  /// No description provided for @totalFiles.
  ///
  /// In en, this message translates to:
  /// **'Total {count} files'**
  String totalFiles(int count);

  /// No description provided for @startRename.
  ///
  /// In en, this message translates to:
  /// **'Start'**
  String get startRename;

  /// No description provided for @renameCompleted.
  ///
  /// In en, this message translates to:
  /// **'Done! Renamed {count} files'**
  String renameCompleted(int count);

  /// No description provided for @readingMetadata.
  ///
  /// In en, this message translates to:
  /// **'Reading metadata...'**
  String get readingMetadata;

  /// No description provided for @readFailed.
  ///
  /// In en, this message translates to:
  /// **'Read failed'**
  String get readFailed;

  /// No description provided for @nameMatches.
  ///
  /// In en, this message translates to:
  /// **'Name matches'**
  String get nameMatches;

  /// No description provided for @renameToPrefix.
  ///
  /// In en, this message translates to:
  /// **'Rename to: '**
  String get renameToPrefix;

  /// No description provided for @unknownArtist.
  ///
  /// In en, this message translates to:
  /// **'Unknown artist'**
  String get unknownArtist;

  /// No description provided for @unknownTitle.
  ///
  /// In en, this message translates to:
  /// **'Unknown title'**
  String get unknownTitle;

  /// No description provided for @unknownAlbum.
  ///
  /// In en, this message translates to:
  /// **'Unknown album'**
  String get unknownAlbum;

  /// No description provided for @untitledTrack.
  ///
  /// In en, this message translates to:
  /// **'Untitled track'**
  String get untitledTrack;

  /// No description provided for @metadataReadFailed.
  ///
  /// In en, this message translates to:
  /// **'Failed to read metadata'**
  String get metadataReadFailed;

  /// No description provided for @unknownError.
  ///
  /// In en, this message translates to:
  /// **'Unknown error'**
  String get unknownError;

  /// No description provided for @editTags.
  ///
  /// In en, this message translates to:
  /// **'Edit tags'**
  String get editTags;

  /// No description provided for @metadataEditorTitle.
  ///
  /// In en, this message translates to:
  /// **'Edit metadata'**
  String get metadataEditorTitle;

  /// No description provided for @metadataTitle.
  ///
  /// In en, this message translates to:
  /// **'Title'**
  String get metadataTitle;

  /// No description provided for @metadataTrackArtist.
  ///
  /// In en, this message translates to:
  /// **'Track artist'**
  String get metadataTrackArtist;

  /// No description provided for @metadataAlbumArtist.
  ///
  /// In en, this message translates to:
  /// **'Album artist'**
  String get metadataAlbumArtist;

  /// No description provided for @metadataArtist.
  ///
  /// In en, this message translates to:
  /// **'Artist'**
  String get metadataArtist;

  /// No description provided for @metadataAlbum.
  ///
  /// In en, this message translates to:
  /// **'Album'**
  String get metadataAlbum;

  /// No description provided for @metadataTrackNumber.
  ///
  /// In en, this message translates to:
  /// **'Track No.'**
  String get metadataTrackNumber;

  /// No description provided for @metadataTrackTotal.
  ///
  /// In en, this message translates to:
  /// **'Total tracks'**
  String get metadataTrackTotal;

  /// No description provided for @metadataYear.
  ///
  /// In en, this message translates to:
  /// **'Year'**
  String get metadataYear;

  /// No description provided for @metadataGenre.
  ///
  /// In en, this message translates to:
  /// **'Genre'**
  String get metadataGenre;

  /// No description provided for @metadataLanguage.
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get metadataLanguage;

  /// No description provided for @metadataComment.
  ///
  /// In en, this message translates to:
  /// **'Comment'**
  String get metadataComment;

  /// No description provided for @apply.
  ///
  /// In en, this message translates to:
  /// **'Apply'**
  String get apply;

  /// No description provided for @confirm.
  ///
  /// In en, this message translates to:
  /// **'Confirm'**
  String get confirm;

  /// No description provided for @cancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get cancel;

  /// No description provided for @close.
  ///
  /// In en, this message translates to:
  /// **'Close'**
  String get close;

  /// No description provided for @invalidNumber.
  ///
  /// In en, this message translates to:
  /// **'Please enter a valid number'**
  String get invalidNumber;

  /// No description provided for @sortAscending.
  ///
  /// In en, this message translates to:
  /// **'Ascending'**
  String get sortAscending;

  /// No description provided for @sortDescending.
  ///
  /// In en, this message translates to:
  /// **'Descending'**
  String get sortDescending;

  /// No description provided for @sidebarExpand.
  ///
  /// In en, this message translates to:
  /// **'Expand sidebar'**
  String get sidebarExpand;

  /// No description provided for @sidebarCollapse.
  ///
  /// In en, this message translates to:
  /// **'Collapse sidebar'**
  String get sidebarCollapse;

  /// No description provided for @sidebarTooNarrow.
  ///
  /// In en, this message translates to:
  /// **'Window too narrow — resize to expand'**
  String get sidebarTooNarrow;

  /// No description provided for @navHome.
  ///
  /// In en, this message translates to:
  /// **'Home'**
  String get navHome;

  /// No description provided for @navSettings.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get navSettings;

  /// No description provided for @appearance.
  ///
  /// In en, this message translates to:
  /// **'Appearance'**
  String get appearance;

  /// No description provided for @themeMode.
  ///
  /// In en, this message translates to:
  /// **'Theme mode'**
  String get themeMode;

  /// No description provided for @renameSettings.
  ///
  /// In en, this message translates to:
  /// **'Rename settings'**
  String get renameSettings;

  /// No description provided for @singleFileAddMode.
  ///
  /// In en, this message translates to:
  /// **'When adding single file'**
  String get singleFileAddMode;

  /// No description provided for @directoryAddMode.
  ///
  /// In en, this message translates to:
  /// **'When scanning directory'**
  String get directoryAddMode;

  /// No description provided for @addModeAppend.
  ///
  /// In en, this message translates to:
  /// **'Append to list'**
  String get addModeAppend;

  /// No description provided for @addModeReplace.
  ///
  /// In en, this message translates to:
  /// **'Replace existing list'**
  String get addModeReplace;

  /// No description provided for @artistSeparator.
  ///
  /// In en, this message translates to:
  /// **'Artist separator'**
  String get artistSeparator;

  /// No description provided for @artistSeparatorHint.
  ///
  /// In en, this message translates to:
  /// **'Separator for multiple artists'**
  String get artistSeparatorHint;

  /// No description provided for @navTranscode.
  ///
  /// In en, this message translates to:
  /// **'Transcode'**
  String get navTranscode;

  /// No description provided for @transcodeTitle.
  ///
  /// In en, this message translates to:
  /// **'Transcode'**
  String get transcodeTitle;

  /// No description provided for @transcodeStart.
  ///
  /// In en, this message translates to:
  /// **'Start transcode'**
  String get transcodeStart;

  /// No description provided for @transcodeCompleted.
  ///
  /// In en, this message translates to:
  /// **'Done! Processed {count} files'**
  String transcodeCompleted(int count);

  /// No description provided for @transcodeProgress.
  ///
  /// In en, this message translates to:
  /// **'Processing... {percent}%'**
  String transcodeProgress(int percent);

  /// No description provided for @transcodeTotalFiles.
  ///
  /// In en, this message translates to:
  /// **'Total {count} tasks'**
  String transcodeTotalFiles(int count);

  /// No description provided for @transcodeEmptyTitle.
  ///
  /// In en, this message translates to:
  /// **'Add audio files to start resampling'**
  String get transcodeEmptyTitle;

  /// No description provided for @transcodeEmptySubtitle.
  ///
  /// In en, this message translates to:
  /// **'Probe results, skip reasons, and output paths will appear here'**
  String get transcodeEmptySubtitle;

  /// No description provided for @transcodeOutputFormat.
  ///
  /// In en, this message translates to:
  /// **'Output format'**
  String get transcodeOutputFormat;

  /// No description provided for @transcodePreset.
  ///
  /// In en, this message translates to:
  /// **'Lossless preset'**
  String get transcodePreset;

  /// No description provided for @transcodeMp3Bitrate.
  ///
  /// In en, this message translates to:
  /// **'MP3 bitrate'**
  String get transcodeMp3Bitrate;

  /// No description provided for @transcodeAllowFormatOnly.
  ///
  /// In en, this message translates to:
  /// **'Convert files that only need a format change'**
  String get transcodeAllowFormatOnly;

  /// No description provided for @transcodeEnableDither.
  ///
  /// In en, this message translates to:
  /// **'Enable triangular dither'**
  String get transcodeEnableDither;

  /// No description provided for @transcodeEnableDitherSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Reduces quantization noise when lowering bit depth'**
  String get transcodeEnableDitherSubtitle;

  /// No description provided for @transcodeConcurrency.
  ///
  /// In en, this message translates to:
  /// **'Concurrency'**
  String get transcodeConcurrency;

  /// No description provided for @transcodeKeepOriginal.
  ///
  /// In en, this message translates to:
  /// **'Keep original'**
  String get transcodeKeepOriginal;

  /// No description provided for @transcodeReplaceOriginal.
  ///
  /// In en, this message translates to:
  /// **'Replace original'**
  String get transcodeReplaceOriginal;

  /// No description provided for @transcodeOutputDirectory.
  ///
  /// In en, this message translates to:
  /// **'Output directory'**
  String get transcodeOutputDirectory;

  /// No description provided for @transcodeChooseOutputDirectory.
  ///
  /// In en, this message translates to:
  /// **'Choose output folder'**
  String get transcodeChooseOutputDirectory;

  /// No description provided for @transcodeOutputDirectoryRequired.
  ///
  /// In en, this message translates to:
  /// **'Choose an output folder first'**
  String get transcodeOutputDirectoryRequired;

  /// No description provided for @transcodeFormatFlac.
  ///
  /// In en, this message translates to:
  /// **'FLAC'**
  String get transcodeFormatFlac;

  /// No description provided for @transcodeFormatWav.
  ///
  /// In en, this message translates to:
  /// **'WAV'**
  String get transcodeFormatWav;

  /// No description provided for @transcodeFormatAlac.
  ///
  /// In en, this message translates to:
  /// **'ALAC (.m4a)'**
  String get transcodeFormatAlac;

  /// No description provided for @transcodeFormatMp3.
  ///
  /// In en, this message translates to:
  /// **'MP3'**
  String get transcodeFormatMp3;

  /// No description provided for @transcodePresetStudio24.
  ///
  /// In en, this message translates to:
  /// **'48kHz / 24bit'**
  String get transcodePresetStudio24;

  /// No description provided for @transcodePresetCd24.
  ///
  /// In en, this message translates to:
  /// **'44.1kHz / 24bit'**
  String get transcodePresetCd24;

  /// No description provided for @transcodePresetCd16.
  ///
  /// In en, this message translates to:
  /// **'44.1kHz / 16bit'**
  String get transcodePresetCd16;

  /// No description provided for @transcodeTaskTarget.
  ///
  /// In en, this message translates to:
  /// **'Target'**
  String get transcodeTaskTarget;

  /// No description provided for @transcodeTaskOutput.
  ///
  /// In en, this message translates to:
  /// **'Output'**
  String get transcodeTaskOutput;

  /// No description provided for @transcodeTaskUnknownOutput.
  ///
  /// In en, this message translates to:
  /// **'Pending output path'**
  String get transcodeTaskUnknownOutput;

  /// No description provided for @transcodeTaskUnknownProbe.
  ///
  /// In en, this message translates to:
  /// **'Probe pending'**
  String get transcodeTaskUnknownProbe;

  /// No description provided for @transcodeStatusProbing.
  ///
  /// In en, this message translates to:
  /// **'Probing'**
  String get transcodeStatusProbing;

  /// No description provided for @transcodeStatusReady.
  ///
  /// In en, this message translates to:
  /// **'Ready'**
  String get transcodeStatusReady;

  /// No description provided for @transcodeStatusSkipped.
  ///
  /// In en, this message translates to:
  /// **'Skipped'**
  String get transcodeStatusSkipped;

  /// No description provided for @transcodeStatusQueued.
  ///
  /// In en, this message translates to:
  /// **'Queued'**
  String get transcodeStatusQueued;

  /// No description provided for @transcodeStatusRunning.
  ///
  /// In en, this message translates to:
  /// **'Running'**
  String get transcodeStatusRunning;

  /// No description provided for @transcodeStatusSuccess.
  ///
  /// In en, this message translates to:
  /// **'Success'**
  String get transcodeStatusSuccess;

  /// No description provided for @transcodeStatusError.
  ///
  /// In en, this message translates to:
  /// **'Error'**
  String get transcodeStatusError;

  /// No description provided for @transcodeSkipLossyToLossless.
  ///
  /// In en, this message translates to:
  /// **'Lossy input cannot be converted to a lossless target'**
  String get transcodeSkipLossyToLossless;

  /// No description provided for @transcodeSkipAlreadyCompliantLossless.
  ///
  /// In en, this message translates to:
  /// **'Already within the target lossless spec'**
  String get transcodeSkipAlreadyCompliantLossless;

  /// No description provided for @transcodeSkipAlreadyCompliantMp3.
  ///
  /// In en, this message translates to:
  /// **'Already matches the target MP3 sample rate and bitrate'**
  String get transcodeSkipAlreadyCompliantMp3;

  /// No description provided for @transcodeSkipUnsupportedSourceFormat.
  ///
  /// In en, this message translates to:
  /// **'Source format is not supported for transcoding'**
  String get transcodeSkipUnsupportedSourceFormat;

  /// No description provided for @transcodeSkipNoOutputDirectory.
  ///
  /// In en, this message translates to:
  /// **'Output folder is required for this output mode'**
  String get transcodeSkipNoOutputDirectory;

  /// No description provided for @transcodeSkipBinaryMissing.
  ///
  /// In en, this message translates to:
  /// **'FFmpeg binaries are missing'**
  String get transcodeSkipBinaryMissing;

  /// No description provided for @transcodeOpenDownloadPage.
  ///
  /// In en, this message translates to:
  /// **'Open FFmpeg download page'**
  String get transcodeOpenDownloadPage;

  /// No description provided for @transcodeOpenDownloadPageSuccess.
  ///
  /// In en, this message translates to:
  /// **'FFmpeg download page opened'**
  String get transcodeOpenDownloadPageSuccess;

  /// No description provided for @transcodeOpenDownloadPageFailed.
  ///
  /// In en, this message translates to:
  /// **'Failed to open FFmpeg download page'**
  String get transcodeOpenDownloadPageFailed;

  /// No description provided for @transcodeOpenBinaryFolder.
  ///
  /// In en, this message translates to:
  /// **'Open FFmpeg folder'**
  String get transcodeOpenBinaryFolder;

  /// No description provided for @transcodeOpenBinaryFolderSuccess.
  ///
  /// In en, this message translates to:
  /// **'FFmpeg folder opened'**
  String get transcodeOpenBinaryFolderSuccess;

  /// No description provided for @transcodeOpenBinaryFolderFailed.
  ///
  /// In en, this message translates to:
  /// **'Failed to open FFmpeg folder'**
  String get transcodeOpenBinaryFolderFailed;

  /// No description provided for @transcodeShowAll.
  ///
  /// In en, this message translates to:
  /// **'Show all'**
  String get transcodeShowAll;

  /// No description provided for @transcodeShowReady.
  ///
  /// In en, this message translates to:
  /// **'Only show ready'**
  String get transcodeShowReady;

  /// No description provided for @transcodeShowSkipped.
  ///
  /// In en, this message translates to:
  /// **'Only show skipped'**
  String get transcodeShowSkipped;

  /// No description provided for @transcodeShowSuccess.
  ///
  /// In en, this message translates to:
  /// **'Only show success'**
  String get transcodeShowSuccess;

  /// No description provided for @transcodeShowError.
  ///
  /// In en, this message translates to:
  /// **'Only show errors'**
  String get transcodeShowError;

  /// No description provided for @transcodeSortByName.
  ///
  /// In en, this message translates to:
  /// **'By file name'**
  String get transcodeSortByName;

  /// No description provided for @transcodeSortByFormat.
  ///
  /// In en, this message translates to:
  /// **'By format'**
  String get transcodeSortByFormat;

  /// No description provided for @transcodeSortBySampleRate.
  ///
  /// In en, this message translates to:
  /// **'By sample rate'**
  String get transcodeSortBySampleRate;

  /// No description provided for @transcodeSortByStatus.
  ///
  /// In en, this message translates to:
  /// **'By status'**
  String get transcodeSortByStatus;

  /// No description provided for @transcodeNoMatchTitle.
  ///
  /// In en, this message translates to:
  /// **'No tasks match the current filter'**
  String get transcodeNoMatchTitle;

  /// No description provided for @transcodeNoMatchSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Adjust the filter to see your tasks'**
  String get transcodeNoMatchSubtitle;

  /// No description provided for @transcodeSettings.
  ///
  /// In en, this message translates to:
  /// **'Resample settings'**
  String get transcodeSettings;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['en', 'zh'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'zh':
      return AppLocalizationsZh();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
