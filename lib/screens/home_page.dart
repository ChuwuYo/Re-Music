import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../constants.dart';
import '../l10n/app_localizations.dart';
import '../providers/audio_provider.dart';
import '../providers/navigation_provider.dart';
import '../widgets/common/left_sidebar.dart';
import '../widgets/common/list_state.dart';
import '../widgets/common/title_bar.dart';
import '../widgets/home/bottom_right_panel.dart';
import '../widgets/home/file_list_item.dart';
import '../widgets/home/list_states.dart';
import '../widgets/home/rename_control_panel.dart';
import 'settings_page.dart';
import 'transcode_page.dart';

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
                    transitionBuilder: (child, animation) {
                      final isIncoming = child.key == ValueKey(currentPage);
                      final curved = CurvedAnimation(
                        parent: animation,
                        curve: Curves.easeInOut,
                      );
                      final offsetAnimation = Tween<Offset>(
                        begin: Offset(
                          0,
                          isIncoming
                              ? AppConstants.pageTransitionSlideOffset
                              : -AppConstants.pageTransitionSlideOffset,
                        ),
                        end: Offset.zero,
                      ).animate(curved);
                      return FadeTransition(
                        opacity: curved,
                        child: SlideTransition(
                          position: offsetAnimation,
                          child: child,
                        ),
                      );
                    },
                    child: switch (currentPage) {
                      AppPage.home => const _HomeContent(
                        key: ValueKey(AppPage.home),
                      ),
                      AppPage.transcode => const TranscodePage(
                        key: ValueKey(AppPage.transcode),
                      ),
                      AppPage.settings => const SettingsPage(
                        key: ValueKey(AppPage.settings),
                      ),
                    },
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

class _HomeContent extends StatelessWidget {
  const _HomeContent({super.key});

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Consumer<AudioProvider>(
          builder: (context, provider, child) {
            final listState = provider.listState;
            final files = provider.files;
            return CustomScrollView(
              physics: listState == ListState.empty
                  ? const NeverScrollableScrollPhysics()
                  : null,
              slivers: [
                const SliverToBoxAdapter(child: RenameControlPanel()),
                ListStateSliver(
                  state: listState,
                  empty: const EmptyState(),
                  noMatch: const NoMatchState(),
                  itemCount: files.length,
                  itemBuilder: (context, index) =>
                      FileListItem(file: files[index]),
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
