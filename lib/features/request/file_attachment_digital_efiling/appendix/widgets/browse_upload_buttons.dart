import "package:easy_localization/easy_localization.dart";
import "package:flutter/material.dart";
import "package:wcas_frontend/core/components/button.dart";
import "package:wcas_frontend/core/components/gap.dart";
import "package:wcas_frontend/core/constants/_server_constants.dart";
import "package:wcas_frontend/features/request/file_attachment_digital_efiling/appendix/model.dart";

/// Enhanced browse + upload button widget.
/// - `onPick`: custom file picker handler for this section/slot.
/// - `onUpload`: custom upload handler for this section/slot.
/// If not provided, falls back to legacy behavior for compatibility.
Widget browseUploadButtonWidget(
  BuildContext context,
  AppendixViewModel viewModel, {
  bool isEnabled = true,
  VoidCallback? onPick,
  VoidCallback? onUpload,
}) {
  return Row(
    mainAxisAlignment: MainAxisAlignment.end,
    children: [
      // Browse button
      CustomButton(
        label: "eDigitalFilingFileAttachments.appendix.browse".tr(),
        onPressed: isEnabled
            ? onPick ??
                () async {
                  // Legacy fallback: global picker
                  await viewModel.pickMultipleFiles();
                }
            : null,
      ),
      const Gap(direction: Axis.horizontal),
      // Upload button
      CustomButton(
        label: "eDigitalFilingFileAttachments.appendix.upload".tr(),
        onPressed: isEnabled
            ? onUpload ??
                () async {
                  await viewModel.uploadFirstAppendixImageFrom(
                    sourceFiles: viewModel.selectedFiles,
                    customerType: viewModel.selectedSectionType,
                    imageType:
                        ServerConstants.financial, // Default type for legacy
                  );
                }
            : null,
      ),
    ],
  );
}
