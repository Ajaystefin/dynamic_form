import "package:flutter/material.dart";
import "package:flutter/services.dart";
import "package:wcas_frontend/core/components/checkbox.dart";
import "package:wcas_frontend/core/components/textfield.dart";

/// A text field that is conditionally displayed and validated.
class CustomConditionalTextbox extends StatefulWidget {
  /// Creates a [CustomConditionalTextbox].
  const CustomConditionalTextbox({
    required this.onSaved,
    super.key,
    this.initialValue,
    this.inputFormatters,
    this.maxLength,
    this.hintText,
    this.message,
  });

  /// Callback invoked when the value is saved.
  final Function(String?) onSaved;

  /// Initial text value; a non-empty value also checks the checkbox.
  final String? initialValue;

  /// Input formatters applied to the text field.
  final List<TextInputFormatter>? inputFormatters;

  /// Maximum number of allowed characters.
  final int? maxLength;

  /// Placeholder text displayed when empty.
  final String? hintText;

  /// Validation or helper message.
  final String? message;

  @override
  State<CustomConditionalTextbox> createState() =>
      _CustomConditionalTextboxState();
}

class _CustomConditionalTextboxState extends State<CustomConditionalTextbox> {
  late final TextEditingController _controller;
  late final ValueNotifier<bool> onChecked;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.initialValue);
    onChecked = ValueNotifier(widget.initialValue?.isNotEmpty ?? false);
  }

  @override
  void dispose() {
    _controller.dispose();
    onChecked.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<bool>(
      valueListenable: onChecked,
      builder: (context, checked, _) {
        return Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Expanded(
              child: CustomCheckbox(
                value: checked,
                onChange: ({value}) {
                  final isChecked = value ?? false;
                  // Unchecking clears the text so a stale value is not saved
                  if (!isChecked) {
                    _controller.clear();
                  }
                  onChecked.value = isChecked;
                },
              ),
            ),
            Expanded(
              child: CustomTextField(
                controller: _controller,
                readOnly: !checked,
                filled: !checked,
                inputFormatters: widget.inputFormatters,
                hintText: widget.hintText,
                maxLength: widget.maxLength,
                errorText: widget.message,
                onSaved: widget.onSaved,
              ),
            ),
          ],
        );
      },
    );
  }
}
