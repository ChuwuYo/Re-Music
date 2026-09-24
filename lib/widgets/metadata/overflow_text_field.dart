import 'package:flutter/material.dart';
import '../../l10n/app_localizations.dart';

/// An adaptive text form field built for desktop forms that handles text overflow gracefully.
///
/// Complies with Material Design 3, Fluent Design, and W3C accessibility guidelines:
/// - Supports multiline expansion ([minLines], [maxLines]) to avoid clipping.
/// - Provides a hover [Tooltip] displaying the full text content.
/// - Offers an optional popout modal editor ([enablePopout]) for comfortably editing long content.
class OverflowTextField extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final String? hintText;
  final int minLines;
  final int maxLines;
  final TextInputType keyboardType;
  final bool isNumeric;
  final bool enablePopout;
  final FormFieldValidator<String>? validator;
  final bool allowDecimal;
  final ValueChanged<String>? onChanged;

  const OverflowTextField({
    super.key,
    required this.controller,
    required this.label,
    this.hintText,
    this.minLines = 1,
    this.maxLines = 1,
    this.keyboardType = TextInputType.text,
    this.isNumeric = false,
    this.allowDecimal = false,
    this.enablePopout = false,
    this.validator,
    this.onChanged,
  });

  void _openPopoutEditor(BuildContext context) async {
    final l10n = AppLocalizations.of(context);
    final cancelText = l10n?.cancel ?? 'Cancel';
    final confirmText = l10n?.confirm ?? 'Confirm';

    final result = await showDialog<String>(
      context: context,
      builder: (dialogContext) => _PopoutEditorDialog(
        label: label,
        initialText: controller.text,
        hintText: hintText,
        cancelText: cancelText,
        confirmText: confirmText,
      ),
    );

    if (result != null) {
      controller.text = result;
      onChanged?.call(result);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final expandTooltip = l10n?.expandEditor ?? 'Expand';
    final invalidNumberMsg = l10n?.invalidNumber ?? 'Invalid number';

    return ValueListenableBuilder<TextEditingValue>(
      valueListenable: controller,
      builder: (context, value, child) {
        final currentText = value.text;
        final showPopout = enablePopout && currentText.isNotEmpty;

        final field = TextFormField(
          controller: controller,
          keyboardType: keyboardType,
          minLines: minLines,
          maxLines: maxLines,
          onChanged: onChanged,
          decoration: InputDecoration(
            labelText: label,
            hintText: hintText,
            filled: true,
            suffixIcon: showPopout
                ? IconButton(
                    icon: const Icon(Icons.open_in_full, size: 16),
                    tooltip: expandTooltip,
                    onPressed: () => _openPopoutEditor(context),
                  )
                : null,
          ),
          validator: (val) {
            if (isNumeric && val != null && val.isNotEmpty) {
              if (allowDecimal) {
                final parsed = double.tryParse(val);
                if (parsed == null || parsed.isNaN || parsed.isInfinite) {
                  return invalidNumberMsg;
                }
              } else {
                if (int.tryParse(val) == null) {
                  return invalidNumberMsg;
                }
              }
            }
            return validator?.call(val);
          },
        );

        if (currentText.isNotEmpty && currentText.length > 25) {
          return Tooltip(
            message: currentText,
            waitDuration: const Duration(milliseconds: 600),
            child: field,
          );
        }

        return field;
      },
    );
  }
}

class _PopoutEditorDialog extends StatefulWidget {
  final String label;
  final String initialText;
  final String? hintText;
  final String cancelText;
  final String confirmText;

  const _PopoutEditorDialog({
    required this.label,
    required this.initialText,
    this.hintText,
    required this.cancelText,
    required this.confirmText,
  });

  @override
  State<_PopoutEditorDialog> createState() => _PopoutEditorDialogState();
}

class _PopoutEditorDialogState extends State<_PopoutEditorDialog> {
  late final TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.initialText);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(widget.label),
      content: SizedBox(
        width: 480,
        child: TextField(
          controller: _controller,
          autofocus: true,
          maxLines: 8,
          minLines: 4,
          decoration: InputDecoration(
            hintText: widget.hintText,
            filled: true,
            border: const OutlineInputBorder(),
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text(widget.cancelText),
        ),
        FilledButton(
          onPressed: () => Navigator.of(context).pop(_controller.text),
          child: Text(widget.confirmText),
        ),
      ],
    );
  }
}
