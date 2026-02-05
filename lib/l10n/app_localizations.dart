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
  /// **'Follow system'**
  String get followSystem;

  /// No description provided for @chinese.
  ///
  /// In en, this message translates to:
  /// **'中文'**
  String get chinese;

  /// No description provided for @english.
  ///
  /// In en, this message translates to:
  /// **'English'**
  String get english;

  /// No description provided for @switchToDark.
  ///
  /// In en, this message translates to:
  /// **'Switch to dark mode'**
  String get switchToDark;

  /// No description provided for @switchToLight.
  ///
  /// In en, this message translates to:
  /// **'Switch to light mode'**
  String get switchToLight;

  /// No description provided for @themeColor.
  ///
  /// In en, this message translates to:
  /// **'Theme color'**
  String get themeColor;

  /// No description provided for @themeColorTeal.
  ///
  /// In en, this message translates to:
  /// **'Teal'**
  String get themeColorTeal;

  /// No description provided for @themeColorBlue.
  ///
  /// In en, this message translates to:
  /// **'Blue'**
  String get themeColorBlue;

  /// No description provided for @themeColorIndigo.
  ///
  /// In en, this message translates to:
  /// **'Indigo'**
  String get themeColorIndigo;

  /// No description provided for @themeColorPurple.
  ///
  /// In en, this message translates to:
  /// **'Purple'**
  String get themeColorPurple;

  /// No description provided for @themeColorPink.
  ///
  /// In en, this message translates to:
  /// **'Pink'**
  String get themeColorPink;

  /// No description provided for @themeColorOrange.
  ///
  /// In en, this message translates to:
  /// **'Orange'**
  String get themeColorOrange;

  /// No description provided for @themeColorGreen.
  ///
  /// In en, this message translates to:
  /// **'Green'**
  String get themeColorGreen;

  /// No description provided for @themeColorRed.
  ///
  /// In en, this message translates to:
  /// **'Red'**
  String get themeColorRed;

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
