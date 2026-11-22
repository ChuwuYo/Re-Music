import 'package:flutter/material.dart';

import '../../constants.dart';
import '../../l10n/app_localizations.dart';

/// 添加文件 / 扫描目录的统一按钮组。
class FileImportButtonGroup extends StatelessWidget {
  const FileImportButtonGroup({
    super.key,
    required this.onAddFiles,
    required this.onScanDirectory,
    this.enabled = true,
    this.extraActions = const [],
  });

  final VoidCallback onAddFiles;
  final VoidCallback onScanDirectory;
  final bool enabled;
  final List<Widget> extraActions;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Wrap(
      spacing: AppConstants.spacingSmall,
      runSpacing: AppConstants.spacingSmall,
      children: [
        FilledButton.tonalIcon(
          onPressed: enabled ? onAddFiles : null,
          icon: const Icon(Icons.audio_file),
          label: Text(l10n.addFiles),
        ),
        OutlinedButton.icon(
          onPressed: enabled ? onScanDirectory : null,
          icon: const Icon(Icons.create_new_folder),
          label: Text(l10n.scanDirectory),
        ),
        ...extraActions,
      ],
    );
  }
}
