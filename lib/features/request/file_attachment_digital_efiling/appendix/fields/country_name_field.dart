import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:wcas_frontend/core/components/label.dart';
import 'package:wcas_frontend/core/components/textfield.dart';
import 'package:wcas_frontend/core/constants/constants.dart';
import 'package:wcas_frontend/features/request/file_attachment_digital_efiling/appendix/model.dart';

class CountryNameField extends StatelessWidget {
  final AppendixViewModel viewModel;

  const CountryNameField({
    super.key,
    required this.viewModel
  });

  @override
  Widget build(BuildContext context) {
    return LabelWidget(
        label: "eDigitalFilingFileAttachments.appendix.countryName".tr(),
        showLabel: true,
        isRequired: true,
        child: CustomTextField(
          initialValue:  '',
          readOnly: false,
          maxLength: 30,
          counterText: "",
          inputFormatters: [
            FilteringTextInputFormatter.allow(RegExp(r'[a-zA-Z\s]'))
          ],
           onSaved: (value) {
          viewModel.setCountryName(value);
        },
          validator: (value) {
            if (value == null || value.trim().isEmpty) {
              return "common.validation.countryName".tr();
            }
            return null;
          },
          filled: false,
          fillColor: AppColors.tableCellColorGroupedRow,
        ));
  }
}
