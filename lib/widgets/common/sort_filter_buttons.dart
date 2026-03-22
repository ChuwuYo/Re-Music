import 'package:flutter/material.dart';

import 'smart_menu_anchor.dart';

/// A generic menu option for filter or sort menus.
class MenuOption<T> {
  final T value;
  final String label;
  const MenuOption({required this.value, required this.label});
}

/// A generic filter menu button using [SmartMenuAnchor].
///
/// Highlights the icon when filter is not [defaultValue].
class FilterMenuButton<T> extends StatelessWidget {
  final T currentValue;
  final T defaultValue;
  final List<MenuOption<T>> options;
  final ValueChanged<T> onSelected;
  final String tooltip;

  const FilterMenuButton({
    super.key,
    required this.currentValue,
    required this.defaultValue,
    required this.options,
    required this.onSelected,
    required this.tooltip,
  });

  @override
  Widget build(BuildContext context) {
    return SmartMenuAnchor(
      tooltip: tooltip,
      icon: Icon(
        Icons.filter_list,
        color: currentValue != defaultValue
            ? Theme.of(context).colorScheme.primary
            : null,
      ),
      widthEstimationLabels: options.map((o) => o.label).toList(),
      menuChildren: options
          .map(
            (option) => MenuItemButton(
              onPressed: () => onSelected(option.value),
              leadingIcon: currentValue == option.value
                  ? const Icon(Icons.check)
                  : const SizedBox(width: 24),
              child: Text(option.label),
            ),
          )
          .toList(),
    );
  }
}

/// A generic sort criteria menu button using [SmartMenuAnchor].
class SortMenuButton extends StatelessWidget {
  final String currentCriteria;
  final List<MenuOption<String>> options;
  final ValueChanged<String> onSelected;
  final String tooltip;

  const SortMenuButton({
    super.key,
    required this.currentCriteria,
    required this.options,
    required this.onSelected,
    required this.tooltip,
  });

  @override
  Widget build(BuildContext context) {
    return SmartMenuAnchor(
      tooltip: tooltip,
      icon: const Icon(Icons.sort),
      widthEstimationLabels: options.map((o) => o.label).toList(),
      menuChildren: options
          .map(
            (option) => MenuItemButton(
              onPressed: () => onSelected(option.value),
              leadingIcon: currentCriteria == option.value
                  ? const Icon(Icons.check)
                  : const SizedBox(width: 24),
              child: Text(option.label),
            ),
          )
          .toList(),
    );
  }
}

/// A toggle button for sort order (ascending / descending).
class SortOrderButton extends StatelessWidget {
  final bool ascending;
  final VoidCallback onToggle;
  final String ascendingTooltip;
  final String descendingTooltip;

  const SortOrderButton({
    super.key,
    required this.ascending,
    required this.onToggle,
    required this.ascendingTooltip,
    required this.descendingTooltip,
  });

  @override
  Widget build(BuildContext context) {
    return IconButton(
      tooltip: ascending ? ascendingTooltip : descendingTooltip,
      icon: Icon(ascending ? Icons.arrow_upward : Icons.arrow_downward),
      onPressed: onToggle,
    );
  }
}
