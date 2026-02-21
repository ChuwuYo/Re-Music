import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../l10n/app_localizations.dart';
import '../../providers/audio_provider.dart';
import '../../constants.dart';

class BottomRightPanel extends StatelessWidget {
  const BottomRightPanel({super.key});

  Future<void> _handleRename(
    BuildContext context,
    AudioProvider provider,
  ) async {
    final count = await provider.renameAll();
    if (!context.mounted) return;
    final l10n = AppLocalizations.of(context)!;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(l10n.renameCompleted(count)),
        behavior: SnackBarBehavior.floating,
        showCloseIcon: true,
      ),
    );
  }

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

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Consumer<AudioProvider>(
      builder: (context, provider, child) {
        if (provider.isProcessing) {
          return _panelSurface(
            context,
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: ConstrainedBox(
                constraints: const BoxConstraints(
                  maxWidth: AppConstants.progressPanelMaxWidth,
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      l10n.processingProgress(
                        (provider.progress * 100).round(),
                      ),
                      style: Theme.of(context).textTheme.labelMedium,
                    ),
                    const SizedBox(height: 8),
                    LinearProgressIndicator(
                      value: provider.progress,
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
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  l10n.totalFiles(provider.totalFilesCount),
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(width: 16),
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
