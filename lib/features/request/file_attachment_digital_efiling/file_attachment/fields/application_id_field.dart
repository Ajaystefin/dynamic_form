import "package:easy_localization/easy_localization.dart";
import "package:flutter/material.dart";
import "package:flutter/services.dart";
import "package:wcas_frontend/core/components/label.dart";
import "package:wcas_frontend/core/components/textfield.dart";
import "package:wcas_frontend/core/constants/constants.dart";
import "package:wcas_frontend/features/request/file_attachment_digital_efiling/file_attachment/model.dart";

/// ApplicationIdField stateless widget
class ApplicationIdField extends StatelessWidget {
  /// Creates [ApplicationIdField] instance
  const ApplicationIdField({
    required this.viewModel,
    super.key,
  });

  /// FileAttachmment view model to handle actions
  final FileAttachmentViewModel viewModel;

  @override
  Widget build(BuildContext context) {
    return LabelWidget(
      label: "eDigitalFilingFileAttachments.fileAttachments.applicationId".tr(),
      child: CustomTextField(
        initialValue: viewModel.request.applicationRefNo,
        readOnly: true,
        maxLength: 30,
        inputFormatters: [
          FilteringTextInputFormatter.allow(RegExp("[a-zA-Z0-9]")),
        ],
        filled: true,
        fillColor: AppColors.tableCellColorGroupedRow,
      ),
    );
  }
}
