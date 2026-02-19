import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../l10n/app_localizations.dart';
import '../providers/audio_provider.dart';
import '../widgets/bottom_right_panel.dart';
import '../widgets/file_list_item.dart';
import '../widgets/left_sidebar.dart';
import '../widgets/list_states.dart';
import '../widgets/rename_control_panel.dart';
import '../widgets/title_bar.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Scaffold(
      body: Column(
        children: [
          ReMusicTitleBar(title: l10n.appTitle),
          Expanded(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 左侧竖向工具栏
                const LeftSidebar(),
                // 主内容区
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
                              const SliverToBoxAdapter(
                                child: RenameControlPanel(),
                              ),
                              if (!hasAnyFiles)
                                const SliverFillRemaining(
                                  hasScrollBody: false,
                                  child: EmptyState(),
                                )
                              else if (provider.files.isEmpty)
                                const SliverFillRemaining(
                                  hasScrollBody: false,
                                  child: NoMatchState(),
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
                      const Positioned(
                        right: 16,
                        bottom: 16,
                        child: SafeArea(child: BottomRightPanel()),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
