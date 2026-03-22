import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../l10n/app_localizations.dart';
import '../../providers/transcode_provider.dart';

class TranscodeSettings extends StatelessWidget {
  const TranscodeSettings({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final provider = context.watch<TranscodeProvider>();

    return Column(
      children: [
        SwitchListTile.adaptive(
          contentPadding: EdgeInsets.zero,
          title: Text(l10n.transcodeAllowFormatOnly),
          value: provider.allowFormatOnlyConversion,
          onChanged: context
              .read<TranscodeProvider>()
              .setAllowFormatOnlyConversion,
        ),
        SwitchListTile.adaptive(
          contentPadding: EdgeInsets.zero,
          title: Text(l10n.transcodeEnableDither),
          subtitle: Text(l10n.transcodeEnableDitherSubtitle),
          value: provider.enableDither,
          onChanged: context.read<TranscodeProvider>().setEnableDither,
        ),
      ],
    );
  }
}
