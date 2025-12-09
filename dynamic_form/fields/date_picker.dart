import 'package:flutter/material.dart';
import 'package:wcas_frontend/core/components/datepicker.dart';
import 'package:wcas_frontend/core/components/dynamic_form/models/field.dart';
import 'package:wcas_frontend/core/components/label.dart';
import 'package:wcas_frontend/core/utils/scale.dart';

class DynamicFormDatePicker extends StatelessWidget {
  final DynamicField fieldData;
  final Map<String, dynamic>? document;
  final bool showLabel;
  final Function(DateTime?) onSubmit;
  const DynamicFormDatePicker(
      {super.key,
      required this.fieldData,
      this.document,
      required this.onSubmit,
      this.showLabel = true});

  DateTime? _parseInitialDate() {
    if (document == null) return null;

    final storedValue = document![fieldData.key];
    if (storedValue == null) return null;

    if (storedValue is String) {
      return DateTime.tryParse(storedValue);
    } else if (storedValue is DateTime) {
      return storedValue;
    } else if (storedValue is Map) {
      // Handle custom date format like {"date": {...}, "jsdate": "...", "epoc": ...}
      final jsdate = storedValue['jsdate'];
      if (jsdate is String) {
        return DateTime.tryParse(jsdate);
      }
    }

    return null;
  }

  @override
  Widget build(BuildContext context) {
    final initialDate = _parseInitialDate();

    return LabelWidget(
        showLabel: showLabel,
        label: fieldData.label,
        isRequired: fieldData.required,
        exponent: fieldData.isCMOUpdate ? "#" : null,
        child: CustomDatePicker(
          width: 230.w,
          initialDateTime: initialDate,
          onSubmit2: (DateTime? selectedDate) {
            onSubmit(selectedDate);
          },
        ));
  }
}
