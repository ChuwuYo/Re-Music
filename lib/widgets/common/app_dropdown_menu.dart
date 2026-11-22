import 'package:flutter/material.dart';

/// Shared Material 3 dropdown for ReMusic.
///
/// Keeps the filled/floating-label look in one place and uses [MenuAnchor]-
/// based positioning instead of the legacy `DropdownButtonFormField` popup.
class AppDropdownMenu<T> extends StatelessWidget {
  const AppDropdownMenu({
    super.key,
    required this.label,
    required this.entries,
    this.initialSelection,
    required this.onSelected,
    this.hintText,
    this.leadingIcon,
    this.width,
    this.controller,
    this.enabled = true,
    this.enableFilter = false,
  });

  final Widget label;
  final T? initialSelection;
  final List<DropdownMenuEntry<T>> entries;
  final ValueChanged<T?>? onSelected;
  final String? hintText;
  final Widget? leadingIcon;
  final double? width;
  final TextEditingController? controller;
  final bool enabled;
  final bool enableFilter;

  @override
  Widget build(BuildContext context) {
    return DropdownMenu<T>(
      key: key ?? ValueKey(initialSelection),
      enabled: enabled,
      width: width,
      controller: controller,
      initialSelection: initialSelection,
      label: label,
      hintText: hintText,
      leadingIcon: leadingIcon,
      enableFilter: enableFilter,
      requestFocusOnTap: true,
      inputDecorationTheme: const InputDecorationTheme(
        filled: true,
        contentPadding: EdgeInsets.symmetric(vertical: 5.0),
      ),
      dropdownMenuEntries: entries,
      onSelected: enabled ? onSelected : null,
    );
  }
}
