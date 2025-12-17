import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:wcas_frontend/core/components/label.dart';
import 'package:wcas_frontend/core/components/textfield.dart';
import 'package:wcas_frontend/core/constants/constants.dart';
import 'package:wcas_frontend/features/request/file_attachment_digital_efiling/upload_document_dialog/model.dart';

class DocumentNameField extends StatelessWidget {
  final String? initialValue;
  final Function(String?) onSaved;
  final bool isRequired;
  final UploadDocumentDialogViewModel viewModel;

  const DocumentNameField(
      {super.key,
      required this.initialValue,
      required this.onSaved,
      required this.viewModel,
      this.isRequired = false});

  @override
  Widget build(BuildContext context) {
    return LabelWidget(
        label:
            "eDigitalFilingFileAttachments.fileAttachments.documentName".tr(),
        showLabel: true,
        isRequired: isRequired,
        child: CustomTextField(
          initialValue: viewModel.textController.text,
          readOnly: viewModel.textController.text != "" ? true : false,
          controller: viewModel.textController,
          maxLength: 100,
          counterText: "",
          inputFormatters: [
            FilteringTextInputFormatter.allow(RegExp(r'[a-zA-Z0-9 ]'))
          ],
          onSaved: onSaved,
          validator: (value) {
            if (value == null || value.trim().isEmpty) {
              return "common.validation.documentNameRequired".tr();
            }
            return null;
          },
          filled: viewModel.textController.text != "" ? true : false,
          fillColor: AppColors.tableCellColorGroupedRow,
        ));
  }
}
