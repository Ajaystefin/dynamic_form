import "package:easy_localization/easy_localization.dart";
import "package:flutter/material.dart";
import "package:flutter/services.dart";
import "package:wcas_frontend/core/components/label.dart";
import "package:wcas_frontend/core/components/textfield.dart";
import "package:wcas_frontend/core/constants/constants.dart";
import "package:wcas_frontend/features/request/file_attachment_digital_efiling/appendix/model.dart";

class ApplicationIdField extends StatelessWidget {
  const ApplicationIdField({
    required this.viewModel,
    super.key,
  });
  final AppendixViewModel viewModel;

  @override
  Widget build(BuildContext context) {
    return LabelWidget(
      label: "eDigitalFilingFileAttachments.appendix.applicationId".tr(),
      isRequired: true,
      child: CustomTextField(
        initialValue: "",
        readOnly: false,
        maxLength: 30,
        counterText: "",
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
        filled: false,
        fillColor: AppColors.tableCellColorGroupedRow,
      ),
    );
  }
}
