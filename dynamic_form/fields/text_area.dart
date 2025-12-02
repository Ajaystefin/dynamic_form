import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:wcas_frontend/core/components/label.dart';
import 'package:wcas_frontend/core/components/textarea.dart';

import '../models/field.dart';

class DynamicFormTextAreaField extends StatelessWidget {
  final DynamicField fieldData;
  final Function(String?) onSubmit;
  final List<TextInputFormatter>? inputFormatters;
  final bool showLabel;
  final int maxLines;
  final int minLines;
  const DynamicFormTextAreaField(
      {super.key,
      required this.fieldData,
      required this.onSubmit,
      this.inputFormatters,
      this.showLabel = true,
      this.maxLines = 5,
      this.minLines = 2});

  @override
  Widget build(BuildContext context) {
    return LabelWidget(
        showLabel: showLabel,
        label: fieldData.label,
        isRequired: fieldData.required,
        child: CustomTextArea(
            maxLines: maxLines,
            minLines: minLines,
            hintText: fieldData.defaultValue,
            maxLength: fieldData.maxLength,
            errorText: fieldData.message,
            readOnly: fieldData.isDisable,
            onSaved: onSubmit));
  }
}
