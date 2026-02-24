import 'package:flutter/material.dart';
import '../constants.dart';

class AppConfigs {
  final String? locale;
  final ThemeMode themeMode;
  final int themeHue;
  final String sortCriteria;
  final bool sortAscending;
  final String pattern;
  final FileFilter filter;
  final String artistSeparator;
  final FileAddMode singleFileAddMode;
  final FileAddMode directoryAddMode;
  final bool sidebarExpanded;

  const AppConfigs({
    required this.locale,
    required this.themeMode,
    required this.themeHue,
    required this.sortCriteria,
    required this.sortAscending,
    required this.pattern,
    required this.filter,
    required this.artistSeparator,
    required this.singleFileAddMode,
    required this.directoryAddMode,
    required this.sidebarExpanded,
  });

  static AppConfigs defaults() {
    return const AppConfigs(
      locale: AppConstants.defaultLocale,
      themeMode: AppConstants.defaultThemeMode,
      themeHue: AppConstants.defaultThemeHue,
      sortCriteria: AppConstants.defaultSortCriteria,
      sortAscending: AppConstants.defaultSortAscending,
      pattern: AppConstants.defaultNamingPattern,
      filter: AppConstants.defaultFileFilter,
      artistSeparator: AppConstants.defaultArtistSeparator,
      singleFileAddMode: AppConstants.defaultSingleFileAddMode,
      directoryAddMode: AppConstants.defaultDirectoryAddMode,
      sidebarExpanded: AppConstants.defaultSidebarExpanded,
    );
  }

  static AppConfigs fromJson(Map<String, dynamic> json) {
    final locale = json['locale'];
    final themeModeRaw = json['themeMode'];
    final themeHueRaw = json['themeHue'];
    final seedColorRaw = json['seedColor']; // legacy field
    final sortCriteriaRaw = json['sortCriteria'];
    final sortAscendingRaw = json['sortAscending'];
    final pattern = json['pattern'];
    final filterRaw = json['filter'];
    final artistSeparator = json['artistSeparator'];
    final singleFileAddModeRaw = json['singleFileAddMode'];
    final directoryAddModeRaw = json['directoryAddMode'];
    final sidebarExpandedRaw = json['sidebarExpanded'];

    return AppConfigs(
      locale: locale is String && locale.isNotEmpty ? locale : null,
      themeMode: _parseThemeMode(themeModeRaw),
      themeHue: _parseThemeHue(themeHueRaw, legacySeedColor: seedColorRaw),
      sortCriteria: _parseSortCriteria(sortCriteriaRaw),
      sortAscending: sortAscendingRaw is bool
          ? sortAscendingRaw
          : AppConstants.defaultSortAscending,
      pattern: pattern is String && pattern.isNotEmpty
          ? pattern
          : AppConstants.defaultNamingPattern,
      filter: _parseFilter(filterRaw),
      artistSeparator: _parseArtistSeparator(artistSeparator),
      singleFileAddMode: _parseFileAddMode(
        singleFileAddModeRaw,
        AppConstants.defaultSingleFileAddMode,
      ),
      directoryAddMode: _parseFileAddMode(
        directoryAddModeRaw,
        AppConstants.defaultDirectoryAddMode,
      ),
      sidebarExpanded: sidebarExpandedRaw is bool
          ? sidebarExpandedRaw
          : AppConstants.defaultSidebarExpanded,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'locale': locale,
      'themeMode': themeMode.name,
      'themeHue': themeHue,
      'sortCriteria': sortCriteria,
      'sortAscending': sortAscending,
      'pattern': pattern,
      'filter': filter.name,
      'artistSeparator': artistSeparator,
      'singleFileAddMode': singleFileAddMode.name,
      'directoryAddMode': directoryAddMode.name,
      'sidebarExpanded': sidebarExpanded,
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
    return AppConstants.defaultThemeMode;
  }

  static int _parseThemeHue(Object? raw, {Object? legacySeedColor}) {
    if (raw is int) {
      return _clampThemeHue(raw);
    }
    if (raw is num) {
      return _clampThemeHue(raw.round());
    }
    if (raw is String) {
      final parsed = int.tryParse(raw);
      if (parsed != null) {
        return _clampThemeHue(parsed);
      }
    }

    final legacyHue = _legacySeedColorToHue(legacySeedColor);
    if (legacyHue != null) {
      return legacyHue;
    }

    return AppConstants.defaultThemeHue;
  }

  static int _clampThemeHue(int hue) {
    return hue.clamp(AppConstants.themeHueMin, AppConstants.themeHueMax);
  }

  static int? _legacySeedColorToHue(Object? raw) {
    if (raw is! String) return null;
    return switch (raw) {
      'teal' => 180,
      'blue' => 220,
      'indigo' => 255,
      'purple' => 285,
      'pink' => 330,
      'orange' => 35,
      'green' => 140,
      'red' => 0,
      _ => null,
    };
  }

  static FileFilter _parseFilter(Object? raw) {
    if (raw is String) {
      for (final v in FileFilter.values) {
        if (v.name == raw) return v;
      }
    }
    return AppConstants.defaultFileFilter;
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
    return AppConstants.defaultSortCriteria;
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
    return AppConstants.defaultArtistSeparator;
  }

  @override
  bool operator ==(Object other) {
    return other is AppConfigs &&
        other.locale == locale &&
        other.themeMode == themeMode &&
        other.themeHue == themeHue &&
        other.sortCriteria == sortCriteria &&
        other.sortAscending == sortAscending &&
        other.pattern == pattern &&
        other.filter == filter &&
        other.artistSeparator == artistSeparator &&
        other.singleFileAddMode == singleFileAddMode &&
        other.directoryAddMode == directoryAddMode &&
        other.sidebarExpanded == sidebarExpanded;
  }

  @override
  int get hashCode => Object.hash(
    locale,
    themeMode,
    themeHue,
    sortCriteria,
    sortAscending,
    pattern,
    filter,
    artistSeparator,
    singleFileAddMode,
    directoryAddMode,
    sidebarExpanded,
  );
}
