import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:wcas_frontend/core/components/label.dart';
import 'package:wcas_frontend/core/components/textfield.dart';
import 'package:wcas_frontend/core/constants/constants.dart';

class AttachmetSubSubTypeField extends StatelessWidget {
  final String? initialValue;
  final Function(String?) onSaved;

  const AttachmetSubSubTypeField({
    super.key,
    required this.initialValue,
    required this.onSaved,
  });

  @override
  Widget build(BuildContext context) {
    return LabelWidget(
        label: "eDigitalFilingFileAttachments.fileAttachments.subSubType".tr(),
        showLabel: true,
        isRequired: false,
        child: CustomTextField(
          initialValue: '',
          readOnly: true,
          maxLength: 50,
          counterText: "",
          inputFormatters: [
            FilteringTextInputFormatter.allow(RegExp(r'[a-zA-Z0-9]'))
          ],
          onSaved: onSaved,
          validator: (value) {
            if (value == null || value.trim().isEmpty) {
              return "validation.subSubTypeRequired".tr();
            }
            return null;
          },
          filled: true,
          fillColor: AppColors.tableCellColorGroupedRow,
        ));
  }
}
