import 'package:flutter/material.dart';
import '../constants.dart';

class AppConfigs {
  final String? locale;
  final ThemeMode themeMode;
  final AppSeedColor seedColor;
  final String sortCriteria;
  final bool sortAscending;
  final String pattern;
  final FileFilter filter;
  final String artistSeparator;
  final FileAddMode singleFileAddMode;
  final FileAddMode directoryAddMode;

  const AppConfigs({
    required this.locale,
    required this.themeMode,
    required this.seedColor,
    required this.sortCriteria,
    required this.sortAscending,
    required this.pattern,
    required this.filter,
    required this.artistSeparator,
    required this.singleFileAddMode,
    required this.directoryAddMode,
  });

  static AppConfigs defaults() {
    return const AppConfigs(
      locale: AppConstants.defaultLocale,
      themeMode: AppConstants.defaultThemeMode,
      seedColor: AppConstants.defaultSeedColor,
      sortCriteria: AppConstants.defaultSortCriteria,
      sortAscending: AppConstants.defaultSortAscending,
      pattern: AppConstants.defaultNamingPattern,
      filter: AppConstants.defaultFileFilter,
      artistSeparator: AppConstants.defaultArtistSeparator,
      singleFileAddMode: AppConstants.defaultSingleFileAddMode,
      directoryAddMode: AppConstants.defaultDirectoryAddMode,
    );
  }

  static AppConfigs fromJson(Map<String, dynamic> json) {
    final locale = json['locale'];
    final themeModeRaw = json['themeMode'];
    final seedColorRaw = json['seedColor'];
    final sortCriteriaRaw = json['sortCriteria'];
    final sortAscendingRaw = json['sortAscending'];
    final pattern = json['pattern'];
    final filterRaw = json['filter'];
    final artistSeparator = json['artistSeparator'];
    final singleFileAddModeRaw = json['singleFileAddMode'];
    final directoryAddModeRaw = json['directoryAddMode'];

    return AppConfigs(
      locale: locale is String && locale.isNotEmpty ? locale : null,
      themeMode: _parseThemeMode(themeModeRaw),
      seedColor: _parseSeedColor(seedColorRaw),
      sortCriteria: _parseSortCriteria(sortCriteriaRaw),
      sortAscending: sortAscendingRaw is bool
          ? sortAscendingRaw
          : AppConstants.defaultSortAscending,
      pattern: pattern is String && pattern.isNotEmpty
          ? pattern
          : AppConfigs.defaults().pattern,
      filter: _parseFilter(filterRaw),
      artistSeparator: _parseArtistSeparator(artistSeparator),
      singleFileAddMode: _parseFileAddMode(
        singleFileAddModeRaw,
        AppConfigs.defaults().singleFileAddMode,
      ),
      directoryAddMode: _parseFileAddMode(
        directoryAddModeRaw,
        AppConfigs.defaults().directoryAddMode,
      ),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'locale': locale,
      'themeMode': themeMode.name,
      'seedColor': seedColor.name,
      'sortCriteria': sortCriteria,
      'sortAscending': sortAscending,
      'pattern': pattern,
      'filter': filter.name,
      'artistSeparator': artistSeparator,
      'singleFileAddMode': singleFileAddMode.name,
      'directoryAddMode': directoryAddMode.name,
    };
  }

  static ThemeMode _parseThemeMode(Object? raw) {
    if (raw is String) {
      switch (raw) {
        case 'dark':
          return ThemeMode.dark;
        case 'light':
          return ThemeMode.light;
      }
    }
    return AppConfigs.defaults().themeMode;
  }

  static AppSeedColor _parseSeedColor(Object? raw) {
    if (raw is String) {
      for (final v in AppSeedColor.values) {
        if (v.name == raw) return v;
      }
    }
    return AppConfigs.defaults().seedColor;
  }

  static FileFilter _parseFilter(Object? raw) {
    if (raw is String) {
      for (final v in FileFilter.values) {
        if (v.name == raw) return v;
      }
    }
    return AppConfigs.defaults().filter;
  }

  static String _parseSortCriteria(Object? raw) {
    if (raw is String) {
      switch (raw) {
        case 'name':
        case 'artist':
        case 'title':
        case 'size':
        case 'modified':
          return raw;
      }
    }
    return AppConfigs.defaults().sortCriteria;
  }

  static FileAddMode _parseFileAddMode(Object? raw, FileAddMode fallback) {
    if (raw is String) {
      for (final v in FileAddMode.values) {
        if (v.name == raw) return v;
      }
    }
    return fallback;
  }

  static String _parseArtistSeparator(Object? raw) {
    if (raw is String && AppConstants.isValidArtistSeparator(raw)) {
      return raw;
    }
    return AppConfigs.defaults().artistSeparator;
  }

  @override
  bool operator ==(Object other) {
    return other is AppConfigs &&
        other.locale == locale &&
        other.themeMode == themeMode &&
        other.seedColor == seedColor &&
        other.sortCriteria == sortCriteria &&
        other.sortAscending == sortAscending &&
        other.pattern == pattern &&
        other.filter == filter &&
        other.artistSeparator == artistSeparator &&
        other.singleFileAddMode == singleFileAddMode &&
        other.directoryAddMode == directoryAddMode;
  }

  @override
  int get hashCode => Object.hash(
    locale,
    themeMode,
    seedColor,
    sortCriteria,
    sortAscending,
    pattern,
    filter,
    artistSeparator,
    singleFileAddMode,
    directoryAddMode,
  );
}
