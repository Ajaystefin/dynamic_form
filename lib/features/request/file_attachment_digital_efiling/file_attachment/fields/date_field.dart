import 'package:flutter/material.dart';
import 'package:wcas_frontend/core/components/datepicker.dart';
import 'package:wcas_frontend/core/components/label.dart';
import 'package:wcas_frontend/core/utils/scale.dart';
import 'package:wcas_frontend/core/utils/validators.dart';
import 'package:wcas_frontend/features/request/file_attachment_digital_efiling/file_attachment/model.dart';

// ignore: must_be_immutable
class DateField extends StatelessWidget {
  final FileAttachmentViewModel viewModel;
  final String label;
  final bool readOnly;
  final DateTime? initialDateTime;

  const DateField({
    super.key,
    required this.label,
    required this.viewModel,
    this.readOnly = false,
    this.initialDateTime,
  });

  @override
  Widget build(BuildContext context) {
    return LabelWidget(
      label: label,
      isRequired: true,
      child: CustomDatePicker(
        width: 250.w,
        initialDateTime: initialDateTime ?? viewModel.selectedDate,
        isEnabled: !readOnly,
        onSubmit2: (DateTime? date) {
          if (!readOnly) {
            viewModel.selectedDate = date;
          }
        },
        validator: CustomValidator.requiredField,
      ),
    );
  }
}
