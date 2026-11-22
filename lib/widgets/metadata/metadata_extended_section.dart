import 'package:flutter/material.dart';
import '../../constants.dart';
import '../../l10n/app_localizations.dart';
import '../common/section_header.dart';
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

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SectionHeader(
          icon: Icons.notes_outlined,
          color: Theme.of(context).colorScheme.secondary,
          title: l10n.metadataComment,
        ),
        OverflowTextField(
          controller: commentController,
          label: l10n.metadataComment,
          minLines: 3,
          maxLines: 4,
          enablePopout: true,
        ),
        const SizedBox(height: AppConstants.spacingMedium),

        // 备注下面是：其他项
        SectionHeader(
          icon: Icons.tune_outlined,
          color: Theme.of(context).colorScheme.secondary,
          title: l10n.metadataExtendedTitle,
          subtitle: l10n.metadataExtendedSubtitle,
        ),
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
