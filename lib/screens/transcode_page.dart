import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../constants.dart';
import '../providers/transcode_provider.dart';
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
            final items = provider.items;
            return CustomScrollView(
              physics: items.isEmpty
                  ? const NeverScrollableScrollPhysics()
                  : null,
              slivers: [
                const SliverToBoxAdapter(child: TranscodeControlPanel()),
                if (items.isEmpty)
                  const SliverFillRemaining(
                    hasScrollBody: false,
                    child: TranscodeEmptyState(),
                  )
                else
                  SliverPadding(
                    padding: const EdgeInsets.only(
                      bottom: AppConstants.homeListBottomPadding,
                    ),
                    sliver: SliverList(
                      delegate: SliverChildBuilderDelegate(
                        (context, index) =>
                            TranscodeItemCard(item: items[index]),
                        childCount: items.length,
                      ),
                    ),
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
