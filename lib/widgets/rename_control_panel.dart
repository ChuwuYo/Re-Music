import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../l10n/app_localizations.dart';
import '../providers/audio_provider.dart';
import '../services/file_service.dart';
import 'smart_menu_anchor.dart';
import '../constants.dart';

class RenameControlPanel extends StatefulWidget {
  const RenameControlPanel({super.key});

  @override
  State<RenameControlPanel> createState() => _RenameControlPanelState();
}

class _RenameControlPanelState extends State<RenameControlPanel> {
  late final TextEditingController _patternController;

  @override
  void initState() {
    super.initState();
    final provider = context.read<AudioProvider>();
    _patternController = TextEditingController(text: provider.pattern);
    _patternController.addListener(_onPatternChanged);
  }

  void _onPatternChanged() {
    context.read<AudioProvider>().setPattern(_patternController.text);
  }

  @override
  void dispose() {
    _patternController.removeListener(_onPatternChanged);
    _patternController.dispose();
    super.dispose();
  }

  String _patternLabel(AppLocalizations l10n, String pattern) {
    switch (pattern) {
      case '{artist} - {title}':
        return l10n.patternArtistTitle;
      case '{title} - {artist}':
        return l10n.patternTitleArtist;
      case '{track} - {title}':
        return l10n.patternTrackTitle;
      case '{artist} - {album} - {title}':
        return l10n.patternArtistAlbumTitle;
      default:
        return pattern;
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Card(
      margin: const EdgeInsets.all(16),
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      FilledButton.tonalIcon(
                        onPressed: () async {
                          final provider = context.read<AudioProvider>();
                          final paths = await FileService.pickFiles();
                          if (!mounted) return;
                          if (paths.isNotEmpty) {
                            provider.addFiles(paths);
                          }
                        },
                        icon: const Icon(Icons.audio_file),
                        label: Text(l10n.addFiles),
                      ),
                      OutlinedButton.icon(
                        onPressed: () async {
                          final provider = context.read<AudioProvider>();
                          final path = await FileService.pickDirectory();
                          if (path == null) return;
                          final files = await FileService.scanDirectory(path);
                          if (!mounted) return;
                          provider.addFiles(files);
                        },
                        icon: const Icon(Icons.create_new_folder),
                        label: Text(l10n.scanDirectory),
                      ),
                    ],
                  ),
                ),
                _FilterMenu(),
                const SizedBox(width: AppConstants.spacingSmall),
                _SortMenu(),
                const SizedBox(width: AppConstants.spacingSmall),
                _SortOrderButton(),
              ],
            ),
            const SizedBox(height: 16),
            LayoutBuilder(
              builder: (context, constraints) {
                return DropdownMenu<String>(
                  width: constraints.maxWidth,
                  controller: _patternController,
                  label: Text(l10n.namingMode),
                  hintText: l10n.namingModeHint('{artist}', '{title}'),
                  enableFilter: false,
                  requestFocusOnTap: true,
                  leadingIcon: const Icon(Icons.edit_note),
                  inputDecorationTheme: const InputDecorationTheme(
                    filled: true,
                    contentPadding: EdgeInsets.symmetric(vertical: 5.0),
                  ),
                  dropdownMenuEntries: [
                    ...AudioProvider.predefinedPatterns.map((e) {
                      final pattern = e['pattern']!;
                      return DropdownMenuEntry<String>(
                        value: pattern,
                        label: _patternLabel(l10n, pattern),
                        trailingIcon: Text(
                          pattern,
                          style: Theme.of(context).textTheme.bodySmall
                              ?.copyWith(
                                color: Theme.of(context).colorScheme.outline,
                              ),
                        ),
                      );
                    }),
                    DropdownMenuEntry<String>(
                      value: '',
                      label: l10n.customPattern,
                      enabled: false,
                    ),
                  ],
                  onSelected: (value) {
                    if (value != null && value.isNotEmpty) {
                      _patternController.text = value;
                      context.read<AudioProvider>().setPattern(value);
                    }
                  },
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

class _FilterMenu extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Consumer<AudioProvider>(
      builder: (context, provider, child) {
        final l10n = AppLocalizations.of(context)!;
        return SmartMenuAnchor(
          tooltip: l10n.filter,
          icon: Icon(
            Icons.filter_list,
            color: provider.filter != FileFilter.all
                ? Theme.of(context).colorScheme.primary
                : null,
          ),
          estimatedMenuWidth: 200,
          menuChildren: [
            MenuItemButton(
              onPressed: () => provider.setFilter(FileFilter.all),
              leadingIcon: provider.filter == FileFilter.all
                  ? const Icon(Icons.check)
                  : const SizedBox(width: 24),
              child: Text(l10n.showAll),
            ),
            MenuItemButton(
              onPressed: () => provider.setFilter(FileFilter.valid),
              leadingIcon: provider.filter == FileFilter.valid
                  ? const Icon(Icons.check)
                  : const SizedBox(width: 24),
              child: Text(l10n.showNoRenameNeeded),
            ),
            MenuItemButton(
              onPressed: () => provider.setFilter(FileFilter.invalid),
              leadingIcon: provider.filter == FileFilter.invalid
                  ? const Icon(Icons.check)
                  : const SizedBox(width: 24),
              child: Text(l10n.showNeedRename),
            ),
          ],
        );
      },
    );
  }
}

class _SortMenu extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Consumer<AudioProvider>(
      builder: (context, provider, child) {
        final l10n = AppLocalizations.of(context)!;
        return SmartMenuAnchor(
          tooltip: l10n.sort,
          icon: const Icon(Icons.sort),
          widthEstimationLabels: [
            l10n.sortByName,
            l10n.sortByArtist,
            l10n.sortByTitle,
            l10n.sortBySize,
            l10n.sortByModifiedTime,
          ],
          menuChildren: [
            MenuItemButton(
              onPressed: () => provider.sortBy('name'),
              leadingIcon: provider.sortCriteria == 'name'
                  ? const Icon(Icons.check)
                  : const SizedBox(width: 24),
              child: Text(l10n.sortByName),
            ),
            MenuItemButton(
              onPressed: () => provider.sortBy('artist'),
              leadingIcon: provider.sortCriteria == 'artist'
                  ? const Icon(Icons.check)
                  : const SizedBox(width: 24),
              child: Text(l10n.sortByArtist),
            ),
            MenuItemButton(
              onPressed: () => provider.sortBy('title'),
              leadingIcon: provider.sortCriteria == 'title'
                  ? const Icon(Icons.check)
                  : const SizedBox(width: 24),
              child: Text(l10n.sortByTitle),
            ),
            MenuItemButton(
              onPressed: () => provider.sortBy('size'),
              leadingIcon: provider.sortCriteria == 'size'
                  ? const Icon(Icons.check)
                  : const SizedBox(width: 24),
              child: Text(l10n.sortBySize),
            ),
            MenuItemButton(
              onPressed: () => provider.sortBy('date'),
              leadingIcon: provider.sortCriteria == 'date'
                  ? const Icon(Icons.check)
                  : const SizedBox(width: 24),
              child: Text(l10n.sortByModifiedTime),
            ),
          ],
        );
      },
    );
  }
}

class _SortOrderButton extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Consumer<AudioProvider>(
      builder: (context, provider, child) {
        final l10n = AppLocalizations.of(context)!;
        return IconButton(
          tooltip: provider.sortAscending
              ? l10n.sortDescending
              : l10n.sortAscending,
          icon: Icon(
            provider.sortAscending
                ? Icons.keyboard_arrow_up
                : Icons.keyboard_arrow_down,
          ),
          onPressed: () => provider.toggleSortOrder(),
        );
      },
    );
  }
}
