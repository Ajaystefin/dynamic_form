import 'package:flutter/material.dart';
import 'package:wcas_frontend/core/components/datepicker.dart';
import 'package:wcas_frontend/core/components/label.dart';
import 'package:wcas_frontend/core/utils/scale.dart';

// ignore: must_be_immutable
class AttachmentDateField extends StatelessWidget {
  DateTime? initialValue;
  final String label;

  AttachmentDateField(
      {super.key, required this.initialValue, required this.label});

  @override
  Widget build(BuildContext context) {
    return LabelWidget(
      label: label,isRequired: true,
      child: CustomDatePicker(
          width: 350.w,
          initialDateTime: initialValue,
          onSubmit2: (DateTime? date) {
            initialValue = date;
          }),
    );
  }
}
