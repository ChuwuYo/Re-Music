import 'package:flutter/material.dart';

import '../../constants.dart';
import '../../l10n/app_localizations.dart';

class TranscodeEmptyState extends StatelessWidget {
  const TranscodeEmptyState({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final scheme = Theme.of(context).colorScheme;
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.multitrack_audio, size: 72, color: scheme.primary),
          const SizedBox(height: AppConstants.spacingMedium),
          Text(
            l10n.transcodeEmptyTitle,
            style: Theme.of(context).textTheme.headlineSmall,
          ),
          const SizedBox(height: AppConstants.spacingSmall),
          Text(
            l10n.transcodeEmptySubtitle,
            style: Theme.of(
              context,
            ).textTheme.bodyMedium?.copyWith(color: scheme.onSurfaceVariant),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

class TranscodeNoMatchState extends StatelessWidget {
  const TranscodeNoMatchState({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final scheme = Theme.of(context).colorScheme;
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.filter_alt_off_outlined,
            size: 64,
            color: scheme.surfaceContainerHighest,
          ),
          const SizedBox(height: AppConstants.spacingLarge),
          Text(
            l10n.transcodeNoMatchTitle,
            style: Theme.of(
              context,
            ).textTheme.headlineSmall?.copyWith(color: scheme.onSurfaceVariant),
          ),
          const SizedBox(height: AppConstants.spacingSmall),
          Text(
            l10n.transcodeNoMatchSubtitle,
            style: Theme.of(
              context,
            ).textTheme.bodyMedium?.copyWith(color: scheme.outline),
          ),
        ],
      ),
    );
  }
}
