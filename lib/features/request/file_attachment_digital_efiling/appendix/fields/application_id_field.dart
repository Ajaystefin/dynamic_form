import "package:easy_localization/easy_localization.dart";
import "package:flutter/material.dart";
import "package:flutter/services.dart";
import "package:wcas_frontend/core/components/label.dart";
import "package:wcas_frontend/core/components/textfield.dart";
import "package:wcas_frontend/core/constants/constants.dart";
import "package:wcas_frontend/features/request/file_attachment_digital_efiling/appendix/model.dart";

/// ApplicationIdField stateless widget
class ApplicationIdField extends StatelessWidget {
  /// Creats [ApplicationIdField] instance
  const ApplicationIdField({
    required this.viewModel,
    super.key,
  });

  /// AppendixViewModel view model to handle actions
  final AppendixViewModel viewModel;

  @override
  Widget build(BuildContext context) {
    return LabelWidget(
      label: "eDigitalFilingFileAttachments.appendix.applicationId".tr(),
      isRequired: true,
      child: CustomTextField(
        initialValue: "",
        maxLength: 30,
        inputFormatters: [
          FilteringTextInputFormatter.allow(RegExp("[a-zA-Z0-9]")),
        ],
        onChanged: viewModel.setApplicationId,
        validator: (value) {
          if (value == null || value.trim().isEmpty) {
            return "common.validation.applicationIdRequired".tr();
          }
          return null;
        },
        fillColor: AppColors.tableCellColorGroupedRow,
      ),
    );
  }
}
