import "package:flutter/material.dart";
import "package:wcas_frontend/core/components/datepicker.dart";
import "package:wcas_frontend/core/components/dynamic_form/models/field.dart";
import "package:wcas_frontend/core/components/label.dart";
import "package:wcas_frontend/core/utils/scale.dart";

/// Dynamic date picker form field.
class DynamicFormDatePicker extends StatelessWidget {
  /// Creates a [DynamicFormDatePicker].
  const DynamicFormDatePicker({
    required this.fieldData,
    required this.onSubmit,
    super.key,
    this.document,
    this.showLabel = true,
  });

  /// Field configuration data.
  final DynamicField fieldData;

  /// Form document data.
  final Map<String, dynamic>? document;

  /// Whether to display the field label.
  final bool showLabel;

  /// Callback invoked when a date is selected.
  final Function(DateTime?) onSubmit;

  /// Parses the initial date value from the document.
  DateTime? _parseInitialDate() {
    if (document == null) {
      return null;
    }

    final storedValue = document![fieldData.key];
    if (storedValue == null) {
      return null;
    }

    if (storedValue is String) {
      return DateTime.tryParse(storedValue);
    } else if (storedValue is DateTime) {
      return storedValue;
    } else if (storedValue is Map) {
      // Handle custom date format like {"date": {...}, "jsdate": "...", "epoc":
      // ...}
      final jsdate = storedValue["jsdate"];
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
      isRequired: fieldData.isRequired,
      exponent: fieldData.isCMOUpdate ? "#" : null,
      child: CustomDatePicker(
        width: 230.w,
        initialDateTime: initialDate,
        validator: fieldData.isRequired
            ? (value) {
                if (value == null || value.isEmpty) {
                  return fieldData.message ?? "${fieldData.label} is required";
                }
                return null;
              }
            : null,
        onSubmit2: onSubmit,
      ),
    );
  }
}
