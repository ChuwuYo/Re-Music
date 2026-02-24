import 'package:flutter/material.dart';

import '../../constants.dart';
import '../../l10n/app_localizations.dart';
import '../../models/audio_file.dart';
import '../common/metadata_edit_dialog.dart';

class FileListItem extends StatelessWidget {
  final AudioFile file;

  const FileListItem({super.key, required this.file});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final l10n = AppLocalizations.of(context)!;

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      elevation: 0,
      color: _getCardColor(colorScheme),
      shape: RoundedRectangleBorder(
        side: BorderSide(color: _getBorderColor(colorScheme)),
        borderRadius: BorderRadius.circular(12),
      ),
      child: ListTile(
        leading: _buildLeading(colorScheme),
        title: Text(
          file.originalFileName,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        subtitle: _buildSubtitle(context, colorScheme),
        trailing: _buildTrailing(context, l10n, colorScheme),
      ),
    );
  }

  Widget _buildTrailing(
    BuildContext context,
    AppLocalizations l10n,
    ColorScheme colorScheme,
  ) {
    final canEdit = file.status == ProcessingStatus.success;
    final editButton = IconButton(
      tooltip: l10n.editTags,
      onPressed: canEdit
          ? () {
              showDialog<void>(
                context: context,
                barrierDismissible: false,
                builder: (_) => MetadataEditDialog(file: file),
              );
            }
          : null,
      icon: const Icon(Icons.edit_note_outlined),
    );

    if (file.status == ProcessingStatus.error) {
      return Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Tooltip(
            message: _errorText(l10n),
            child: Icon(Icons.error_outline, color: colorScheme.error),
          ),
          const SizedBox(width: 6),
          editButton,
        ],
      );
    }

    return editButton;
  }

  String _errorText(AppLocalizations l10n) {
    final key = file.errorMessage;
    if (key == 'metadataReadFailed') return l10n.metadataReadFailed;
    return key ?? l10n.unknownError;
  }

  Color _getCardColor(ColorScheme colorScheme) {
    if (file.status == ProcessingStatus.error) {
      return colorScheme.errorContainer.withValues(alpha: 0.1);
    }
    if (file.originalFileName == file.newFileName) {
      return colorScheme.primaryContainer.withValues(
        alpha: AppConstants.matchedNameCardAlpha,
      );
    }
    return colorScheme.surface;
  }

  Color _getBorderColor(ColorScheme colorScheme) {
    if (file.status == ProcessingStatus.error) return colorScheme.error;
    if (file.originalFileName == file.newFileName) {
      return colorScheme.primary.withValues(
        alpha: AppConstants.matchedNameBorderAlpha,
      );
    }
    return colorScheme.outlineVariant;
  }

  Widget _buildLeading(ColorScheme colorScheme) {
    switch (file.status) {
      case ProcessingStatus.pending:
        return const SizedBox(
          width: 24,
          height: 24,
          child: CircularProgressIndicator(strokeWidth: 2),
        );
      case ProcessingStatus.success:
        return Icon(Icons.music_note, color: colorScheme.primary);
      case ProcessingStatus.error:
        return Icon(Icons.error, color: colorScheme.error);
    }
  }

  Widget _buildSubtitle(BuildContext context, ColorScheme colorScheme) {
    final l10n = AppLocalizations.of(context)!;

    if (file.status == ProcessingStatus.pending) {
      return Text(l10n.readingMetadata);
    }

    if (file.status == ProcessingStatus.error) {
      return Text(l10n.readFailed, style: TextStyle(color: colorScheme.error));
    }

    if (file.originalFileName == file.newFileName) {
      return Row(
        children: [
          Icon(
            Icons.check_circle_outline,
            size: 14,
            color: colorScheme.primary,
          ),
          const SizedBox(width: 4),
          Text(l10n.nameMatches, style: TextStyle(color: colorScheme.primary)),
        ],
      );
    }

    return RichText(
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
      text: TextSpan(
        style: Theme.of(context).textTheme.bodyMedium,
        children: [
          TextSpan(text: l10n.renameToPrefix),
          TextSpan(
            text: file.newFileName ?? '',
            style: TextStyle(
              color: colorScheme.primary,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}
