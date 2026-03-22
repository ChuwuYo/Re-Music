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
  final TranscodeOutputFormat transcodeOutputFormat;
  final TranscodeLosslessPreset transcodeLosslessPreset;
  final int transcodeMp3BitRateKbps;
  final bool allowFormatOnlyConversion;
  final bool enableTranscodeDither;
  final TranscodeOutputMode transcodeOutputMode;
  final String? transcodeOutputDirectory;
  final int transcodeConcurrency;

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
    required this.transcodeOutputFormat,
    required this.transcodeLosslessPreset,
    required this.transcodeMp3BitRateKbps,
    required this.allowFormatOnlyConversion,
    required this.enableTranscodeDither,
    required this.transcodeOutputMode,
    required this.transcodeOutputDirectory,
    required this.transcodeConcurrency,
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
      transcodeOutputFormat: AppConstants.defaultTranscodeOutputFormat,
      transcodeLosslessPreset: AppConstants.defaultTranscodeLosslessPreset,
      transcodeMp3BitRateKbps: AppConstants.defaultTranscodeMp3BitRateKbps,
      allowFormatOnlyConversion: AppConstants.defaultAllowFormatOnlyConversion,
      enableTranscodeDither: AppConstants.defaultEnableTranscodeDither,
      transcodeOutputMode: AppConstants.defaultTranscodeOutputMode,
      transcodeOutputDirectory: null,
      transcodeConcurrency: AppConstants.defaultTranscodeConcurrency,
    );
  }

  static AppConfigs fromJson(Map<String, dynamic> json) {
    final locale = json['locale'];
    final themeModeRaw = json['themeMode'];
    final themeHueRaw = json['themeHue'];
    final seedColorRaw = json['seedColor'];
    final sortCriteriaRaw = json['sortCriteria'];
    final sortAscendingRaw = json['sortAscending'];
    final pattern = json['pattern'];
    final filterRaw = json['filter'];
    final artistSeparator = json['artistSeparator'];
    final singleFileAddModeRaw = json['singleFileAddMode'];
    final directoryAddModeRaw = json['directoryAddMode'];
    final sidebarExpandedRaw = json['sidebarExpanded'];
    final transcodeOutputFormatRaw = json['transcodeOutputFormat'];
    final transcodeLosslessPresetRaw = json['transcodeLosslessPreset'];
    final transcodeMp3BitRateKbpsRaw = json['transcodeMp3BitRateKbps'];
    final allowFormatOnlyConversionRaw = json['allowFormatOnlyConversion'];
    final enableTranscodeDitherRaw = json['enableTranscodeDither'];
    final transcodeOutputModeRaw = json['transcodeOutputMode'];
    final transcodeOutputDirectoryRaw = json['transcodeOutputDirectory'];
    final transcodeConcurrencyRaw = json['transcodeConcurrency'];

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
      transcodeOutputFormat: _parseTranscodeOutputFormat(
        transcodeOutputFormatRaw,
      ),
      transcodeLosslessPreset: _parseTranscodeLosslessPreset(
        transcodeLosslessPresetRaw,
      ),
      transcodeMp3BitRateKbps: _parseTranscodeMp3BitRateKbps(
        transcodeMp3BitRateKbpsRaw,
      ),
      allowFormatOnlyConversion: allowFormatOnlyConversionRaw is bool
          ? allowFormatOnlyConversionRaw
          : AppConstants.defaultAllowFormatOnlyConversion,
      enableTranscodeDither: enableTranscodeDitherRaw is bool
          ? enableTranscodeDitherRaw
          : AppConstants.defaultEnableTranscodeDither,
      transcodeOutputMode: _parseSafeTranscodeOutputMode(
        transcodeOutputModeRaw,
        transcodeOutputDirectoryRaw,
      ),
      transcodeOutputDirectory: _parseTranscodeOutputDirectory(
        transcodeOutputDirectoryRaw,
      ),
      transcodeConcurrency: _parseTranscodeConcurrency(transcodeConcurrencyRaw),
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
      'transcodeOutputFormat': transcodeOutputFormat.name,
      'transcodeLosslessPreset': transcodeLosslessPreset.name,
      'transcodeMp3BitRateKbps': transcodeMp3BitRateKbps,
      'allowFormatOnlyConversion': allowFormatOnlyConversion,
      'enableTranscodeDither': enableTranscodeDither,
      'transcodeOutputMode': transcodeOutputMode.name,
      'transcodeOutputDirectory': transcodeOutputDirectory,
      'transcodeConcurrency': transcodeConcurrency,
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
    return hue
        .clamp(AppConstants.themeHueMin, AppConstants.themeHueMax)
        .toInt();
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

  static TranscodeOutputFormat _parseTranscodeOutputFormat(Object? raw) {
    if (raw is String) {
      for (final v in TranscodeOutputFormat.values) {
        if (v.name == raw) return v;
      }
    }
    return AppConstants.defaultTranscodeOutputFormat;
  }

  static TranscodeLosslessPreset _parseTranscodeLosslessPreset(Object? raw) {
    if (raw is String) {
      for (final v in TranscodeLosslessPreset.values) {
        if (v.name == raw) return v;
      }
    }
    return AppConstants.defaultTranscodeLosslessPreset;
  }

  static int _parseTranscodeMp3BitRateKbps(Object? raw) {
    final parsed = switch (raw) {
      int value => value,
      num value => value.round(),
      String value => int.tryParse(value),
      _ => null,
    };
    if (parsed != null &&
        AppConstants.transcodeMp3BitRateOptions.contains(parsed)) {
      return parsed;
    }
    return AppConstants.defaultTranscodeMp3BitRateKbps;
  }

  static TranscodeOutputMode _parseTranscodeOutputMode(Object? raw) {
    if (raw is String) {
      for (final v in TranscodeOutputMode.values) {
        if (v.name == raw) return v;
      }
    }
    return AppConstants.defaultTranscodeOutputMode;
  }

  static TranscodeOutputMode _parseSafeTranscodeOutputMode(
    Object? raw,
    Object? directoryRaw,
  ) {
    final mode = _parseTranscodeOutputMode(raw);
    if (mode == TranscodeOutputMode.outputDirectory &&
        _parseTranscodeOutputDirectory(directoryRaw) == null) {
      return AppConstants.defaultTranscodeOutputMode;
    }
    return mode;
  }

  static String? _parseTranscodeOutputDirectory(Object? raw) {
    if (raw is! String) return null;
    final trimmed = raw.trim();
    return trimmed.isEmpty ? null : trimmed;
  }

  static int _parseTranscodeConcurrency(Object? raw) {
    final parsed = switch (raw) {
      int value => value,
      num value => value.round(),
      String value => int.tryParse(value),
      _ => null,
    };
    if (parsed == null) return AppConstants.defaultTranscodeConcurrency;
    return parsed
        .clamp(
          AppConstants.transcodeConcurrencyMin,
          AppConstants.transcodeConcurrencyMax,
        )
        .toInt();
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
        other.sidebarExpanded == sidebarExpanded &&
        other.transcodeOutputFormat == transcodeOutputFormat &&
        other.transcodeLosslessPreset == transcodeLosslessPreset &&
        other.transcodeMp3BitRateKbps == transcodeMp3BitRateKbps &&
        other.allowFormatOnlyConversion == allowFormatOnlyConversion &&
        other.enableTranscodeDither == enableTranscodeDither &&
        other.transcodeOutputMode == transcodeOutputMode &&
        other.transcodeOutputDirectory == transcodeOutputDirectory &&
        other.transcodeConcurrency == transcodeConcurrency;
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
    transcodeOutputFormat,
    transcodeLosslessPreset,
    transcodeMp3BitRateKbps,
    allowFormatOnlyConversion,
    enableTranscodeDither,
    transcodeOutputMode,
    transcodeOutputDirectory,
    transcodeConcurrency,
  );
}
