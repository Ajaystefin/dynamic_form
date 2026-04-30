import "package:flutter/material.dart";
import "package:intl/intl.dart";
import "package:wcas_frontend/core/components/datepicker.dart";
import "package:wcas_frontend/core/components/label.dart";
import "package:wcas_frontend/core/utils/scale.dart";
import "package:wcas_frontend/core/utils/validators.dart";
import "package:wcas_frontend/features/request/file_attachment_digital_efiling/upload_document_dialog/model.dart";

// ignore: must_be_immutable
class AttachmentDateField extends StatelessWidget {
  const AttachmentDateField({
    required this.label,
    required this.viewModel,
    super.key,
  });
  final UploadDocumentDialogViewModel viewModel;
  final String label;

  @override
  Widget build(BuildContext context) {
    return LabelWidget(
      label: label,
      isRequired: true,
      child: CustomDatePicker(
        labelText: viewModel.selectedDate.toString(),
        width: 250.w,
        initialDateTime: viewModel.selectedDate,
        onSubmit: (value) {
          if (value != null) {
            final DateFormat format = DateFormat("dd/MM/yyyy");
            viewModel.selectedDate = format.parse(value);
          }
        },
        validator: CustomValidator.requiredField,
        // onSaved: (String? value) {},
      ),
    );
  }
}
