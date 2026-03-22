import '../constants.dart';

class ArtistNameService {
  ArtistNameService._();

  static final RegExp _artistSplitPattern = RegExp(
    AppConstants.artistSplitPatternParts.join('|'),
    caseSensitive: false,
  );

  static List<String> splitArtists(String? rawValue) {
    if (rawValue == null) return const [];

    final normalized = rawValue
        .replaceAll(RegExp(r'[\u200B-\u200D\uFEFF]'), '')
        .trim();
    if (normalized.isEmpty) return const [];

    final parts = normalized
        .split(_artistSplitPattern)
        .map((value) => value.trim())
        .where((value) => value.isNotEmpty)
        .toList();

    if (parts.isEmpty) return const [];

    final unique = <String>[];
    for (final value in parts) {
      if (!unique.contains(value)) {
        unique.add(value);
      }
    }
    return unique;
  }

  static List<String> mergeArtistSources({
    Iterable<String?> rawValues = const [],
    Iterable<Iterable<String>> collections = const [],
  }) {
    final merged = <String>[];

    void addValues(Iterable<String> values) {
      for (final value in values) {
        final trimmed = value.trim();
        if (trimmed.isEmpty || merged.contains(trimmed)) continue;
        merged.add(trimmed);
      }
    }

    for (final value in rawValues) {
      addValues(splitArtists(value));
    }
    for (final values in collections) {
      addValues(values);
    }

    return merged;
  }

  static String joinArtists(
    Iterable<String> artists, {
    String separator = AppConstants.internalArtistDisplaySeparator,
    String fallback = '',
  }) {
    final safeSeparator =
        separator == AppConstants.internalArtistDisplaySeparator
        ? AppConstants.internalArtistDisplaySeparator
        : AppConstants.isValidArtistSeparator(separator)
        ? separator
        : AppConstants.defaultArtistSeparator;
    // Deduplicate without re-splitting — callers are responsible for splitting.
    final unique = <String>[];
    for (final value in artists) {
      final trimmed = value.trim();
      if (trimmed.isNotEmpty && !unique.contains(trimmed)) {
        unique.add(trimmed);
      }
    }
    if (unique.isEmpty) return fallback;
    return unique.join(safeSeparator);
  }

  static String normalizeArtists(
    String? rawValue, {
    String separator = AppConstants.internalArtistDisplaySeparator,
    String fallback = '',
  }) {
    return joinArtists(
      splitArtists(rawValue),
      separator: separator,
      fallback: fallback,
    );
  }
}
