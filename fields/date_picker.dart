import 'package:flutter/material.dart';
import 'package:wcas_frontend/core/components/datepicker.dart';
import 'package:wcas_frontend/core/components/dynamic_form/models/field.dart';
import 'package:wcas_frontend/core/components/label.dart';

class DynamicFormDatePicker extends StatelessWidget {
  final DynamicField fieldData;
  final bool showLabel;
  final Function(DateTime?) onSubmit;
  const DynamicFormDatePicker(
      {super.key,
      required this.fieldData,
      required this.onSubmit,
      this.showLabel = true});

  @override
  Widget build(BuildContext context) {
    return LabelWidget(
        showLabel: showLabel,
        label: fieldData.label,
        isRequired: fieldData.required,
        child: CustomDatePicker(
          onSubmit2: (DateTime? selectedDate) {
            onSubmit(selectedDate);
          },
        ));
  }
}
