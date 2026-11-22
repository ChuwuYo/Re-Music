import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../constants.dart';
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
    return Stack(
      children: [
        Consumer<TranscodeProvider>(
          builder: (context, provider, child) {
            final listState = provider.listState;
            final items = provider.displayItems;
            return CustomScrollView(
              physics: listState == ListState.empty
                  ? const NeverScrollableScrollPhysics()
                  : null,
              slivers: [
                const SliverToBoxAdapter(child: TranscodeControlPanel()),
                ListStateSliver(
                  state: listState,
                  empty: const TranscodeEmptyState(),
                  noMatch: const TranscodeNoMatchState(),
                  itemCount: items.length,
                  itemBuilder: (context, index) =>
                      TranscodeItemCard(item: items[index]),
                ),
              ],
            );
          },
        ),
        const Positioned(
          right: 16,
          bottom: 16,
          child: SafeArea(child: TranscodeBottomPanel()),
        ),
      ],
    );
  }
}
