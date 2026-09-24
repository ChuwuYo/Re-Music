import 'package:flutter/material.dart';
import '../../constants.dart';
import '../../l10n/app_localizations.dart';
import 'overflow_text_field.dart';

/// Right-column extended metadata form section.
///
/// Contains standard audio tags physically supported for writing by the underlying engine:
/// - Disc number & disc total
/// - BPM (beats per minute)
/// - Embedded lyrics
class MetadataExtendedSection extends StatelessWidget {
  final TextEditingController discNumberController;
  final TextEditingController discTotalController;
  final TextEditingController bpmController;
  final TextEditingController lyricsController;

  const MetadataExtendedSection({
    super.key,
    required this.discNumberController,
    required this.discTotalController,
    required this.bpmController,
    required this.lyricsController,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final textTheme = Theme.of(context).textTheme;
    final colorScheme = Theme.of(context).colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(Icons.tune_outlined, size: 20, color: colorScheme.secondary),
            const SizedBox(width: AppConstants.spacingSmall),
            Text(
              l10n.metadataExtendedTitle,
              style: textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: colorScheme.secondary,
              ),
            ),
          ],
        ),
        const SizedBox(height: 2),
        Text(
          l10n.metadataExtendedSubtitle,
          style: textTheme.bodySmall?.copyWith(
            color: colorScheme.onSurfaceVariant,
          ),
        ),
        const SizedBox(height: AppConstants.spacingMedium),
        Row(
          children: [
            Expanded(
              child: OverflowTextField(
                controller: discNumberController,
                label: l10n.metadataDiscNumber,
                keyboardType: TextInputType.number,
                isNumeric: true,
              ),
            ),
            const SizedBox(width: AppConstants.spacingMediumSmall),
            Expanded(
              child: OverflowTextField(
                controller: discTotalController,
                label: l10n.metadataDiscTotal,
                keyboardType: TextInputType.number,
                isNumeric: true,
              ),
            ),
          ],
        ),
        const SizedBox(height: AppConstants.spacingMediumSmall),
        OverflowTextField(
          controller: bpmController,
          label: l10n.metadataBpm,
          keyboardType: TextInputType.number,
          isNumeric: true,
        ),
        const SizedBox(height: AppConstants.spacingMediumSmall),
        OverflowTextField(
          controller: lyricsController,
          label: l10n.metadataLyrics,
          minLines: 8,
          maxLines: 12,
          enablePopout: true,
        ),
      ],
    );
  }
}
