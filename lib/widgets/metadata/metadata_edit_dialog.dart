import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../constants.dart';
import '../../l10n/app_localizations.dart';
import '../../models/audio_file.dart';
import '../../providers/audio_provider.dart';
import 'metadata_extended_section.dart';
import 'metadata_primary_section.dart';
import 'overflow_text_field.dart';

/// Comprehensive audio metadata editor dialog supporting standard writable tags.
class MetadataEditDialog extends StatefulWidget {
  final AudioFile file;

  const MetadataEditDialog({super.key, required this.file});

  @override
  State<MetadataEditDialog> createState() => _MetadataEditDialogState();
}

class _MetadataEditDialogState extends State<MetadataEditDialog> {
  final _formKey = GlobalKey<FormState>();

  // Full-width title
  late final TextEditingController _titleController;

  // Primary fields
  late final TextEditingController _trackArtistController;
  late final TextEditingController _albumArtistController;
  late final TextEditingController _albumController;
  late final TextEditingController _trackNumberController;
  late final TextEditingController _trackTotalController;
  late final TextEditingController _yearController;
  late final TextEditingController _genreController;
  late final TextEditingController _languageController;
  late final TextEditingController _commentController;

  // Extended fields (physically writable)
  late final TextEditingController _discNumberController;
  late final TextEditingController _discTotalController;
  late final TextEditingController _bpmController;
  late final TextEditingController _lyricsController;

  @override
  void initState() {
    super.initState();
    final file = widget.file;
    final metadata = file.metadata;

    _titleController = TextEditingController(text: metadata?.title ?? '');
    _trackArtistController = TextEditingController(text: file.trackArtist);
    _albumArtistController = TextEditingController(text: file.albumArtist);
    _albumController = TextEditingController(text: metadata?.album ?? '');
    _trackNumberController = TextEditingController(
      text: metadata?.trackNumber?.toString() ?? '',
    );
    _trackTotalController = TextEditingController(
      text: metadata?.trackTotal?.toString() ?? '',
    );
    _yearController = TextEditingController(
      text: metadata?.year?.year.toString() ?? '',
    );
    _genreController = TextEditingController(
      text: (metadata?.genres ?? []).join(', '),
    );
    _languageController = TextEditingController(text: metadata?.language ?? '');
    _commentController = TextEditingController(text: file.comment ?? '');

    _discNumberController = TextEditingController(
      text: file.discNumber?.toString() ?? '',
    );
    _discTotalController = TextEditingController(
      text: file.discTotal?.toString() ?? '',
    );
    _bpmController = TextEditingController(
      text: file.bpm != null ? file.bpm.toString() : '',
    );
    _lyricsController = TextEditingController(text: file.lyrics ?? '');
  }

  @override
  void dispose() {
    _titleController.dispose();
    _trackArtistController.dispose();
    _albumArtistController.dispose();
    _albumController.dispose();
    _trackNumberController.dispose();
    _trackTotalController.dispose();
    _yearController.dispose();
    _genreController.dispose();
    _languageController.dispose();
    _commentController.dispose();
    _discNumberController.dispose();
    _discTotalController.dispose();
    _bpmController.dispose();
    _lyricsController.dispose();
    super.dispose();
  }

  void _applyChanges({required bool close}) {
    if (_formKey.currentState?.validate() ?? false) {
      context.read<AudioProvider>().updateMetadata(
        widget.file,
        title: _titleController.text,
        trackArtist: _trackArtistController.text,
        albumArtist: _albumArtistController.text,
        album: _albumController.text,
        trackNumber: _trackNumberController.text,
        trackTotal: _trackTotalController.text,
        year: _yearController.text,
        genre: _genreController.text,
        language: _languageController.text,
        comment: _commentController.text,
        discNumber: int.tryParse(_discNumberController.text.trim()),
        discTotal: int.tryParse(_discTotalController.text.trim()),
        bpm: double.tryParse(_bpmController.text.trim()),
        lyrics: _lyricsController.text,
      );

      if (close) {
        Navigator.of(context).pop();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final textTheme = Theme.of(context).textTheme;

    return Dialog(
      insetPadding: const EdgeInsets.symmetric(
        horizontal: AppConstants.dialogHorizontalPadding,
        vertical: AppConstants.dialogVerticalPadding,
      ),
      child: ConstrainedBox(
        constraints: const BoxConstraints(
          maxWidth: AppConstants.metadataDialogMaxWidth,
          maxHeight: AppConstants.metadataDialogMaxHeight,
        ),
        child: Padding(
          padding: const EdgeInsets.all(AppConstants.dialogPadding),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Header with Title, Filename and Close Button
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          l10n.metadataEditorTitle,
                          style: textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          widget.file.originalFileName,
                          style: textTheme.bodySmall?.copyWith(
                            color: Theme.of(
                              context,
                            ).colorScheme.onSurfaceVariant,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    tooltip: l10n.close,
                    onPressed: () => Navigator.of(context).pop(),
                    icon: const Icon(Icons.close),
                  ),
                ],
              ),
              const SizedBox(height: AppConstants.spacingMedium),

              // Full-width Song Title Input
              OverflowTextField(
                controller: _titleController,
                label: l10n.metadataTitle,
                enablePopout: true,
              ),
              const SizedBox(height: AppConstants.spacingMedium),

              // Dual-column Scrollable Body
              Expanded(
                child: SingleChildScrollView(
                  child: Form(
                    key: _formKey,
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Left Column: Primary Fields
                        Expanded(
                          child: MetadataPrimarySection(
                            trackArtistController: _trackArtistController,
                            albumArtistController: _albumArtistController,
                            albumController: _albumController,
                            trackNumberController: _trackNumberController,
                            trackTotalController: _trackTotalController,
                            yearController: _yearController,
                            genreController: _genreController,
                            languageController: _languageController,
                            commentController: _commentController,
                          ),
                        ),
                        const SizedBox(width: AppConstants.spacingLarge),

                        // Right Column: Extended Fields
                        Expanded(
                          child: MetadataExtendedSection(
                            discNumberController: _discNumberController,
                            discTotalController: _discTotalController,
                            bpmController: _bpmController,
                            lyricsController: _lyricsController,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(height: AppConstants.spacingMedium),

              // Footer Action Buttons
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: () => Navigator.of(context).pop(),
                    child: Text(l10n.cancel),
                  ),
                  const SizedBox(width: AppConstants.spacingSmall),
                  OutlinedButton(
                    onPressed: () => _applyChanges(close: false),
                    child: Text(l10n.apply),
                  ),
                  const SizedBox(width: AppConstants.spacingSmall),
                  FilledButton(
                    onPressed: () => _applyChanges(close: true),
                    child: Text(l10n.confirm),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
