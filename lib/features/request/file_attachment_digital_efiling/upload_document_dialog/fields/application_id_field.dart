import "package:easy_localization/easy_localization.dart";
import "package:flutter/material.dart";
import "package:flutter/services.dart";
import "package:wcas_frontend/core/components/label.dart";
import "package:wcas_frontend/core/components/textfield.dart";
import "package:wcas_frontend/features/request/file_attachment_digital_efiling/upload_document_dialog/model.dart";

/// ApplicationIdField stateless widget
class ApplicationIdField extends StatelessWidget {
  /// Creates [ApplicationIdField] instance
  const ApplicationIdField({
    required this.onSaved,
    required this.viewModel,
    super.key,
  });

  /// UploadDocumentDialogViewModel view model to handle actions
  final UploadDocumentDialogViewModel viewModel;

  /// onSave callback function
  final Function(String?) onSaved;

  @override
  Widget build(BuildContext context) {
    return LabelWidget(
      label: "eDigitalFilingFileAttachments.fileAttachments.applicationId".tr(),
      child: CustomTextField(
        initialValue: viewModel.appRefNoCtrl.text,
        controller: viewModel.appRefNoCtrl,
        // readOnly:
        //     viewModel.applicationId != null && viewModel.applicationId != "",
        maxLength: 30,
        onSaved: onSaved,
        inputFormatters: [
          FilteringTextInputFormatter.allow(RegExp("[a-zA-Z0-9]")),
        ],
        // filled:
        //     viewModel.applicationId != null && viewModel.applicationId != "",
      ),
    );
  }
}
