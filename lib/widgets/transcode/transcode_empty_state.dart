import 'package:flutter/material.dart';

import '../../constants.dart';
import '../../l10n/app_localizations.dart';
import '../common/list_state.dart';

class TranscodeEmptyState extends StatelessWidget {
  const TranscodeEmptyState({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return ListStateMessage(
      icon: Icons.multitrack_audio,
      iconSize: AppConstants.iconSizeHuge,
      title: l10n.transcodeEmptyTitle,
      subtitle: l10n.transcodeEmptySubtitle,
    );
  }
}

class TranscodeNoMatchState extends StatelessWidget {
  const TranscodeNoMatchState({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return ListStateMessage(
      icon: Icons.filter_alt_off_outlined,
      iconSize: AppConstants.iconSizeExtraLarge,
      title: l10n.transcodeNoMatchTitle,
      subtitle: l10n.transcodeNoMatchSubtitle,
    );
  }
}
