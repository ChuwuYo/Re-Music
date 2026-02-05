import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../l10n/app_localizations.dart';
import '../models/audio_file.dart';
import '../providers/audio_provider.dart';

class MetadataEditDialog extends StatefulWidget {
  final AudioFile file;

  const MetadataEditDialog({super.key, required this.file});

  @override
  State<MetadataEditDialog> createState() => _MetadataEditDialogState();
}

class _MetadataEditDialogState extends State<MetadataEditDialog> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _titleController;
  late final TextEditingController _artistController;
  late final TextEditingController _albumController;
  late final TextEditingController _trackNumberController;
  late final TextEditingController _trackTotalController;
  late final TextEditingController _yearController;
  late final TextEditingController _genreController;
  late final TextEditingController _languageController;
  late final TextEditingController _commentController;

  @override
  void initState() {
    super.initState();
    final metadata = widget.file.metadata;
    _titleController = TextEditingController(text: metadata?.title ?? '');
    _artistController = TextEditingController(text: metadata?.artist ?? '');
    _albumController = TextEditingController(text: metadata?.album ?? '');
    _trackNumberController = TextEditingController(text: metadata?.trackNumber?.toString() ?? '');
    _trackTotalController = TextEditingController(text: metadata?.trackTotal?.toString() ?? '');
    _yearController = TextEditingController(text: metadata?.year?.year.toString() ?? '');
    _genreController = TextEditingController(text: (metadata?.genres ?? []).join(', '));
    _languageController = TextEditingController(text: metadata?.language ?? '');
    _commentController = TextEditingController(text: widget.file.comment ?? '');
  }

  @override
  void dispose() {
    _titleController.dispose();
    _artistController.dispose();
    _albumController.dispose();
    _trackNumberController.dispose();
    _trackTotalController.dispose();
    _yearController.dispose();
    _genreController.dispose();
    _languageController.dispose();
    _commentController.dispose();
    super.dispose();
  }

  void _applyChanges({required bool close}) {
    if (_formKey.currentState?.validate() ?? false) {
      context.read<AudioProvider>().updateMetadata(
            widget.file,
            title: _titleController.text,
            artist: _artistController.text,
            album: _albumController.text,
            trackNumber: _trackNumberController.text,
            trackTotal: _trackTotalController.text,
            year: _yearController.text,
            genre: _genreController.text,
            language: _languageController.text,
            comment: _commentController.text,
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
      insetPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 720, maxHeight: 640),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(l10n.metadataEditorTitle, style: textTheme.titleLarge),
                        const SizedBox(height: 4),
                        Text(
                          widget.file.originalFileName,
                          style: textTheme.bodySmall,
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
              const SizedBox(height: 16),
              Expanded(
                child: SingleChildScrollView(
                  child: Form(
                    key: _formKey,
                    child: Column(
                      children: [
                        _buildTextField(_titleController, l10n.metadataTitle),
                        const SizedBox(height: 12),
                        _buildTextField(_artistController, l10n.metadataArtist),
                        const SizedBox(height: 12),
                        _buildTextField(_albumController, l10n.metadataAlbum),
                        const SizedBox(height: 12),
                        Row(
                          children: [
                            Expanded(
                              child: _buildTextField(
                                _trackNumberController,
                                l10n.metadataTrackNumber,
                                keyboardType: TextInputType.number,
                                isNumeric: true,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: _buildTextField(
                                _trackTotalController,
                                l10n.metadataTrackTotal,
                                keyboardType: TextInputType.number,
                                isNumeric: true,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        Row(
                          children: [
                            Expanded(
                              child: _buildTextField(
                                _yearController,
                                l10n.metadataYear,
                                keyboardType: TextInputType.number,
                                isNumeric: true,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: _buildTextField(_genreController, l10n.metadataGenre),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        Row(
                          children: [
                            Expanded(
                              child: _buildTextField(_languageController, l10n.metadataLanguage),
                            ),
                            const SizedBox(width: 12),
                            const Expanded(child: SizedBox()),
                          ],
                        ),
                        const SizedBox(height: 12),
                        _buildTextField(
                          _commentController,
                          l10n.metadataComment,
                          keyboardType: TextInputType.multiline,
                          maxLines: 3,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: () => Navigator.of(context).pop(),
                    child: Text(l10n.cancel),
                  ),
                  const SizedBox(width: 8),
                  OutlinedButton(
                    onPressed: () => _applyChanges(close: false),
                    child: Text(l10n.apply),
                  ),
                  const SizedBox(width: 8),
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

  Widget _buildTextField(
    TextEditingController controller,
    String label, {
    TextInputType keyboardType = TextInputType.text,
    int maxLines = 1,
    bool isNumeric = false,
  }) {
    final l10n = AppLocalizations.of(context)!;
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      maxLines: maxLines,
      decoration: InputDecoration(
        labelText: label,
        filled: true,
      ),
      validator: (value) {
        if (isNumeric && value != null && value.isNotEmpty) {
          if (int.tryParse(value) == null) {
            return l10n.invalidNumber;
          }
        }
        return null;
      },
    );
  }
}
