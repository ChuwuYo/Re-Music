import 'package:flutter/material.dart';

import '../../constants.dart';

/// 空态/无匹配态的统一视觉组件。
class ListStateMessage extends StatelessWidget {
  const ListStateMessage({
    super.key,
    required this.icon,
    required this.iconSize,
    required this.title,
    required this.subtitle,
  });

  final IconData icon;
  final double iconSize;
  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: AppConstants.spacingLarge,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: iconSize, color: scheme.surfaceContainerHighest),
            const SizedBox(height: AppConstants.spacingLarge),
            Text(
              title,
              style: textTheme.headlineSmall?.copyWith(
                color: scheme.onSurfaceVariant,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppConstants.spacingSmall),
            Text(
              subtitle,
              style: textTheme.bodyMedium?.copyWith(color: scheme.outline),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

/// 空态/无匹配态/有内容的统一 sliver 分支组件。
class ListStateSliver extends StatelessWidget {
  const ListStateSliver({
    super.key,
    required this.state,
    required this.empty,
    required this.noMatch,
    required this.itemCount,
    required this.itemBuilder,
    this.bottomPadding = AppConstants.homeListBottomPadding,
  });

  final ListState state;
  final Widget empty;
  final Widget noMatch;
  final int itemCount;
  final IndexedWidgetBuilder itemBuilder;
  final double bottomPadding;

  @override
  Widget build(BuildContext context) {
    return switch (state) {
      ListState.empty => SliverFillRemaining(
        hasScrollBody: false,
        child: empty,
      ),
      ListState.noMatch => SliverFillRemaining(
        hasScrollBody: false,
        child: noMatch,
      ),
      ListState.ready => SliverPadding(
        padding: EdgeInsets.only(bottom: bottomPadding),
        sliver: SliverList(
          delegate: SliverChildBuilderDelegate(
            itemBuilder,
            childCount: itemCount,
          ),
        ),
      ),
    };
  }
}
