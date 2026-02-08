import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../l10n/app_localizations.dart';
import '../providers/audio_provider.dart';
import '../widgets/bottom_right_panel.dart';
import '../widgets/file_list_item.dart';
import '../widgets/list_states.dart';
import '../widgets/rename_control_panel.dart';
import '../widgets/title_bar.dart';
import '../widgets/toolbar_row.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Scaffold(
      body: Column(
        children: [
          ReMusicTitleBar(title: l10n.appTitle),
          const ReMusicToolbarRow(),
          Expanded(
            child: Stack(
              children: [
                Consumer<AudioProvider>(
                  builder: (context, provider, child) {
                    final hasAnyFiles = provider.totalFilesCount > 0;
                    return CustomScrollView(
                      physics: hasAnyFiles
                          ? null
                          : const NeverScrollableScrollPhysics(),
                      slivers: [
                        SliverToBoxAdapter(child: const RenameControlPanel()),
                        if (!hasAnyFiles)
                          SliverFillRemaining(
                            hasScrollBody: false,
                            child: const EmptyState(),
                          )
                        else if (provider.files.isEmpty)
                          SliverFillRemaining(
                            hasScrollBody: false,
                            child: const NoMatchState(),
                          )
                        else
                          SliverPadding(
                            padding: const EdgeInsets.only(bottom: 80),
                            sliver: SliverList(
                              delegate: SliverChildBuilderDelegate((
                                context,
                                index,
                              ) {
                                return FileListItem(
                                  file: provider.files[index],
                                );
                              }, childCount: provider.files.length),
                            ),
                          ),
                      ],
                    );
                  },
                ),
                Positioned(
                  right: 16,
                  bottom: 16,
                  child: SafeArea(child: const BottomRightPanel()),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
