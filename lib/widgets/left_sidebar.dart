import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../constants.dart';
import '../l10n/app_localizations.dart';
import '../providers/audio_provider.dart';
import '../providers/locale_provider.dart';
import '../providers/theme_provider.dart';

/// 左侧竖向工具栏：支持展开（图标+文字）和收起（仅图标）两种状态。
/// 窗口宽度小于 [AppConstants.sidebarAutoCollapseWidth] 时自动收起。
class LeftSidebar extends StatefulWidget {
  const LeftSidebar({super.key});

  @override
  State<LeftSidebar> createState() => _LeftSidebarState();
}

class _LeftSidebarState extends State<LeftSidebar> {
  bool _userWantsExpanded = false;

  static const double _collapsedWidth = 56.0;
  static const double _expandedWidth = 220.0;

  void _toggle() => setState(() => _userWantsExpanded = !_userWantsExpanded);

  String _seedColorLabel(AppLocalizations l10n, AppSeedColor seed) {
    switch (seed) {
      case AppSeedColor.teal:
        return l10n.themeColorTeal;
      case AppSeedColor.blue:
        return l10n.themeColorBlue;
      case AppSeedColor.indigo:
        return l10n.themeColorIndigo;
      case AppSeedColor.purple:
        return l10n.themeColorPurple;
      case AppSeedColor.pink:
        return l10n.themeColorPink;
      case AppSeedColor.orange:
        return l10n.themeColorOrange;
      case AppSeedColor.green:
        return l10n.themeColorGreen;
      case AppSeedColor.red:
        return l10n.themeColorRed;
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final scheme = Theme.of(context).colorScheme;
    final localeController = context.watch<LocaleController>();
    final themeController = context.watch<ThemeController>();

    // 响应式：订阅窗口宽度变化，宽度不足时自动收起
    final windowWidth = MediaQuery.sizeOf(context).width;
    final expanded =
        _userWantsExpanded &&
        windowWidth >= AppConstants.sidebarAutoCollapseWidth;
    // 用户想展开但窗口太窄：需要给出视觉提示
    final forcedCollapsed = _userWantsExpanded && !expanded;

    return ClipRect(
      child: AnimatedContainer(
        duration: AppConstants.defaultAnimationDuration,
        curve: Curves.easeInOut,
        width: expanded ? _expandedWidth : _collapsedWidth,
        child: SizedBox(
          width: _expandedWidth,
          child: Material(
            color: scheme.surfaceContainerLow,
            child: DecoratedBox(
              decoration: BoxDecoration(
                border: Border(
                  right: BorderSide(
                    color: scheme.outlineVariant.withValues(alpha: 0.7),
                  ),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // ── 折叠/展开按钮 ──────────────────────────────────
                  _SidebarItem(
                    icon: expanded ? Icons.menu_open : Icons.menu,
                    label: expanded ? l10n.sidebarCollapse : l10n.sidebarExpand,
                    tooltip: forcedCollapsed
                        ? l10n.sidebarTooNarrow
                        : (expanded
                              ? l10n.sidebarCollapse
                              : l10n.sidebarExpand),
                    expanded: expanded,
                    showLabel: false,
                    showBadge: forcedCollapsed,
                    onPressed: _toggle,
                  ),

                  const Divider(height: 1, indent: 8, endIndent: 8),

                  const Spacer(),

                  const Divider(height: 1, indent: 8, endIndent: 8),

                  // ── 语言菜单 ───────────────────────────────────────
                  _SidebarMenuAnchor(
                    icon: Icons.language,
                    label: l10n.language,
                    tooltip: l10n.language,
                    expanded: expanded,
                    menuAnchorAlignment: AlignmentDirectional.topEnd,
                    menuChildren: [
                      MenuItemButton(
                        onPressed: () =>
                            context.read<LocaleController>().setLocale(null),
                        leadingIcon: localeController.locale == null
                            ? const Icon(Icons.check)
                            : const SizedBox(width: 24),
                        child: Text(l10n.followSystem),
                      ),
                      MenuItemButton(
                        onPressed: () => context
                            .read<LocaleController>()
                            .setLocale(const Locale('zh')),
                        leadingIcon:
                            localeController.locale?.languageCode == 'zh'
                            ? const Icon(Icons.check)
                            : const SizedBox(width: 24),
                        child: Text(l10n.chinese),
                      ),
                      MenuItemButton(
                        onPressed: () => context
                            .read<LocaleController>()
                            .setLocale(const Locale('en')),
                        leadingIcon:
                            localeController.locale?.languageCode == 'en'
                            ? const Icon(Icons.check)
                            : const SizedBox(width: 24),
                        child: Text(l10n.english),
                      ),
                    ],
                  ),

                  // ── 明暗主题切换 ───────────────────────────────────
                  _SidebarItem(
                    icon: themeController.isDark
                        ? Icons.light_mode
                        : Icons.dark_mode,
                    label: themeController.isDark
                        ? l10n.switchToLight
                        : l10n.switchToDark,
                    tooltip: themeController.isDark
                        ? l10n.switchToLight
                        : l10n.switchToDark,
                    expanded: expanded,
                    onPressed: () =>
                        context.read<ThemeController>().toggleThemeMode(),
                  ),

                  // ── 主题颜色菜单 ───────────────────────────────────
                  _SidebarMenuAnchor(
                    icon: Icons.palette_outlined,
                    label: l10n.themeColor,
                    tooltip: l10n.themeColor,
                    expanded: expanded,
                    menuAnchorAlignment: AlignmentDirectional.topEnd,
                    menuChildren: AppSeedColor.values.map((seed) {
                      final selected = themeController.seedColor;
                      return MenuItemButton(
                        onPressed: () =>
                            context.read<ThemeController>().setSeedColor(seed),
                        leadingIcon: seed == selected
                            ? const Icon(Icons.check)
                            : const SizedBox(width: 24),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Container(
                              width: 12,
                              height: 12,
                              decoration: BoxDecoration(
                                color: seed.color,
                                shape: BoxShape.circle,
                              ),
                            ),
                            const SizedBox(width: 10),
                            Text(_seedColorLabel(l10n, seed)),
                          ],
                        ),
                      );
                    }).toList(),
                  ),

                  // ── 清空列表 ───────────────────────────────────────
                  Consumer<AudioProvider>(
                    builder: (context, provider, child) {
                      return _SidebarItem(
                        icon: Icons.delete_sweep_outlined,
                        label: l10n.clearList,
                        tooltip: l10n.clearList,
                        expanded: expanded,
                        onPressed: provider.totalFilesCount == 0
                            ? null
                            : () => provider.clearFiles(),
                      );
                    },
                  ),

                  const SizedBox(height: 8),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// 私有辅助 Widget
// ---------------------------------------------------------------------------

/// 普通可点击侧边栏项，支持可选 Badge 点标记。
class _SidebarItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final String? tooltip;
  final bool expanded;
  final bool showLabel;
  final bool showBadge;
  final VoidCallback? onPressed;

  const _SidebarItem({
    required this.icon,
    required this.label,
    required this.expanded,
    required this.onPressed,
    this.tooltip,
    this.showLabel = true,
    this.showBadge = false,
  });

  @override
  Widget build(BuildContext context) {
    final showText = expanded && showLabel;
    Widget iconWidget = Icon(icon);
    if (showBadge) {
      iconWidget = Badge(
        smallSize: 6,
        backgroundColor: Theme.of(context).colorScheme.primary,
        child: iconWidget,
      );
    }

    if (!showText) {
      return Tooltip(
        message: tooltip ?? label,
        child: SizedBox(
          height: 48,
          width: double.infinity,
          child: IconButton(
            icon: iconWidget,
            onPressed: onPressed,
            style: IconButton.styleFrom(shape: const RoundedRectangleBorder()),
          ),
        ),
      );
    }

    return Tooltip(
      message: tooltip ?? label,
      child: SizedBox(
        height: 48,
        width: double.infinity,
        child: TextButton(
          onPressed: onPressed,
          style: TextButton.styleFrom(
            alignment: Alignment.centerLeft,
            padding: const EdgeInsets.symmetric(horizontal: 14),
            shape: const RoundedRectangleBorder(),
          ),
          child: Row(
            children: [
              iconWidget,
              const SizedBox(width: 14),
              Expanded(child: Text(label, overflow: TextOverflow.ellipsis)),
            ],
          ),
        ),
      ),
    );
  }
}

/// 带弹出菜单的侧边栏项
class _SidebarMenuAnchor extends StatefulWidget {
  final IconData icon;
  final String label;
  final String tooltip;
  final bool expanded;
  final AlignmentGeometry menuAnchorAlignment;
  final List<Widget> menuChildren;

  const _SidebarMenuAnchor({
    required this.icon,
    required this.label,
    required this.tooltip,
    required this.expanded,
    required this.menuChildren,
    this.menuAnchorAlignment = AlignmentDirectional.topEnd,
  });

  @override
  State<_SidebarMenuAnchor> createState() => _SidebarMenuAnchorState();
}

class _SidebarMenuAnchorState extends State<_SidebarMenuAnchor> {
  final MenuController _menuController = MenuController();

  @override
  Widget build(BuildContext context) {
    void onTap() {
      if (_menuController.isOpen) {
        _menuController.close();
      } else {
        _menuController.open();
      }
    }

    return MenuAnchor(
      controller: _menuController,
      menuChildren: widget.menuChildren,
      style: MenuStyle(alignment: widget.menuAnchorAlignment),
      builder: (context, controller, child) {
        if (!widget.expanded) {
          return Tooltip(
            message: widget.tooltip,
            child: SizedBox(
              height: 48,
              width: double.infinity,
              child: IconButton(
                icon: Icon(widget.icon),
                onPressed: onTap,
                style: IconButton.styleFrom(
                  shape: const RoundedRectangleBorder(),
                ),
              ),
            ),
          );
        }

        return Tooltip(
          message: widget.tooltip,
          child: SizedBox(
            height: 48,
            width: double.infinity,
            child: TextButton(
              onPressed: onTap,
              style: TextButton.styleFrom(
                alignment: Alignment.centerLeft,
                padding: const EdgeInsets.symmetric(horizontal: 14),
                shape: const RoundedRectangleBorder(),
              ),
              child: Row(
                children: [
                  Icon(widget.icon),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Text(widget.label, overflow: TextOverflow.ellipsis),
                  ),
                  const Icon(Icons.chevron_right, size: 18),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
