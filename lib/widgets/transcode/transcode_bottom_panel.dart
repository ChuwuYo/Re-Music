import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../constants.dart';
import '../../l10n/app_localizations.dart';
import '../../providers/transcode_provider.dart';
import '../common/floating_panel_surface.dart';
import '../common/floating_progress_panel.dart';
import '../common/remusic_snack_bar.dart';

class TranscodeBottomPanel extends StatelessWidget {
  const TranscodeBottomPanel({super.key});

  Future<void> _handleTranscode(
    BuildContext context,
    TranscodeProvider provider,
  ) async {
    try {
      final count = await provider.startTranscoding();
      if (!context.mounted) return;
      final l10n = AppLocalizations.of(context)!;
      ReMusicSnackBar.showFloating(
        context,
        message: l10n.transcodeCompleted(count),
        adaptiveHorizontalMargin: true,
      );
    } catch (error) {
      if (!context.mounted) return;
      ReMusicSnackBar.showFloating(
        context,
        message: '$error',
        adaptiveHorizontalMargin: true,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Consumer<TranscodeProvider>(
      builder: (context, provider, child) {
        if (provider.isBusy) {
          return FloatingProgressPanel(
            label: l10n.transcodeProgress((provider.progress * 100).round()),
            progress: provider.progress <= 0 ? null : provider.progress,
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
                  l10n.transcodeTotalFiles(provider.totalFilesCount),
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(width: AppConstants.spacingMedium),
                FilledButton.icon(
                  onPressed: provider.canStart
                      ? () => _handleTranscode(context, provider)
                      : null,
                  icon: const Icon(Icons.play_arrow),
                  label: Text(l10n.transcodeStart),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
