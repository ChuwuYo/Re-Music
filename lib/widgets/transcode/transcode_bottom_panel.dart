import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../constants.dart';
import '../../l10n/app_localizations.dart';
import '../../providers/transcode_provider.dart';
import '../common/remusic_snack_bar.dart';

class TranscodeBottomPanel extends StatelessWidget {
  const TranscodeBottomPanel({super.key});

  Widget _panelSurface(BuildContext context, Widget child) {
    final scheme = Theme.of(context).colorScheme;
    final brightness = Theme.of(context).brightness;
    final radius = BorderRadius.circular(AppConstants.borderRadiusLarge);
    final shadow = scheme.shadow.withValues(
      alpha: brightness == Brightness.dark ? 0.6 : 0.22,
    );
    final highlight = Colors.white.withValues(
      alpha: brightness == Brightness.dark ? 0.0 : 0.6,
    );

    return DecoratedBox(
      decoration: BoxDecoration(
        borderRadius: radius,
        boxShadow: [
          BoxShadow(
            color: shadow,
            blurRadius: AppConstants.shadowBlurRadius,
            offset: Offset(0, AppConstants.shadowOffsetY),
          ),
          if (brightness != Brightness.dark)
            BoxShadow(
              color: highlight,
              blurRadius: AppConstants.highlightBlurRadius,
              offset: Offset(0, AppConstants.highlightOffsetY),
            ),
        ],
      ),
      child: Material(
        type: MaterialType.card,
        color: scheme.surface,
        shape: RoundedRectangleBorder(
          borderRadius: radius,
          side: BorderSide(color: scheme.outlineVariant.withValues(alpha: 0.7)),
        ),
        child: child,
      ),
    );
  }

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
          return _panelSurface(
            context,
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: AppConstants.spacingMedium,
                vertical: AppConstants.spacingMediumSmall,
              ),
              child: ConstrainedBox(
                constraints: const BoxConstraints(
                  maxWidth: AppConstants.progressPanelMaxWidth,
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      l10n.transcodeProgress((provider.progress * 100).round()),
                      style: Theme.of(context).textTheme.labelMedium,
                    ),
                    const SizedBox(height: AppConstants.spacingSmall),
                    LinearProgressIndicator(
                      value: provider.progress <= 0 ? null : provider.progress,
                      borderRadius: BorderRadius.circular(
                        AppConstants.progressBorderRadius,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        }

        return _panelSurface(
          context,
          Padding(
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
