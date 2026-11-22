import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../constants.dart';
import '../../l10n/app_localizations.dart';
import '../../providers/transcode_provider.dart';
import '../../services/file_service.dart';
import '../common/app_dropdown_menu.dart';
import '../common/number_setting_field.dart';
import '../common/remusic_snack_bar.dart';
import '../common/sort_filter_buttons.dart';

class TranscodeControlPanel extends StatelessWidget {
  const TranscodeControlPanel({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final provider = context.watch<TranscodeProvider>();
    final outputMode = provider.outputMode;
    final controlsLocked = provider.isBusy;
    final colorScheme = Theme.of(context).colorScheme;

    Future<void> handleAddFiles() async {
      final paths = await FileService.pickFiles(
        allowedExtensions: AppConstants.supportedTranscodeInputExtensions,
      );
      if (!context.mounted || paths.isEmpty) return;
      await context.read<TranscodeProvider>().addFiles(paths);
    }

    Future<void> handleScanDirectory() async {
      final path = await FileService.pickDirectory();
      if (!context.mounted || path == null) return;
      final files = await FileService.scanDirectory(
        path,
        allowedExtensions: AppConstants.supportedTranscodeInputExtensions,
      );
      if (!context.mounted || files.isEmpty) return;
      await context.read<TranscodeProvider>().addFiles(files);
    }

    Future<void> handlePickOutputDirectory() async {
      final path = await FileService.pickDirectory();
      if (!context.mounted || path == null) return;
      context.read<TranscodeProvider>().setOutputDirectory(path);
    }

    Future<void> handleOpenDownloadPage() async {
      final ok = await context
          .read<TranscodeProvider>()
          .openBinaryDownloadPage();
      if (!context.mounted) return;
      ReMusicSnackBar.showFloating(
        context,
        message: ok
            ? l10n.transcodeOpenDownloadPageSuccess
            : l10n.transcodeOpenDownloadPageFailed,
        adaptiveHorizontalMargin: true,
      );
    }

    Future<void> handleOpenBinaryFolder() async {
      final ok = await context.read<TranscodeProvider>().openBinaryFolder();
      if (!context.mounted) return;
      ReMusicSnackBar.showFloating(
        context,
        message: ok
            ? l10n.transcodeOpenBinaryFolderSuccess
            : l10n.transcodeOpenBinaryFolderFailed,
        adaptiveHorizontalMargin: true,
      );
    }

    void handleRefreshBinaryStatus() {
      context.read<TranscodeProvider>().refreshBinaryStatus();
      if (!context.mounted) return;
      final stillMissing =
          context.read<TranscodeProvider>().binaryError != null;
      ReMusicSnackBar.showFloating(
        context,
        message: stillMissing
            ? l10n.transcodeRefreshBinaryStillMissing
            : l10n.transcodeRefreshBinarySuccess,
        adaptiveHorizontalMargin: true,
      );
    }

    return Card(
      margin: const EdgeInsets.all(AppConstants.spacingMedium),
      child: Padding(
        padding: const EdgeInsets.all(AppConstants.spacingMedium),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              l10n.transcodeTitle,
              style: Theme.of(
                context,
              ).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: AppConstants.spacingMedium),
            if (provider.binaryError != null)
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(AppConstants.spacingMediumSmall),
                decoration: BoxDecoration(
                  color: colorScheme.error.withValues(
                    alpha: AppConstants.bannerErrorBackgroundAlpha,
                  ),
                  borderRadius: BorderRadius.circular(
                    AppConstants.borderRadiusMedium,
                  ),
                  border: Border.all(
                    color: colorScheme.error.withValues(
                      alpha: AppConstants.bannerErrorBorderAlpha,
                    ),
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(
                          Icons.error_outline,
                          size: AppConstants.iconSizeNotice,
                          color: colorScheme.error,
                        ),
                        const SizedBox(width: AppConstants.spacingSmall),
                        Expanded(
                          child: Text(
                            _localizedBinaryMessage(
                              l10n,
                              provider.binaryError!,
                            ),
                            style: TextStyle(
                              color: colorScheme.error,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: AppConstants.spacingSmall),
                    Wrap(
                      spacing: AppConstants.spacingSmall,
                      runSpacing: AppConstants.spacingSmall,
                      children: [
                        OutlinedButton.icon(
                          style: OutlinedButton.styleFrom(
                            foregroundColor: colorScheme.error,
                            side: BorderSide(
                              color: colorScheme.error.withValues(
                                alpha:
                                    AppConstants.bannerErrorButtonBorderAlpha,
                              ),
                            ),
                          ),
                          onPressed: controlsLocked
                              ? null
                              : handleRefreshBinaryStatus,
                          icon: const Icon(Icons.refresh),
                          label: Text(l10n.transcodeRefreshBinary),
                        ),
                        OutlinedButton.icon(
                          style: OutlinedButton.styleFrom(
                            foregroundColor: colorScheme.error,
                            side: BorderSide(
                              color: colorScheme.error.withValues(
                                alpha:
                                    AppConstants.bannerErrorButtonBorderAlpha,
                              ),
                            ),
                          ),
                          onPressed: controlsLocked
                              ? null
                              : handleOpenDownloadPage,
                          icon: const Icon(Icons.open_in_new),
                          label: Text(l10n.transcodeOpenDownloadPage),
                        ),
                        OutlinedButton.icon(
                          style: OutlinedButton.styleFrom(
                            foregroundColor: colorScheme.error,
                            side: BorderSide(
                              color: colorScheme.error.withValues(
                                alpha:
                                    AppConstants.bannerErrorButtonBorderAlpha,
                              ),
                            ),
                          ),
                          onPressed: controlsLocked
                              ? null
                              : handleOpenBinaryFolder,
                          icon: const Icon(Icons.folder_open),
                          label: Text(l10n.transcodeOpenBinaryFolder),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            if (provider.binaryError != null)
              const SizedBox(height: AppConstants.spacingMedium),
            Row(
              children: [
                Expanded(
                  child: Wrap(
                    spacing: AppConstants.spacingSmall,
                    runSpacing: AppConstants.spacingSmall,
                    children: [
                      FilledButton.tonalIcon(
                        onPressed:
                            controlsLocked || provider.binaryError != null
                            ? null
                            : handleAddFiles,
                        icon: const Icon(Icons.audio_file),
                        label: Text(l10n.addFiles),
                      ),
                      OutlinedButton.icon(
                        onPressed:
                            controlsLocked || provider.binaryError != null
                            ? null
                            : handleScanDirectory,
                        icon: const Icon(Icons.create_new_folder),
                        label: Text(l10n.scanDirectory),
                      ),
                      if (outputMode == TranscodeOutputMode.outputDirectory)
                        OutlinedButton.icon(
                          onPressed: controlsLocked
                              ? null
                              : handlePickOutputDirectory,
                          icon: const Icon(Icons.folder_open),
                          label: Text(l10n.transcodeChooseOutputDirectory),
                        ),
                    ],
                  ),
                ),
                FilterMenuButton<TranscodeItemFilter>(
                  tooltip: l10n.filter,
                  currentValue: provider.filter,
                  defaultValue: TranscodeItemFilter.all,
                  options: [
                    MenuOption(
                      value: TranscodeItemFilter.all,
                      label: l10n.transcodeShowAll,
                    ),
                    MenuOption(
                      value: TranscodeItemFilter.ready,
                      label: l10n.transcodeShowReady,
                    ),
                    MenuOption(
                      value: TranscodeItemFilter.skipped,
                      label: l10n.transcodeShowSkipped,
                    ),
                    MenuOption(
                      value: TranscodeItemFilter.success,
                      label: l10n.transcodeShowSuccess,
                    ),
                    MenuOption(
                      value: TranscodeItemFilter.error,
                      label: l10n.transcodeShowError,
                    ),
                  ],
                  onSelected: provider.setFilter,
                ),
                const SizedBox(width: AppConstants.spacingSmall),
                SortMenuButton(
                  tooltip: l10n.sort,
                  currentCriteria: provider.sortCriteria,
                  options: [
                    MenuOption(value: 'name', label: l10n.transcodeSortByName),
                    MenuOption(
                      value: 'format',
                      label: l10n.transcodeSortByFormat,
                    ),
                    MenuOption(
                      value: 'sampleRate',
                      label: l10n.transcodeSortBySampleRate,
                    ),
                    MenuOption(
                      value: 'status',
                      label: l10n.transcodeSortByStatus,
                    ),
                  ],
                  onSelected: provider.setSortCriteria,
                ),
                const SizedBox(width: AppConstants.spacingSmall),
                SortOrderButton(
                  ascending: provider.sortAscending,
                  ascendingTooltip: l10n.sortAscending,
                  descendingTooltip: l10n.sortDescending,
                  onToggle: () =>
                      provider.setSortAscending(!provider.sortAscending),
                ),
              ],
            ),
            if (outputMode == TranscodeOutputMode.outputDirectory)
              Padding(
                padding: const EdgeInsets.only(top: AppConstants.spacingSmall),
                child: Text(
                  provider.outputDirectory ??
                      l10n.transcodeOutputDirectoryRequired,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: provider.outputDirectory == null
                        ? Theme.of(context).colorScheme.error
                        : Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
                ),
              ),
            const SizedBox(height: AppConstants.spacingMedium),
            Wrap(
              spacing: AppConstants.spacingMedium,
              runSpacing: AppConstants.spacingMedium,
              crossAxisAlignment: WrapCrossAlignment.start,
              children: [
                AppDropdownMenu<TranscodeOutputFormat>(
                  width: AppConstants.transcodeSettingFieldWidth,
                  label: Text(l10n.transcodeOutputFormat),
                  initialSelection: provider.outputFormat,
                  enableFilter: true,
                  enabled: !controlsLocked,
                  entries: [
                    DropdownMenuEntry(
                      value: TranscodeOutputFormat.flac,
                      label: l10n.transcodeFormatFlac,
                    ),
                    DropdownMenuEntry(
                      value: TranscodeOutputFormat.wav,
                      label: l10n.transcodeFormatWav,
                    ),
                    DropdownMenuEntry(
                      value: TranscodeOutputFormat.alac,
                      label: l10n.transcodeFormatAlac,
                    ),
                    DropdownMenuEntry(
                      value: TranscodeOutputFormat.mp3,
                      label: l10n.transcodeFormatMp3,
                    ),
                  ],
                  onSelected: (value) {
                    if (value != null) {
                      context.read<TranscodeProvider>().setOutputFormat(value);
                    }
                  },
                ),
                if (provider.outputFormat == TranscodeOutputFormat.mp3)
                  NumberSettingField(
                    key: ValueKey(provider.mp3BitRateKbps),
                    label: l10n.transcodeMp3Bitrate,
                    value: provider.mp3BitRateKbps,
                    errorText: l10n.transcodeInvalidNumber,
                    enabled: !controlsLocked,
                    onSubmit: (text) => context
                        .read<TranscodeProvider>()
                        .trySetMp3BitRateKbps(text),
                  )
                else
                  AppDropdownMenu<TranscodeLosslessPreset>(
                    width: AppConstants.transcodeSettingFieldWidth,
                    label: Text(l10n.transcodePreset),
                    initialSelection: provider.losslessPreset,
                    enableFilter: true,
                    enabled: !controlsLocked,
                    entries: [
                      DropdownMenuEntry(
                        value: TranscodeLosslessPreset.studio24,
                        label: l10n.transcodePresetStudio24,
                      ),
                      DropdownMenuEntry(
                        value: TranscodeLosslessPreset.cd24,
                        label: l10n.transcodePresetCd24,
                      ),
                      DropdownMenuEntry(
                        value: TranscodeLosslessPreset.cd16,
                        label: l10n.transcodePresetCd16,
                      ),
                    ],
                    onSelected: (value) {
                      if (value != null) {
                        context.read<TranscodeProvider>().setLosslessPreset(
                          value,
                        );
                      }
                    },
                  ),
                NumberSettingField(
                  key: ValueKey(provider.concurrency),
                  label: l10n.transcodeConcurrencyLabel(
                    AppConstants.transcodeConcurrencyMin,
                    AppConstants.transcodeConcurrencyMax,
                  ),
                  value: provider.concurrency,
                  errorText: l10n.transcodeInvalidNumber,
                  enabled: !controlsLocked,
                  onSubmit: (text) =>
                      context.read<TranscodeProvider>().trySetConcurrency(text),
                ),
              ],
            ),
            const SizedBox(height: AppConstants.spacingMediumSmall),
            _buildOutputModeSelector(
              context: context,
              l10n: l10n,
              provider: provider,
              controlsLocked: controlsLocked,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOutputModeSelector({
    required BuildContext context,
    required AppLocalizations l10n,
    required TranscodeProvider provider,
    required bool controlsLocked,
  }) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final useDropdown = constraints.maxWidth < 640;
        if (useDropdown) {
          return AppDropdownMenu<TranscodeOutputMode>(
            label: Text(l10n.transcodeTaskOutput),
            initialSelection: provider.outputMode,
            leadingIcon: const Icon(Icons.folder_copy_outlined),
            enabled: !controlsLocked,
            entries: [
              DropdownMenuEntry(
                value: TranscodeOutputMode.keepOriginal,
                label: l10n.transcodeKeepOriginal,
              ),
              DropdownMenuEntry(
                value: TranscodeOutputMode.replaceOriginal,
                label: l10n.transcodeReplaceOriginal,
              ),
              DropdownMenuEntry(
                value: TranscodeOutputMode.outputDirectory,
                label: l10n.transcodeOutputDirectory,
              ),
            ],
            onSelected: (value) {
              if (value != null) {
                context.read<TranscodeProvider>().setOutputMode(value);
              }
            },
          );
        }

        return SegmentedButton<TranscodeOutputMode>(
          segments: [
            ButtonSegment(
              value: TranscodeOutputMode.keepOriginal,
              label: Text(l10n.transcodeKeepOriginal),
              icon: const Icon(Icons.copy_all_outlined),
            ),
            ButtonSegment(
              value: TranscodeOutputMode.replaceOriginal,
              label: Text(l10n.transcodeReplaceOriginal),
              icon: const Icon(Icons.swap_horiz),
            ),
            ButtonSegment(
              value: TranscodeOutputMode.outputDirectory,
              label: Text(l10n.transcodeOutputDirectory),
              icon: const Icon(Icons.folder_copy_outlined),
            ),
          ],
          selected: {provider.outputMode},
          onSelectionChanged: controlsLocked
              ? null
              : (selection) {
                  context.read<TranscodeProvider>().setOutputMode(
                    selection.first,
                  );
                },
        );
      },
    );
  }

  String _localizedBinaryMessage(AppLocalizations l10n, String message) {
    return switch (message) {
      AppConstants.transcodeSkipBinaryMissing =>
        l10n.transcodeSkipBinaryMissing,
      _ => message,
    };
  }
}
