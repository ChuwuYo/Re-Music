import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/transcode_provider.dart';
import '../widgets/common/list_state.dart';
import '../widgets/transcode/transcode_bottom_panel.dart';
import '../widgets/transcode/transcode_control_panel.dart';
import '../widgets/transcode/transcode_empty_state.dart';
import '../widgets/transcode/transcode_item_card.dart';

class TranscodePage extends StatelessWidget {
  const TranscodePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<TranscodeProvider>(
      child: const TranscodeBottomPanel(),
      builder: (context, provider, floatingPanel) {
        final items = provider.displayItems;
        return ListPageScaffold(
          listState: provider.listState,
          controlPanel: const TranscodeControlPanel(),
          empty: const TranscodeEmptyState(),
          noMatch: const TranscodeNoMatchState(),
          itemCount: items.length,
          itemBuilder: (context, index) =>
              TranscodeItemCard(item: items[index]),
          floatingPanel: floatingPanel!,
        );
      },
    );
  }
}
