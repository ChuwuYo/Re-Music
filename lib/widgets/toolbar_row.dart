import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../l10n/app_localizations.dart';
import '../providers/audio_provider.dart';
import '../providers/locale_provider.dart';
import '../providers/theme_provider.dart';
import 'smart_menu_anchor.dart';
import '../constants.dart';

class ReMusicToolbarRow extends StatelessWidget {
  const ReMusicToolbarRow({super.key});

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

    return Material(
      color: scheme.surface,
      child: DecoratedBox(
        decoration: BoxDecoration(
          border: Border(
            bottom: BorderSide(
              color: scheme.outlineVariant.withValues(alpha: 0.7),
            ),
          ),
        ),
        child: SizedBox(
          height: 48,
          child: Row(
            children: [
              const SizedBox(width: 4),
              SmartMenuAnchor(
                useFilledButton: false,
                tooltip: l10n.language,
                icon: const Icon(Icons.language),
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
                    onPressed: () => context.read<LocaleController>().setLocale(
                      const Locale('zh'),
                    ),
                    leadingIcon: localeController.locale?.languageCode == 'zh'
                        ? const Icon(Icons.check)
                        : const SizedBox(width: 24),
                    child: Text(l10n.chinese),
                  ),
                  MenuItemButton(
                    onPressed: () => context.read<LocaleController>().setLocale(
                      const Locale('en'),
                    ),
                    leadingIcon: localeController.locale?.languageCode == 'en'
                        ? const Icon(Icons.check)
                        : const SizedBox(width: 24),
                    child: Text(l10n.english),
                  ),
                ],
              ),
              IconButton(
                tooltip: themeController.isDark
                    ? l10n.switchToLight
                    : l10n.switchToDark,
                icon: Icon(
                  themeController.isDark ? Icons.light_mode : Icons.dark_mode,
                ),
                onPressed: () =>
                    context.read<ThemeController>().toggleThemeMode(),
              ),
              SmartMenuAnchor(
                useFilledButton: false,
                tooltip: l10n.themeColor,
                icon: const Icon(Icons.palette_outlined),
                estimatedMenuWidth: 280,
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
              Consumer<AudioProvider>(
                builder: (context, provider, child) {
                  return IconButton(
                    icon: const Icon(Icons.delete_sweep_outlined),
                    onPressed: provider.totalFilesCount == 0
                        ? null
                        : () => provider.clearFiles(),
                    tooltip: l10n.clearList,
                  );
                },
              ),
              const Spacer(),
              const SizedBox(width: 4),
            ],
          ),
        ),
      ),
    );
  }
}
