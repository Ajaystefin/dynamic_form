import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:wcas_frontend/core/components/button.dart';
import 'package:wcas_frontend/core/components/gap.dart';
import 'package:wcas_frontend/features/request/file_attachment_digital_efiling/appendix/model.dart';

Widget browseUploadButtonWidget(
    BuildContext context, AppendixViewModel viewModel) {
  return Row(mainAxisAlignment: MainAxisAlignment.end, children: [
    CustomButton(
        label: "eDigitalFilingFileAttachments.appendix.browse".tr(),
        onPressed: () {
          viewModel.pickMultipleFiles();
        }),
    const Gap(direction: Axis.horizontal),
   
      CustomButton(
          label: "eDigitalFilingFileAttachments.appendix.upload".tr(),
          onPressed: () {
            // viewModel.uploadFormData();
          })
    
      
  ]);
}
