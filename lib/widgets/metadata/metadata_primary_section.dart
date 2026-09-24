import 'package:flutter/material.dart';
import '../../constants.dart';
import '../../l10n/app_localizations.dart';
import 'overflow_text_field.dart';

/// Left-column primary metadata form section.
class MetadataPrimarySection extends StatelessWidget {
  final TextEditingController trackArtistController;
  final TextEditingController albumArtistController;
  final TextEditingController albumController;
  final TextEditingController trackNumberController;
  final TextEditingController trackTotalController;
  final TextEditingController yearController;
  final TextEditingController genreController;

  const MetadataPrimarySection({
    super.key,
    required this.trackArtistController,
    required this.albumArtistController,
    required this.albumController,
    required this.trackNumberController,
    required this.trackTotalController,
    required this.yearController,
    required this.genreController,
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
            Icon(Icons.album_outlined, size: 20, color: colorScheme.primary),
            const SizedBox(width: AppConstants.spacingSmall),
            Text(
              l10n.metadataPrimaryTitle,
              style: textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: colorScheme.primary,
              ),
            ),
          ],
        ),
        const SizedBox(height: 2),
        Text(
          l10n.metadataPrimarySubtitle,
          style: textTheme.bodySmall?.copyWith(
            color: colorScheme.onSurfaceVariant,
          ),
        ),
        const SizedBox(height: AppConstants.spacingMedium),
        OverflowTextField(
          controller: trackArtistController,
          label: l10n.metadataTrackArtist,
          maxLines: 2,
          enablePopout: true,
        ),
        const SizedBox(height: AppConstants.spacingMediumSmall),
        OverflowTextField(
          controller: albumArtistController,
          label: l10n.metadataAlbumArtist,
          maxLines: 2,
          enablePopout: true,
        ),
        const SizedBox(height: AppConstants.spacingMediumSmall),
        OverflowTextField(
          controller: albumController,
          label: l10n.metadataAlbum,
          maxLines: 2,
          enablePopout: true,
        ),
        const SizedBox(height: AppConstants.spacingMediumSmall),
        Row(
          children: [
            Expanded(
              child: OverflowTextField(
                controller: trackNumberController,
                label: l10n.metadataTrackNumber,
                keyboardType: TextInputType.number,
                isNumeric: true,
              ),
            ),
            const SizedBox(width: AppConstants.spacingMediumSmall),
            Expanded(
              child: OverflowTextField(
                controller: trackTotalController,
                label: l10n.metadataTrackTotal,
                keyboardType: TextInputType.number,
                isNumeric: true,
              ),
            ),
          ],
        ),
        const SizedBox(height: AppConstants.spacingMediumSmall),
        Row(
          children: [
            Expanded(
              child: OverflowTextField(
                controller: yearController,
                label: l10n.metadataYear,
                keyboardType: TextInputType.number,
                isNumeric: true,
              ),
            ),
            const SizedBox(width: AppConstants.spacingMediumSmall),
            Expanded(
              child: OverflowTextField(
                controller: genreController,
                label: l10n.metadataGenre,
                enablePopout: true,
              ),
            ),
          ],
        ),
      ],
    );
  }
}
