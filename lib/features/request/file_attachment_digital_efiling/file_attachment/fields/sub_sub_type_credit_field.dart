import "package:easy_localization/easy_localization.dart";
import "package:flutter/material.dart";
import "package:flutter/services.dart";
import "package:wcas_frontend/core/components/label.dart";
import "package:wcas_frontend/core/components/textfield.dart";
import "package:wcas_frontend/core/constants/constants.dart";
import "package:wcas_frontend/features/request/file_attachment_digital_efiling/file_attachment/model.dart";

/// SubSubTypeCreditField stateless widget
class SubSubTypeCreditField extends StatelessWidget {
  /// Creates [SubSubTypeCreditField] instance
  const SubSubTypeCreditField({
    required this.viewModel,
    super.key,
  });

  /// FileAttachmment view model to handle actions
  final FileAttachmentViewModel viewModel;

  @override
  Widget build(BuildContext context) {
    return LabelWidget(
      label: "eDigitalFilingFileAttachments.fileAttachments.subSubType".tr(),
      child: CustomTextField(
        initialValue: viewModel.request.applicationType?.name ?? "",
        readOnly: true,
        maxLength: 50,
        inputFormatters: [
          FilteringTextInputFormatter.allow(RegExp("[a-zA-Z0-9]")),
        ],
        validator: (value) {
          if (value == null || value.trim().isEmpty) {
            return "validation.subSubTypeRequired".tr();
          }
          return null;
        },
        filled: true,
        fillColor: AppColors.tableCellColorGroupedRow,
      ),
    );
  }
}
