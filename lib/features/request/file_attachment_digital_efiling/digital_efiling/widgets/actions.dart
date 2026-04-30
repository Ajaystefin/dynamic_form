import "package:easy_localization/easy_localization.dart";
import "package:flutter/material.dart";

import "package:wcas_frontend/core/components/button.dart";
import "package:wcas_frontend/core/components/gap.dart";
import "package:wcas_frontend/core/utils/utils.dart";
import "package:wcas_frontend/features/request/file_attachment_digital_efiling/digital_efiling/model.dart";

Widget actionButtons(DigitalEfilingViewModel viewModel, BuildContext context) {
  return Row(
    mainAxisAlignment: MainAxisAlignment.end,
    children: [
      if (viewModel.selectedDocumentIds.isNotEmpty)
        CustomButton(
          label: "eDigitalFilingFileAttachments.fileAttachments.download".tr(),
          onPressed: () async {
            await viewModel.downloadDocumentsZip();
          },
        ),
      const Gap(
        direction: Axis.horizontal,
      ),
      if (viewModel.selectedDocumentIds.isNotEmpty)
        CustomButton(
          label: "eDigitalFilingFileAttachments.fileAttachments.mergeDownload"
              .tr(),
          onPressed: () async {
            await viewModel.mergeDownloadDocument();
          },
        ),
      const Gap(
        direction: Axis.horizontal,
      ),
      if (viewModel.buttonVisibilityStatus[DigitaleFileFields.uploadDocument]
              ?.call() ??
          false)
        CustomButton(
          label: "eDigitalFilingFileAttachments.fileAttachments.upload".tr(),
          onPressed: () async {
            await viewModel.openUploadDialog(context);
          },
        ),
    ],
  );
}
