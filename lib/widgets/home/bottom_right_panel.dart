import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../l10n/app_localizations.dart';
import '../../providers/audio_provider.dart';
import '../../constants.dart';
import '../common/floating_panel_surface.dart';
import '../common/floating_progress_panel.dart';
import '../common/remusic_snack_bar.dart';

class BottomRightPanel extends StatelessWidget {
  const BottomRightPanel({super.key});

  Future<void> _handleRename(
    BuildContext context,
    AudioProvider provider,
  ) async {
    final count = await provider.renameAll();
    if (!context.mounted) return;
    final l10n = AppLocalizations.of(context)!;

    ReMusicSnackBar.showFloating(
      context,
      message: l10n.renameCompleted(count),
      adaptiveHorizontalMargin: true,
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Consumer<AudioProvider>(
      builder: (context, provider, child) {
        if (provider.isProcessing) {
          return FloatingProgressPanel(
            label: l10n.processingProgress((provider.progress * 100).round()),
            progress: provider.progress,
          );
        }

        return FloatingPanelSurface(
          child: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: AppConstants.spacingMedium,
              vertical: AppConstants.spacingMediumSmall,
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  l10n.totalFiles(provider.totalFilesCount),
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(width: AppConstants.spacingMedium),
                FilledButton.icon(
                  onPressed:
                      provider.totalFilesCount == 0 ||
                          provider.isProcessing ||
                          !provider.hasRenameCandidates
                      ? null
                      : () => _handleRename(context, provider),
                  style: FilledButton.styleFrom(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 24,
                      vertical: 12,
                    ),
                  ),
                  icon: const Icon(Icons.drive_file_rename_outline),
                  label: Text(l10n.startRename),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
