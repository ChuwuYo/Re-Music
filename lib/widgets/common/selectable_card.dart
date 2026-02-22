import 'package:flutter/material.dart';

import '../../constants.dart';

class SelectableCard extends StatelessWidget {
  final bool isSelected;
  final VoidCallback onTap;
  final Widget child;

  const SelectableCard({
    super.key,
    required this.isSelected,
    required this.onTap,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppConstants.borderRadiusMedium),
        child: Container(
          padding: const EdgeInsets.symmetric(
            horizontal: AppConstants.spacingSmall + AppConstants.spacingExtraSmall,
            vertical: AppConstants.spacingSmall + AppConstants.spacingExtraSmall,
          ),
          decoration: BoxDecoration(
            color: isSelected
                ? scheme.primary.withValues(alpha: 0.12)
                : Colors.transparent,
            borderRadius: BorderRadius.circular(AppConstants.borderRadiusMedium),
            border: Border.all(
              color: isSelected ? scheme.primary : scheme.outlineVariant,
              width: isSelected ? 2 : 1,
            ),
          ),
          child: child,
        ),
      ),
    );
  }
}
