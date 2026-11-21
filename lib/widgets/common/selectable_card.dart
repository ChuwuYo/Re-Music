import 'package:flutter/material.dart';

import '../../constants.dart';

class SelectableCard extends StatelessWidget {
  final bool isSelected;
  final bool isActive;
  final String? hint;
  final VoidCallback onTap;
  final Widget child;

  const SelectableCard({
    super.key,
    required this.isSelected,
    this.isActive = false,
    this.hint,
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
        child: Semantics(
          selected: isSelected,
          button: true,
          hint: hint,
          child: Ink(
            padding: const EdgeInsets.all(AppConstants.spacingMediumSmall),
            decoration: BoxDecoration(
              color: isSelected
                  ? scheme.primary.withValues(alpha: isActive ? 0.22 : 0.12)
                  : Colors.transparent,
              borderRadius: BorderRadius.circular(
                AppConstants.borderRadiusMedium,
              ),
              border: Border.all(
                color: isSelected ? scheme.primary : scheme.outlineVariant,
                width: isActive ? 2 : 1,
              ),
            ),
            child: child,
          ),
        ),
      ),
    );
  }
}
