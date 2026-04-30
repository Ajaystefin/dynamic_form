import "package:easy_localization/easy_localization.dart";
import "package:flutter/material.dart";
import "package:flutter/services.dart";
import "package:wcas_frontend/core/components/label.dart";
import "package:wcas_frontend/core/components/textfield.dart";
import "package:wcas_frontend/core/constants/constants.dart";
import "package:wcas_frontend/features/request/file_attachment_digital_efiling/upload_document_dialog/model.dart";

class GroupRimField extends StatelessWidget {
  const GroupRimField({
    required this.viewModel,
    super.key,
  });
  final UploadDocumentDialogViewModel viewModel;

  @override
  Widget build(BuildContext context) {
    return LabelWidget(
      label: "eDigitalFilingFileAttachments.fileAttachments.groupRim".tr(),
      showLabel: true,
      isRequired: false,
      child: CustomTextField(
        initialValue: viewModel.selectedGroupRim?.toString() ?? "",
        readOnly: true,
        maxLength: 15,
        counterText: "",
        inputFormatters: [
          FilteringTextInputFormatter.allow(RegExp("[a-zA-Z0-9]")),
        ],
        validator: (value) {
          if (value == null || value.trim().isEmpty) {
            return "validation.groupRimRequired".tr();
          }
          return null;
        },
        filled: true,
        fillColor: AppColors.tableCellColorGroupedRow,
      ),
    );
  }
}
