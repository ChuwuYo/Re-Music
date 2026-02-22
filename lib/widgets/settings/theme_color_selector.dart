import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../constants.dart';
import '../../l10n/app_localizations.dart';
import '../../providers/theme_provider.dart';
import '../common/selectable_card.dart';

class ThemeColorSelector extends StatelessWidget {
  const ThemeColorSelector({super.key});

  /// 根据种子颜色获取本地化标签
  static String _seedColorLabel(AppLocalizations l10n, AppSeedColor seed) {
    return switch (seed) {
      AppSeedColor.teal => l10n.themeColorTeal,
      AppSeedColor.blue => l10n.themeColorBlue,
      AppSeedColor.indigo => l10n.themeColorIndigo,
      AppSeedColor.purple => l10n.themeColorPurple,
      AppSeedColor.pink => l10n.themeColorPink,
      AppSeedColor.orange => l10n.themeColorOrange,
      AppSeedColor.green => l10n.themeColorGreen,
      AppSeedColor.red => l10n.themeColorRed,
    };
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final themeController = context.watch<ThemeController>();
    final selectedColor = themeController.seedColor;
    final scheme = Theme.of(context).colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          l10n.themeColor,
          style: Theme.of(
            context,
          ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w500),
        ),
        const SizedBox(height: AppConstants.spacingMediumSmall),
        Wrap(
          spacing: AppConstants.spacingSmall,
          runSpacing: AppConstants.spacingSmall,
          children: AppSeedColor.values.map((seed) {
            final isSelected = seed == selectedColor;
            return SelectableCard(
              isSelected: isSelected,
              onTap: () => context.read<ThemeController>().setSeedColor(seed),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 20,
                    height: 20,
                    decoration: BoxDecoration(
                      color: seed.color,
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: scheme.outline.withValues(alpha: 0.3),
                      ),
                    ),
                  ),
                  const SizedBox(width: AppConstants.spacingSmall),
                  Text(
                    _seedColorLabel(l10n, seed),
                    style: TextStyle(
                      color: isSelected ? scheme.primary : scheme.onSurface,
                      fontWeight: isSelected
                          ? FontWeight.w500
                          : FontWeight.normal,
                    ),
                  ),
                ],
              ),
            );
          }).toList(),
        ),
      ],
    );
  }
}
