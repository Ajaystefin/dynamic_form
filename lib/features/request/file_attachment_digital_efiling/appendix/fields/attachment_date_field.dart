import "package:flutter/material.dart";
import "package:wcas_frontend/core/components/datepicker.dart";
import "package:wcas_frontend/core/components/label.dart";
import "package:wcas_frontend/core/utils/scale.dart";

/// AttachmentDateField stateless widget
class AttachmentDateField extends StatelessWidget {
  /// Creates [AttachmentDateField] instance
  const AttachmentDateField({
    required this.initialValue,
    required this.onChanged,
    required this.label,
    super.key,
  });

  /// initial value in date
  final DateTime? initialValue;

  /// onChanged callback function
  final ValueChanged<DateTime?> onChanged;

  /// Label
  final String label;

  @override
  Widget build(BuildContext context) {
    return LabelWidget(
      label: label,
      isRequired: true,
      child: CustomDatePicker(
        width: 350.w,
        initialDateTime: initialValue,
        onSubmit2: onChanged,
      ),
    );
  }
}
