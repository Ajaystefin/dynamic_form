import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:wcas_frontend/core/components/label.dart';
import 'package:wcas_frontend/core/components/textfield.dart';
import 'package:wcas_frontend/core/constants/constants.dart';

class DocumentNameField extends StatelessWidget {
  final String? initialValue;
  final Function(String?) onSaved;
  final bool isRequired;

  const DocumentNameField(
      {super.key,
      required this.initialValue,
      required this.onSaved,
      this.isRequired = false});

  @override
  Widget build(BuildContext context) {
    return LabelWidget(
        label:
            "eDigitalFilingFileAttachments.fileAttachments.documentName".tr(),
        showLabel: true,
        isRequired: isRequired,
        child: CustomTextField(
          initialValue: initialValue ?? '',
          readOnly: false,
          maxLength: 100,
          counterText: "",
          inputFormatters: [
            FilteringTextInputFormatter.allow(RegExp(r'[a-zA-Z0-9]'))
          ],
          onSaved: onSaved,
          validator: (value) {
            if (value == null || value.trim().isEmpty) {
              return "common.validation.documentNameRequired".tr();
            }
            return null;
          },
          filled: false,
          fillColor: AppColors.tableCellColorGroupedRow,
        ));
  }
}
