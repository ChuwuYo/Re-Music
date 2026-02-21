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

  const AppConfigs({
    required this.locale,
    required this.themeMode,
    required this.seedColor,
    required this.sortCriteria,
    required this.sortAscending,
    required this.pattern,
    required this.filter,
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

  @override
  bool operator ==(Object other) {
    return other is AppConfigs &&
        other.locale == locale &&
        other.themeMode == themeMode &&
        other.seedColor == seedColor &&
        other.sortCriteria == sortCriteria &&
        other.sortAscending == sortAscending &&
        other.pattern == pattern &&
        other.filter == filter;
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
  );
}
