import "package:easy_localization/easy_localization.dart";
import "package:flutter/material.dart";

import "package:wcas_frontend/core/components/label.dart";
import "package:wcas_frontend/core/components/textfield.dart";
import "package:wcas_frontend/core/constants/constants.dart";
import "package:wcas_frontend/features/request/file_attachment_digital_efiling/appendix/model.dart";

/// GDPField stateless widget

class GDPField extends StatelessWidget {
  /// Creates [GDPField] instance
  const GDPField({
    required this.viewModel,
    super.key,
  });

  /// AppendixViewModel view model to handle actions
  final AppendixViewModel viewModel;

  @override
  Widget build(BuildContext context) {
    return LabelWidget(
      label: "eDigitalFilingFileAttachments.appendix.gdp".tr(),
      isRequired: true,
      child: CustomTextField(
        initialValue: viewModel.appendix.gdpText,
        readOnly: viewModel.isAppendixReadOnly,
        maxLength: 100,
        onChanged: (value) {
          viewModel.setGdp(value);
        },
        validator: (value) {
          if (value == null || value.trim().isEmpty) {
            return "common.validation.gdp".tr();
          }
          return null;
        },
        fillColor: AppColors.tableCellColorGroupedRow,
      ),
    );
  }
}
