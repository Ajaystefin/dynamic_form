import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:wcas_frontend/core/components/gap.dart';
import 'package:wcas_frontend/features/request/file_attachment_digital_efiling/file_attachment/model.dart';

import '../../../../../core/components/button.dart';

Widget actionButtons(FileAttachmentViewModel viewModel, BuildContext context) {
  return Row(
    mainAxisAlignment: MainAxisAlignment.end,
    children: [
      const Gap(),
      CustomButton(
          label: "eDigitalFilingFileAttachments.fileAttachments.download".tr(),
          onPressed: () async {}),
      const Gap(direction: Axis.horizontal),
      CustomButton(
          label: "eDigitalFilingFileAttachments.fileAttachments.mergeDownload"
              .tr(),
          onPressed: () async {}),
      const Gap(direction: Axis.horizontal),
      CustomButton(
          label:
              "eDigitalFilingFileAttachments.fileAttachments.linkToApplicationID"
                  .tr(),
          onPressed: () async {}),
      const Gap(direction: Axis.horizontal),
      CustomButton(
          label: "eDigitalFilingFileAttachments.fileAttachments.continue".tr(),
          onPressed: () async {}),
    ],
  );
}

Widget saveCancelButtonWidget(
    BuildContext context, FileAttachmentViewModel viewModel) {
  return Row(mainAxisAlignment: MainAxisAlignment.end, children: [
    const Gap(),
    CustomButton(
        label: "eDigitalFilingFileAttachments.fileAttachments.browse".tr(),
        onPressed: () {
          viewModel.onBrowsePressed();
        }),
    const Gap(direction: Axis.horizontal),
    if (viewModel.selectedDocuments.isNotEmpty)
      CustomButton(
          label: "eDigitalFilingFileAttachments.fileAttachments.upload".tr(),
          onPressed: () {
            viewModel.onUploadDocumentsPressed();
          })
  ]);
}
