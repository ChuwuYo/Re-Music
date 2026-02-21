import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../constants.dart';
import '../l10n/app_localizations.dart';
import '../providers/audio_provider.dart';
import '../providers/navigation_provider.dart';
import '../widgets/bottom_right_panel.dart';
import '../widgets/file_list_item.dart';
import '../widgets/left_sidebar.dart';
import '../widgets/list_states.dart';
import '../widgets/rename_control_panel.dart';
import '../widgets/title_bar.dart';
import 'settings_page.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final currentPage = context.watch<NavigationController>().currentPage;
    return Scaffold(
      body: Column(
        children: [
          ReMusicTitleBar(title: l10n.appTitle),
          Expanded(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const LeftSidebar(),
                Expanded(
                  child: AnimatedSwitcher(
                    duration: AppConstants.defaultAnimationDuration,
                    switchInCurve: Curves.easeInOut,
                    switchOutCurve: Curves.easeInOut,
                    transitionBuilder: (child, animation) {
                      final offsetAnimation = Tween<Offset>(
                        begin: const Offset(0.03, 0),
                        end: Offset.zero,
                      ).animate(animation);
                      return FadeTransition(
                        opacity: animation,
                        child: SlideTransition(
                          position: offsetAnimation,
                          child: child,
                        ),
                      );
                    },
                    child: currentPage == AppPage.home
                        ? const _HomeContent(key: ValueKey(AppPage.home))
                        : const SettingsPage(key: ValueKey(AppPage.settings)),
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

/// 主页内容区（文件列表 + 重命名控制面板）
class _HomeContent extends StatelessWidget {
  const _HomeContent({super.key});

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Consumer<AudioProvider>(
          builder: (context, provider, child) {
            final hasAnyFiles = provider.totalFilesCount > 0;
            return CustomScrollView(
              physics: hasAnyFiles
                  ? null
                  : const NeverScrollableScrollPhysics(),
              slivers: [
                const SliverToBoxAdapter(child: RenameControlPanel()),
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
                      delegate: SliverChildBuilderDelegate(
                        (context, index) =>
                            FileListItem(file: provider.files[index]),
                        childCount: provider.files.length,
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
          child: SafeArea(child: BottomRightPanel()),
        ),
      ],
    );
  }
}
