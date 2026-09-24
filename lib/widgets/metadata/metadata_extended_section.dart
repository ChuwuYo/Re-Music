import 'package:flutter/material.dart';
import '../../constants.dart';
import '../../l10n/app_localizations.dart';
import 'overflow_text_field.dart';

/// Right-column section containing comment and extended metadata (disc number & BPM).
class MetadataExtendedSection extends StatelessWidget {
  final TextEditingController commentController;
  final TextEditingController discNumberController;
  final TextEditingController discTotalController;
  final TextEditingController bpmController;

  const MetadataExtendedSection({
    super.key,
    required this.commentController,
    required this.discNumberController,
    required this.discTotalController,
    required this.bpmController,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final textTheme = Theme.of(context).textTheme;
    final colorScheme = Theme.of(context).colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // 备注/注释
        Row(
          children: [
            Icon(Icons.notes_outlined, size: 20, color: colorScheme.secondary),
            const SizedBox(width: AppConstants.spacingSmall),
            Text(
              l10n.metadataComment,
              style: textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: colorScheme.secondary,
              ),
            ),
          ],
        ),
        const SizedBox(height: AppConstants.spacingSmall),
        OverflowTextField(
          controller: commentController,
          label: l10n.metadataComment,
          minLines: 3,
          maxLines: 4,
          enablePopout: true,
        ),
        const SizedBox(height: AppConstants.spacingMedium),

        // 备注下面是：其他项
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
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          isNumeric: true,
          allowDecimal: true,
        ),
      ],
    );
  }
}
