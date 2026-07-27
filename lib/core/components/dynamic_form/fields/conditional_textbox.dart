import "package:flutter/material.dart";
import "package:flutter/services.dart";
import "package:wcas_frontend/core/components/conditional_textbox.dart";
import "package:wcas_frontend/core/components/dynamic_form/models/field.dart";
import "package:wcas_frontend/core/components/label.dart";

/// Dynamic conditional text box field.
class DynamicConditionalTextbox extends StatelessWidget {
  /// Creates a [DynamicConditionalTextbox].
  const DynamicConditionalTextbox({
    required this.fieldData,
    required this.onSubmit,
    super.key,
    this.document,
    this.showLabel = true,
    this.inputFormatters,
  });

  /// Field configuration data.
  final DynamicField fieldData;

  /// Form document data.
  final Map<String, dynamic>? document;

  /// Whether to display the field label.
  final bool showLabel;

  /// Callback invoked when the value is submitted.
  final Function(String) onSubmit;

  /// Input formatters applied to the text field.
  final List<TextInputFormatter>? inputFormatters;
  @override
  Widget build(BuildContext context) {
    return LabelWidget(
      label: fieldData.label,
      showLabel: showLabel,
      isRequired: fieldData.isRequired,
      exponent: fieldData.isCMOUpdate ? "#" : null,
      child: CustomConditionalTextbox(
        onSaved: (value) => onSubmit(value ?? ""),
        initialValue: document?[fieldData.key]?.toString(),
        inputFormatters: inputFormatters,
        hintText: fieldData.defaultValue,
        maxLength: fieldData.maxLength,
        message: fieldData.message,
      ),
    );
  }
}
