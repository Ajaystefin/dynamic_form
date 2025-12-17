import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:wcas_frontend/core/components/label.dart';
import 'package:wcas_frontend/core/components/textarea.dart';
// import 'package:wcas_frontend/core/constants/constants.dart';
import 'package:wcas_frontend/features/request/file_attachment_digital_efiling/appendix/model.dart';

class GroupCorporateStructure extends StatelessWidget {
  const GroupCorporateStructure({super.key, required this.viewModel});
  final AppendixViewModel viewModel;
  @override
  Widget build(BuildContext context) {
    return LabelWidget(
      isRequired: true,
      label:
          "eDigitalFilingFileAttachments.appendix.groupCorporateStructure".tr(),
      child:  CustomTextArea(
        maxLength: 5000,
        initialValue: '',
        
        validator: (value) {
          if (value == null || value.trim().isEmpty) {
            return "common.validation.emptyField".tr(); // or a custom error key
          }
          return null;
        },

      ),
    );
  }
}
