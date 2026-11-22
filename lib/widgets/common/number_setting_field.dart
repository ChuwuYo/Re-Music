import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../constants.dart';

/// Numeric setting: type a value and press Enter to commit it.
///
/// Parsing and validation live in the provider via [onSubmit].
class NumberSettingField extends StatefulWidget {
  const NumberSettingField({
    super.key,
    required this.label,
    required this.value,
    required this.errorText,
    required this.onSubmit,
    this.enabled = true,
  });

  final String label;
  final int value;
  final String errorText;
  final bool Function(String text) onSubmit;
  final bool enabled;

  @override
  State<NumberSettingField> createState() => _NumberSettingFieldState();
}

class _NumberSettingFieldState extends State<NumberSettingField> {
  late final TextEditingController _controller;
  String? _error;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: '${widget.value}');
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _submit(String text) {
    final accepted = widget.onSubmit(text);
    setState(() => _error = accepted ? null : widget.errorText);
    if (accepted) FocusScope.of(context).unfocus();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: AppConstants.transcodeSettingFieldWidth,
      child: TextField(
        controller: _controller,
        enabled: widget.enabled,
        keyboardType: TextInputType.number,
        inputFormatters: [FilteringTextInputFormatter.digitsOnly],
        onSubmitted: widget.enabled ? _submit : null,
        onChanged: (_) {
          if (_error != null) setState(() => _error = null);
        },
        decoration: InputDecoration(
          labelText: widget.label,
          errorText: _error,
          filled: true,
          contentPadding: const EdgeInsets.symmetric(vertical: 5.0),
        ),
      ),
    );
  }
}
