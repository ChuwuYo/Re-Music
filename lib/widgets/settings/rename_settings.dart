import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../constants.dart';
import '../../l10n/app_localizations.dart';
import '../../providers/audio_provider.dart';
import '../common/selectable_card.dart';

class RenameSettings extends StatelessWidget {
  const RenameSettings({super.key});

  @override
  Widget build(BuildContext context) {
    return const Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _FileAddModeSelector(),
        SizedBox(height: AppConstants.spacingLarge),
        _ArtistSeparatorSelector(),
      ],
    );
  }
}

class _FileAddModeSelector extends StatelessWidget {
  const _FileAddModeSelector();

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final singleFileAddMode = context.select<AudioProvider, FileAddMode>(
      (provider) => provider.singleFileAddMode,
    );
    final directoryAddMode = context.select<AudioProvider, FileAddMode>(
      (provider) => provider.directoryAddMode,
    );
    final setSingleFileAddMode = context
        .read<AudioProvider>()
        .setSingleFileAddMode;
    final setDirectoryAddMode = context
        .read<AudioProvider>()
        .setDirectoryAddMode;

    return LayoutBuilder(
      builder: (context, constraints) {
        final isNarrow =
            constraints.maxWidth < AppConstants.renameSettingsNarrowWidth;

        return Wrap(
          spacing: AppConstants.spacingMedium,
          runSpacing: AppConstants.spacingMedium,
          alignment: WrapAlignment.start,
          children: [
            SizedBox(
              width: isNarrow
                  ? double.infinity
                  : (constraints.maxWidth - AppConstants.spacingMedium) / 2,
              child: _AddModeColumn(
                title: l10n.singleFileAddMode,
                currentMode: singleFileAddMode,
                onModeChanged: setSingleFileAddMode,
                l10n: l10n,
              ),
            ),
            SizedBox(
              width: isNarrow
                  ? double.infinity
                  : (constraints.maxWidth - AppConstants.spacingMedium) / 2,
              child: _AddModeColumn(
                title: l10n.directoryAddMode,
                currentMode: directoryAddMode,
                onModeChanged: setDirectoryAddMode,
                l10n: l10n,
              ),
            ),
          ],
        );
      },
    );
  }
}

class _AddModeColumn extends StatelessWidget {
  final String title;
  final FileAddMode currentMode;
  final void Function(FileAddMode) onModeChanged;
  final AppLocalizations l10n;

  const _AddModeColumn({
    required this.title,
    required this.currentMode,
    required this.onModeChanged,
    required this.l10n,
  });

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final options = <MapEntry<FileAddMode, String>>[
      MapEntry(FileAddMode.append, l10n.addModeAppend),
      MapEntry(FileAddMode.replace, l10n.addModeReplace),
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          title,
          style: Theme.of(
            context,
          ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w500),
        ),
        const SizedBox(height: AppConstants.spacingMediumSmall),
        Wrap(
          spacing: AppConstants.spacingSmall,
          runSpacing: AppConstants.spacingSmall,
          children: options.map((option) {
            final mode = option.key;
            final label = option.value;
            final isSelected = currentMode == mode;

            return SelectableCard(
              isSelected: isSelected,
              onTap: () => onModeChanged(mode),
              child: Text(
                label,
                style: TextStyle(
                  color: isSelected ? scheme.primary : scheme.onSurface,
                  fontWeight: isSelected ? FontWeight.w500 : FontWeight.normal,
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }
}

class _ArtistSeparatorSelector extends StatelessWidget {
  const _ArtistSeparatorSelector();

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final selectedSeparator = context.select<AudioProvider, String>(
      (provider) => provider.artistSeparator,
    );
    final setArtistSeparator = context.read<AudioProvider>().setArtistSeparator;
    final scheme = Theme.of(context).colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          l10n.artistSeparator,
          style: Theme.of(
            context,
          ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w500),
        ),
        const SizedBox(height: AppConstants.spacingMediumSmall),
        Wrap(
          spacing: AppConstants.spacingSmall,
          runSpacing: AppConstants.spacingSmall,
          children: AppConstants.artistSeparatorOptions.map((sep) {
            final isSelected = selectedSeparator == sep;
            return SizedBox(
              width: AppConstants.artistSeparatorOptionWidth,
              child: SelectableCard(
                isSelected: isSelected,
                onTap: () => setArtistSeparator(sep),
                child: Center(
                  child: Text(
                    sep,
                    style: TextStyle(
                      color: isSelected ? scheme.primary : scheme.onSurface,
                      fontWeight: isSelected
                          ? FontWeight.w500
                          : FontWeight.normal,
                    ),
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }
}
