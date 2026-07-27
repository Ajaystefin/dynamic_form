import "package:easy_localization/easy_localization.dart";
import "package:flutter/material.dart";
import "package:wcas_frontend/core/components/datepicker.dart";
import "package:wcas_frontend/core/components/label.dart";
import "package:wcas_frontend/core/utils/scale.dart";
import "package:wcas_frontend/core/utils/validators.dart";
import "package:wcas_frontend/features/request/file_attachment_digital_efiling/file_attachment/model.dart";

/// DateField stateless widget
class DateField extends StatelessWidget {
  /// Creates [DateField] instance
  const DateField({
    required this.label,
    required this.viewModel,
    super.key,
    this.readOnly = false,
    this.initialDateTime,
  });

  /// FileAttachmment view model to handle actions
  final FileAttachmentViewModel viewModel;

  /// shows the string as label
  final String label;

  /// is in read only state
  final bool readOnly;

  /// DateTime initial value
  final DateTime? initialDateTime;

  @override
  Widget build(BuildContext context) {
    if (initialDateTime != null) {
      viewModel.selectedDate = initialDateTime;
    }

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
        onSubmit: (value) {
          final DateFormat format = DateFormat("dd/MM/yyyy");
          viewModel.selectedDate = format.parse(value!);
        },
        validator: CustomValidator.requiredField,
      ),
    );
  }
}
