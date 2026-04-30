import "package:flutter/material.dart";
import "package:flutter/services.dart";
import "package:wcas_frontend/core/components/conditional_textbox.dart";
import "package:wcas_frontend/core/components/dynamic_form/models/field.dart";
import "package:wcas_frontend/core/components/label.dart";

class DynamicConditionalTextbox extends StatelessWidget {
  const DynamicConditionalTextbox({
    required this.fieldData,
    required this.onSubmit,
    super.key,
    this.showLabel = true,
    this.inputFormatters,
  });
  final DynamicField fieldData;
  final bool showLabel;
  final Function(String) onSubmit;
  final List<TextInputFormatter>? inputFormatters;

  @override
  Widget build(BuildContext context) {
    return LabelWidget(
      label: fieldData.label,
      showLabel: showLabel,
      isRequired: fieldData.isRequired,
      exponent: fieldData.isCMOUpdate ? "#" : null,
      child: CustomConditionalTextbox(
        onSaved: (value) => onSubmit,
        inputFormatters: inputFormatters,
        hintText: fieldData.defaultValue,
        maxLength: fieldData.maxLength,
        message: fieldData.message,
      ),
    );
  }
}
