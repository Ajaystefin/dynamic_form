import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:wcas_frontend/core/components/dropdown_textbox.dart';
import 'package:wcas_frontend/core/components/dynamic_form/models/field.dart';
import 'package:wcas_frontend/core/components/label.dart';
import 'package:wcas_frontend/core/utils/scale.dart';

class DynamicFormDropdownTextfield extends StatelessWidget {
  final DynamicField fieldData;
  final Function(Map<String, dynamic>) onSubmit;
  final bool showLabel;
  final List<TextInputFormatter>? inputFormatters;
  const DynamicFormDropdownTextfield(
      {super.key,
      required this.fieldData,
      required this.onSubmit,
      this.showLabel = false,
      this.inputFormatters});

  @override
  Widget build(BuildContext context) {
    Widget child = CustomDropdownTextbox(textFieldWidth: 280.w,
      options: fieldData.optionList ?? [],
      initialOption: fieldData.defaultValue,
      onChanged: (value) {
        onSubmit(value);
      },
    );
    return showLabel
        ? LabelWidget(
            showLabel: showLabel,
            label: fieldData.label,
            isRequired: fieldData.required,
            child: child)
        : child;
  }
}
