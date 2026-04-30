import "package:easy_localization/easy_localization.dart";
import "package:flutter/material.dart";
import "package:flutter/services.dart";
import "package:wcas_frontend/core/components/label.dart";
import "package:wcas_frontend/core/components/textfield.dart";
import "package:wcas_frontend/core/constants/constants.dart";
import "package:wcas_frontend/features/request/file_attachment_digital_efiling/upload_document_dialog/model.dart";

class EntityIdField extends StatelessWidget {
  const EntityIdField({
    required this.initialValue,
    required this.onSaved,
    required this.viewModel,
    super.key,
    this.isRequired = false,
  });
  final String? initialValue;
  final Function(String?) onSaved;
  final bool isRequired;
  final UploadDocumentDialogViewModel viewModel;

  @override
  Widget build(BuildContext context) {
    return LabelWidget(
      label: "eDigitalFilingFileAttachments.fileAttachments.entityIdField".tr(),
      showLabel: true,
      isRequired: isRequired,
      child: CustomTextField(
        initialValue: viewModel.entityIdCtrl.text,
        readOnly: false,
        controller: viewModel.entityIdCtrl,
        maxLength: 10,
        counterText: "",
        inputFormatters: [
          FilteringTextInputFormatter.allow(RegExp("[0-9]")),
        ],
        onSaved: onSaved,
        validator: (value) {
          if (value == null || value.trim().isEmpty) {
            return "common.validation.entityIdRequired".tr();
          }
          return null;
        },
        filled: false,
        fillColor: AppColors.tableCellColorGroupedRow,
      ),
    );
  }
}
