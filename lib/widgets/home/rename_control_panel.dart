import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../l10n/app_localizations.dart';
import '../../providers/audio_provider.dart';
import '../../services/file_service.dart';
import '../common/sort_filter_buttons.dart';
import '../../constants.dart';

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

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // locale 切换时 DropdownMenu 重建可能短暂清空 controller，
    // 以 provider 的 pattern 为准恢复显示
    final providerPattern = context.read<AudioProvider>().pattern;
    if (_patternController.text.isEmpty && providerPattern.isNotEmpty) {
      _patternController.text = providerPattern;
    }
  }

  void _onPatternChanged() {
    if (!mounted) return;
    final text = _patternController.text;
    if (text.isEmpty) return; // 忽略 DropdownMenu 重建期间的临时空值
    context.read<AudioProvider>().setPattern(text);
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
      case '{albumArtist} - {track} - {title}':
        return l10n.patternAlbumArtistTrackTitle;
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
                          if (paths.isEmpty) return;
                          await provider.addSingleFiles(paths);
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
                          await provider.addDirectoryFiles(files);
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
                final dropWidth = constraints.maxWidth;
                return DropdownMenu<String>(
                  width: dropWidth,
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
                      // setPattern is invoked by _patternController listener
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
        return FilterMenuButton<FileFilter>(
          tooltip: l10n.filter,
          currentValue: provider.filter,
          defaultValue: FileFilter.all,
          options: [
            MenuOption(value: FileFilter.all, label: l10n.showAll),
            MenuOption(value: FileFilter.valid, label: l10n.showNoRenameNeeded),
            MenuOption(value: FileFilter.invalid, label: l10n.showNeedRename),
          ],
          onSelected: provider.setFilter,
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
        return SortMenuButton(
          tooltip: l10n.sort,
          currentCriteria: provider.sortCriteria,
          options: [
            MenuOption(value: 'name', label: l10n.sortByName),
            MenuOption(value: 'artist', label: l10n.sortByArtist),
            MenuOption(value: 'title', label: l10n.sortByTitle),
            MenuOption(value: 'size', label: l10n.sortBySize),
            MenuOption(value: 'modified', label: l10n.sortByModifiedTime),
          ],
          onSelected: provider.setSortCriteria,
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
        return SortOrderButton(
          ascending: provider.sortAscending,
          ascendingTooltip: l10n.sortAscending,
          descendingTooltip: l10n.sortDescending,
          onToggle: () => provider.setSortAscending(!provider.sortAscending),
        );
      },
    );
  }
}
