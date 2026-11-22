import 'package:flutter/material.dart';

import '../../constants.dart';
import '../../l10n/app_localizations.dart';
import '../common/list_state.dart';

class EmptyState extends StatelessWidget {
  const EmptyState({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return ListStateMessage(
      icon: Icons.library_music_outlined,
      iconSize: AppConstants.iconSizeHuge,
      title: l10n.emptyTitle,
      subtitle: l10n.emptySubtitle,
    );
  }
}

class NoMatchState extends StatelessWidget {
  const NoMatchState({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return ListStateMessage(
      icon: Icons.filter_alt_off_outlined,
      iconSize: AppConstants.iconSizeExtraLarge,
      title: l10n.noMatchTitle,
      subtitle: l10n.noMatchSubtitle,
    );
  }
}
