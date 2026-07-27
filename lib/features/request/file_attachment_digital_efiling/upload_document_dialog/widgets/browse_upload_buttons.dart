import "package:easy_localization/easy_localization.dart";
import "package:flutter/material.dart";
import "package:wcas_frontend/core/components/button.dart";
import "package:wcas_frontend/core/components/gap.dart";
import "package:wcas_frontend/core/utils/utils.dart";
import "package:wcas_frontend/features/request/file_attachment_digital_efiling/upload_document_dialog/model.dart";
import "package:wcas_frontend/features/request/file_attachment_digital_efiling/upload_document_dialog/state.dart";

/// button widget to browse upload
Widget browseUploadButtonWidget(
  BuildContext context,
  UploadDocumentDialogViewModel viewModel,
  UploadDocumentDialogState state,
) {
  return Row(
    mainAxisAlignment: MainAxisAlignment.end,
    children: [
      // if (viewModel.selectedFiles.isEmpty)
      CustomButton(
        label: "eDigitalFilingFileAttachments.fileAttachments.browse".tr(),
        onPressed: () {
          viewModel.pickMultipleFiles();
        },
      ),
      const Gap(direction: Axis.horizontal),
      if (viewModel.selectedFiles.isNotEmpty)
        CustomButton(
          label: "eDigitalFilingFileAttachments.fileAttachments.upload".tr(),
          semanticLabel:
              "eDigitalFilingFileAttachments.fileAttachments.upload".tr(),
          isLoading: state.uploadButtonStatus == LoadingStatus.loading,
          onPressed: () {
            viewModel.onUploadDocumentsPressed(context);
          },
        ),
    ],
  );
}
