// lib/features/request/file_attachment_digital_efiling/appendix/widgets/image_row.dart

import "package:easy_localization/easy_localization.dart";
import "package:flutter/material.dart";
import "package:wcas_frontend/core/components/gap.dart";
import "package:wcas_frontend/core/components/label.dart";
import "package:wcas_frontend/core/constants/constants.dart";
import "package:wcas_frontend/features/request/file_attachment_digital_efiling/appendix/model.dart";
import "package:wcas_frontend/features/request/file_attachment_digital_efiling/appendix/widgets/browse_upload_buttons.dart";
import "package:wcas_frontend/features/request/file_attachment_digital_efiling/appendix/widgets/selected_files_list.dart";

class ImageRow extends StatelessWidget {
  const ImageRow({
    required this.title,
    required this.viewModel,
    required this.type,
    super.key,
  });
  final String title;
  final AppendixViewModel viewModel;
  final CountryImage type;

  @override
  Widget build(BuildContext context) {
    final files = viewModel.countryFiles[type] ?? const [];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        LabelWidget(
          label: title,
          child: Column(
            children: [
              if (files.isNotEmpty)
                SelectedFilesList(
                  viewModel: viewModel,
                  files: files,
                  onRemove: (index) async {
                    await viewModel.onPressRemoveCountryFile(
                      type: type,
                      index: index,
                    );
                  },
                ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    "eDigitalFilingFileAttachments.appendix.allowedImgExt".tr(),
                    style: const TextStyle(
                      color: AppColors.darkTooltip,
                      fontSize: AppStyle.fontSizeSmall,
                    ),
                  ),
                  const Gap(),
                  if (!viewModel.isAppendixReadOnly)
                    browseUploadButtonWidget(
                      context,
                      viewModel,
                      onPick: () => viewModel.onPressBrowseCountryType(type),
                      onUpload: () async {
                        await viewModel.onPressUploadCountryType(type);
                      },
                    ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }
}
