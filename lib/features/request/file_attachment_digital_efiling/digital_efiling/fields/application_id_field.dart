import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:wcas_frontend/core/components/label.dart';
import 'package:wcas_frontend/core/components/textfield.dart';
import 'package:wcas_frontend/core/constants/constants.dart';
import 'package:wcas_frontend/core/utils/scale.dart';

class ApplicationIdField extends StatelessWidget {
  final TextEditingController controller;
  final Function(String?) onSaved;
  final bool? readOnly;

  const ApplicationIdField(
      {super.key,
      required this.controller,
      required this.onSaved,
      this.readOnly});

  @override
  Widget build(BuildContext context) {
    return LabelWidget(
        label:
            "eDigitalFilingFileAttachments.fileAttachments.applicationId".tr(),
        showLabel: true,
        isRequired: false,
        child: CustomTextField(
          controller: controller,
          readOnly: readOnly ?? false,
          maxLength: 30,
          counterText: "",
          width: 250.w,
          inputFormatters: [
            FilteringTextInputFormatter.allow(RegExp(r'[a-zA-Z0-9]'))
          ],
          onSaved: onSaved,
          // validator: (value) {
          //   if (value == null || value.trim().isEmpty) {
          //     return "common.validation.applicationIdRequired".tr();
          //   }
          //   return null;
          // },
          filled: readOnly ?? false,
          fillColor: AppColors.tableCellColorGroupedRow,
        ));
  }
}
