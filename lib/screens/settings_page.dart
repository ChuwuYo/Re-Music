import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../constants.dart';
import '../l10n/app_localizations.dart';
import '../providers/theme_provider.dart';
import '../widgets/common/selectable_card.dart';
import '../widgets/settings/theme_color_selector.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppConstants.spacingLarge),
        child: Center(
          child: Container(
            constraints: const BoxConstraints(maxWidth: 720),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  l10n.navSettings,
                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: AppConstants.spacingExtraLarge),
                _SettingsCard(
                  title: l10n.appearance,
                  children: [
                    const _ThemeModeSelector(),
                    const SizedBox(height: AppConstants.spacingLarge),
                    const ThemeColorSelector(),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _SettingsCard extends StatelessWidget {
  final String title;
  final List<Widget> children;

  const _SettingsCard({required this.title, required this.children});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppConstants.spacingMedium),
      decoration: BoxDecoration(
        color: scheme.surfaceContainerLow,
        borderRadius: BorderRadius.circular(AppConstants.borderRadiusMedium),
        border: Border.all(color: scheme.outlineVariant.withValues(alpha: 0.5)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              color: scheme.primary,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: AppConstants.spacingMedium),
          ...children,
        ],
      ),
    );
  }
}

class _ThemeModeSelector extends StatelessWidget {
  const _ThemeModeSelector();

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final themeController = context.watch<ThemeController>();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          l10n.themeMode,
          style: Theme.of(
            context,
          ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w500),
        ),
        const SizedBox(height: AppConstants.spacingMediumSmall),
        Row(
          children: [
            Expanded(
              child: _ThemeModeOption(
                icon: Icons.light_mode,
                label: l10n.switchToLight,
                isSelected: themeController.themeMode == ThemeMode.light,
                onTap: () => context.read<ThemeController>().setThemeMode(
                  ThemeMode.light,
                ),
              ),
            ),
            const SizedBox(width: AppConstants.spacingSmall),
            Expanded(
              child: _ThemeModeOption(
                icon: Icons.dark_mode,
                label: l10n.switchToDark,
                isSelected: themeController.themeMode == ThemeMode.dark,
                onTap: () => context.read<ThemeController>().setThemeMode(
                  ThemeMode.dark,
                ),
              ),
            ),
            const SizedBox(width: AppConstants.spacingSmall),
            Expanded(
              child: _ThemeModeOption(
                icon: Icons.brightness_auto,
                label: l10n.followSystem,
                isSelected: themeController.themeMode == ThemeMode.system,
                onTap: () => context.read<ThemeController>().setThemeMode(
                  ThemeMode.system,
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _ThemeModeOption extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _ThemeModeOption({
    required this.icon,
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return SelectableCard(
      isSelected: isSelected,
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(
          vertical: AppConstants.spacingMedium,
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              color: isSelected ? scheme.primary : scheme.onSurfaceVariant,
            ),
            const SizedBox(height: AppConstants.spacingSmall),
            Text(
              label,
              style: TextStyle(
                color: isSelected ? scheme.primary : scheme.onSurface,
                fontWeight: isSelected ? FontWeight.w500 : FontWeight.normal,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
