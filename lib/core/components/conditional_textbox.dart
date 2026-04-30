import "package:flutter/material.dart";
import "package:flutter/services.dart";
import "package:wcas_frontend/core/components/checkbox.dart";
import "package:wcas_frontend/core/components/textfield.dart";

class CustomConditionalTextbox extends StatefulWidget {
  const CustomConditionalTextbox({
    required this.onSaved,
    super.key,
    this.inputFormatters,
    this.maxLength,
    this.hintText,
    this.message,
  });
  final Function(String?) onSaved;
  final List<TextInputFormatter>? inputFormatters;
  final int? maxLength;
  final String? hintText;
  final String? message;

  @override
  State<CustomConditionalTextbox> createState() =>
      _CustomConditionalTextboxState();
}

class _CustomConditionalTextboxState extends State<CustomConditionalTextbox> {
  ValueNotifier<bool> onChecked = ValueNotifier(false);
  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<bool>(
      valueListenable: onChecked,
      builder: (context, checked, _) {
        return Row(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Expanded(
              child: CustomCheckbox(
                value: checked,
                onChange: (value) => onChecked.value = value ?? false,
              ),
            ),
            Expanded(
              child: CustomTextField(
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
