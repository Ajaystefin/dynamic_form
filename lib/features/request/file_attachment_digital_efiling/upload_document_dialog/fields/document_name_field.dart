import "package:easy_localization/easy_localization.dart";
import "package:flutter/material.dart";
import "package:flutter/services.dart";
import "package:wcas_frontend/core/components/file_attachment/tooltip_helper.dart";
import "package:wcas_frontend/core/components/label.dart";
import "package:wcas_frontend/core/components/textfield.dart";
import "package:wcas_frontend/core/constants/constants.dart";
import "package:wcas_frontend/features/request/file_attachment_digital_efiling/upload_document_dialog/model.dart";

/// DocumentNameField stateless widget
class DocumentNameField extends StatelessWidget {
  /// Creates [DocumentNameField] instance
  const DocumentNameField({
    required this.initialValue,
    required this.onSaved,
    required this.viewModel,
    super.key,
    this.isRequired = false,
  });

  /// Initial value
  final String? initialValue;

  /// onSave callback function
  final Function(String?) onSaved;

  /// whether required or not
  final bool isRequired;

  /// UploadDocumentDialogViewModel view model to handle actions
  final UploadDocumentDialogViewModel viewModel;

  @override
  Widget build(BuildContext context) {
    return LabelWidget(
      label: "eDigitalFilingFileAttachments.fileAttachments.documentName".tr(),
      isRequired: isRequired,
      infoContent: TooltipHelper.getDocumentNameTooltip(
        viewModel.selectedDocumentType?.id,
        viewModel.selectedSubSubTypeFinancial?.id,
      ),
      child: CustomTextField(
        initialValue: viewModel.documentNameCtrl.text,
        controller: viewModel.documentNameCtrl,
        maxLength: 100,
        inputFormatters: [
          FilteringTextInputFormatter.allow(RegExp("[a-zA-Z0-9 ]")),
        ],
        onSaved: onSaved,
        validator: (value) {
          if (value == null || value.trim().isEmpty) {
            return "common.validation.documentNameRequired".tr();
          }
          return null;
        },
        fillColor: AppColors.tableCellColorGroupedRow,
      ),
    );
  }
}
