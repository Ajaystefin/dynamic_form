import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';

import 'package:wcas_frontend/core/components/label.dart';
import 'package:wcas_frontend/core/components/textfield.dart';
import 'package:wcas_frontend/core/constants/constants.dart';
import 'package:wcas_frontend/features/request/file_attachment_digital_efiling/appendix/model.dart';

class GDPField extends StatelessWidget {
  final AppendixViewModel viewModel;

  const GDPField({
    super.key,
    required this.viewModel,
  });

  @override
  Widget build(BuildContext context) {
    return LabelWidget(
      label: "eDigitalFilingFileAttachments.appendix.gdp".tr(),
      showLabel: true,
      isRequired: true,
      child: CustomTextField(
        initialValue:  '',
        readOnly: false,
        maxLength: 20,
        counterText: "",
        onChanged: (value) {
          viewModel.setGdp(value);
        },
      
        validator: (value) {
          if (value == null || value.trim().isEmpty) {
            return "common.validation.gdp".tr();
          }
          return null;
        },
        filled: false,
        fillColor: AppColors.tableCellColorGroupedRow,
      ),
    );
  }
}
