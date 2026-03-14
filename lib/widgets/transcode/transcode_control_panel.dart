import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../constants.dart';
import '../../l10n/app_localizations.dart';
import '../../providers/transcode_provider.dart';
import '../../services/file_service.dart';
import '../common/remusic_snack_bar.dart';

class TranscodeControlPanel extends StatelessWidget {
  const TranscodeControlPanel({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final provider = context.watch<TranscodeProvider>();
    final outputMode = provider.outputMode;
    final controlsLocked = provider.isBusy;

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
      if (!context.mounted) return;
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
                  color: Theme.of(context).colorScheme.errorContainer,
                  borderRadius: BorderRadius.circular(
                    AppConstants.borderRadiusMedium,
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _localizedBinaryMessage(l10n, provider.binaryError!),
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.onErrorContainer,
                      ),
                    ),
                    const SizedBox(height: AppConstants.spacingSmall),
                    Wrap(
                      spacing: AppConstants.spacingSmall,
                      runSpacing: AppConstants.spacingSmall,
                      children: [
                        OutlinedButton.icon(
                          onPressed: controlsLocked
                              ? null
                              : handleOpenDownloadPage,
                          icon: const Icon(Icons.open_in_new),
                          label: Text(l10n.transcodeOpenDownloadPage),
                        ),
                        OutlinedButton.icon(
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
            Wrap(
              spacing: AppConstants.spacingSmall,
              runSpacing: AppConstants.spacingSmall,
              children: [
                FilledButton.tonalIcon(
                  onPressed: controlsLocked ? null : handleAddFiles,
                  icon: const Icon(Icons.audio_file),
                  label: Text(l10n.addFiles),
                ),
                OutlinedButton.icon(
                  onPressed: controlsLocked ? null : handleScanDirectory,
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
              children: [
                SizedBox(
                  width: 260,
                  child: DropdownButtonFormField<TranscodeOutputFormat>(
                    initialValue: provider.outputFormat,
                    isExpanded: true,
                    decoration: InputDecoration(
                      labelText: l10n.transcodeOutputFormat,
                    ),
                    items: [
                      DropdownMenuItem(
                        value: TranscodeOutputFormat.flac,
                        child: Text(l10n.transcodeFormatFlac),
                      ),
                      DropdownMenuItem(
                        value: TranscodeOutputFormat.wav,
                        child: Text(l10n.transcodeFormatWav),
                      ),
                      DropdownMenuItem(
                        value: TranscodeOutputFormat.alac,
                        child: Text(l10n.transcodeFormatAlac),
                      ),
                      DropdownMenuItem(
                        value: TranscodeOutputFormat.mp3,
                        child: Text(l10n.transcodeFormatMp3),
                      ),
                    ],
                    onChanged: controlsLocked
                        ? null
                        : (value) {
                            if (value != null) {
                              context.read<TranscodeProvider>().setOutputFormat(
                                value,
                              );
                            }
                          },
                  ),
                ),
                if (provider.outputFormat == TranscodeOutputFormat.mp3)
                  SizedBox(
                    width: 260,
                    child: DropdownButtonFormField<int>(
                      initialValue: provider.mp3BitRateKbps,
                      isExpanded: true,
                      decoration: InputDecoration(
                        labelText: l10n.transcodeMp3Bitrate,
                      ),
                      items: AppConstants.transcodeMp3BitRateOptions
                          .map(
                            (bitrate) => DropdownMenuItem(
                              value: bitrate,
                              child: Text('${bitrate}k'),
                            ),
                          )
                          .toList(),
                      onChanged: controlsLocked
                          ? null
                          : (value) {
                              if (value != null) {
                                context
                                    .read<TranscodeProvider>()
                                    .setMp3BitRateKbps(value);
                              }
                            },
                    ),
                  )
                else
                  SizedBox(
                    width: 260,
                    child: DropdownButtonFormField<TranscodeLosslessPreset>(
                      initialValue: provider.losslessPreset,
                      isExpanded: true,
                      decoration: InputDecoration(
                        labelText: l10n.transcodePreset,
                      ),
                      items: [
                        DropdownMenuItem(
                          value: TranscodeLosslessPreset.studio24,
                          child: Text(l10n.transcodePresetStudio24),
                        ),
                        DropdownMenuItem(
                          value: TranscodeLosslessPreset.cd24,
                          child: Text(l10n.transcodePresetCd24),
                        ),
                        DropdownMenuItem(
                          value: TranscodeLosslessPreset.cd16,
                          child: Text(l10n.transcodePresetCd16),
                        ),
                      ],
                      onChanged: controlsLocked
                          ? null
                          : (value) {
                              if (value != null) {
                                context
                                    .read<TranscodeProvider>()
                                    .setLosslessPreset(value);
                              }
                            },
                    ),
                  ),
                SizedBox(
                  width: 260,
                  child: DropdownButtonFormField<int>(
                    initialValue: provider.concurrency,
                    isExpanded: true,
                    decoration: InputDecoration(
                      labelText: l10n.transcodeConcurrency,
                    ),
                    items:
                        List.generate(
                              AppConstants.transcodeConcurrencyMax,
                              (index) => index + 1,
                            )
                            .map(
                              (value) => DropdownMenuItem(
                                value: value,
                                child: Text('$value'),
                              ),
                            )
                            .toList(),
                    onChanged: controlsLocked
                        ? null
                        : (value) {
                            if (value != null) {
                              context.read<TranscodeProvider>().setConcurrency(
                                value,
                              );
                            }
                          },
                  ),
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
            ListTile(
              contentPadding: EdgeInsets.zero,
              title: Text(l10n.transcodeAllowFormatOnly),
              trailing: Switch.adaptive(
                value: provider.allowFormatOnlyConversion,
                onChanged: controlsLocked
                    ? null
                    : context
                          .read<TranscodeProvider>()
                          .setAllowFormatOnlyConversion,
              ),
            ),
            ListTile(
              contentPadding: EdgeInsets.zero,
              title: Text(l10n.transcodeEnableDither),
              trailing: Switch.adaptive(
                value: provider.enableDither,
                onChanged:
                    controlsLocked ||
                        provider.outputFormat == TranscodeOutputFormat.mp3
                    ? null
                    : context.read<TranscodeProvider>().setEnableDither,
              ),
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
          return DropdownButtonFormField<TranscodeOutputMode>(
            initialValue: provider.outputMode,
            decoration: InputDecoration(labelText: l10n.transcodeTaskOutput),
            items: [
              DropdownMenuItem(
                value: TranscodeOutputMode.keepOriginal,
                child: Text(l10n.transcodeKeepOriginal),
              ),
              DropdownMenuItem(
                value: TranscodeOutputMode.replaceOriginal,
                child: Text(l10n.transcodeReplaceOriginal),
              ),
              DropdownMenuItem(
                value: TranscodeOutputMode.outputDirectory,
                child: Text(l10n.transcodeOutputDirectory),
              ),
            ],
            onChanged: controlsLocked
                ? null
                : (value) {
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
