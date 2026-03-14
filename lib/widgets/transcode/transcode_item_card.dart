import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../constants.dart';
import '../../l10n/app_localizations.dart';
import '../../models/transcode_item.dart';
import '../../providers/transcode_provider.dart';

class TranscodeItemCard extends StatelessWidget {
  final TranscodeItem item;

  const TranscodeItemCard({super.key, required this.item});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final scheme = Theme.of(context).colorScheme;
    final provider = context.watch<TranscodeProvider>();
    final statusLabel = _statusLabel(l10n, item.status);
    final statusColor = _statusColor(scheme, item.status);
    final message = _localizedMessage(l10n, item.message);

    return Card(
      margin: const EdgeInsets.symmetric(
        horizontal: AppConstants.spacingMedium,
        vertical: AppConstants.spacingSmall,
      ),
      child: Padding(
        padding: const EdgeInsets.all(AppConstants.spacingMedium),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        item.fileName,
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      const SizedBox(height: AppConstants.spacingExtraSmall),
                      Text(
                        item.probeInfo?.summary ??
                            l10n.transcodeTaskUnknownProbe,
                      ),
                      const SizedBox(height: AppConstants.spacingExtraSmall),
                      Text(
                        '${l10n.transcodeTaskTarget}: ${item.decision?.targetSummary ?? '—'}',
                      ),
                      const SizedBox(height: AppConstants.spacingExtraSmall),
                      Text(
                        '${l10n.transcodeTaskOutput}: ${item.actualOutputPath ?? item.plannedOutputPath ?? provider.outputDirectory ?? l10n.transcodeTaskUnknownOutput}',
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppConstants.spacingSmall,
                    vertical: AppConstants.spacingExtraSmall,
                  ),
                  decoration: BoxDecoration(
                    color: statusColor.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(
                      AppConstants.borderRadiusMedium,
                    ),
                  ),
                  child: Text(
                    statusLabel,
                    style: TextStyle(
                      color: statusColor,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
            if (message != null) ...[
              const SizedBox(height: AppConstants.spacingSmall),
              Text(
                message,
                style: TextStyle(
                  color: item.status == TranscodeItemStatus.error
                      ? scheme.error
                      : scheme.onSurfaceVariant,
                ),
              ),
            ],
            if (item.status == TranscodeItemStatus.running ||
                item.status == TranscodeItemStatus.queued) ...[
              const SizedBox(height: AppConstants.spacingSmall),
              LinearProgressIndicator(value: item.progress),
            ],
          ],
        ),
      ),
    );
  }

  String _statusLabel(AppLocalizations l10n, TranscodeItemStatus status) {
    return switch (status) {
      TranscodeItemStatus.probing => l10n.transcodeStatusProbing,
      TranscodeItemStatus.ready => l10n.transcodeStatusReady,
      TranscodeItemStatus.skipped => l10n.transcodeStatusSkipped,
      TranscodeItemStatus.queued => l10n.transcodeStatusQueued,
      TranscodeItemStatus.running => l10n.transcodeStatusRunning,
      TranscodeItemStatus.success => l10n.transcodeStatusSuccess,
      TranscodeItemStatus.error => l10n.transcodeStatusError,
      TranscodeItemStatus.pending => l10n.readingMetadata,
    };
  }

  Color _statusColor(ColorScheme scheme, TranscodeItemStatus status) {
    return switch (status) {
      TranscodeItemStatus.success => scheme.primary,
      TranscodeItemStatus.error => scheme.error,
      TranscodeItemStatus.skipped => scheme.outline,
      TranscodeItemStatus.running ||
      TranscodeItemStatus.queued => scheme.tertiary,
      _ => scheme.onSurfaceVariant,
    };
  }

  String? _localizedMessage(AppLocalizations l10n, String? message) {
    if (message == null || message.isEmpty) return null;
    return switch (message) {
      AppConstants.transcodeSkipLossyToLossless =>
        l10n.transcodeSkipLossyToLossless,
      AppConstants.transcodeSkipAlreadyCompliantLossless =>
        l10n.transcodeSkipAlreadyCompliantLossless,
      AppConstants.transcodeSkipAlreadyCompliantMp3 =>
        l10n.transcodeSkipAlreadyCompliantMp3,
      AppConstants.transcodeSkipUnsupportedSourceFormat =>
        l10n.transcodeSkipUnsupportedSourceFormat,
      AppConstants.transcodeSkipNoOutputDirectory =>
        l10n.transcodeSkipNoOutputDirectory,
      AppConstants.transcodeSkipBinaryMissing =>
        l10n.transcodeSkipBinaryMissing,
      _ => message,
    };
  }
}
