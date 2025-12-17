import 'package:easy_localization/easy_localization.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:wcas_frontend/core/components/gap.dart';
import 'package:wcas_frontend/core/components/label.dart';
import 'package:wcas_frontend/core/constants/constants.dart';
import 'package:wcas_frontend/features/request/file_attachment_digital_efiling/appendix/model.dart';
import 'package:wcas_frontend/features/request/file_attachment_digital_efiling/appendix/widgets/browse_upload_buttons.dart';
import 'package:wcas_frontend/features/request/file_attachment_digital_efiling/appendix/widgets/selected_files_list.dart';

class ImageRow extends StatelessWidget {
  final String title;
  final PlatformFile? file;
  final AppendixViewModel viewModel;
  final BuildContext context;
  const ImageRow(
      {super.key,
      required this.title,
      this.file,
      required this.viewModel,
      required this.context});

  @override
  Widget build(BuildContext context) {
    final subtitle = Text(
      'eDigitalFilingFileAttachments.appendix.allowedImgExt'.tr(),
      style: const TextStyle(color: AppColors.defaultTextColor),
    );

    return LabelWidget(
      label: title,isRequired: true,
      // infoContent: ,
      child: Column(
        children: [
          if (viewModel.selectedFiles.isNotEmpty)
            SelectedFilesList(viewModel: viewModel),
          Row(
            children: [
              Expanded(
                child: ListTile(
                  dense: true,
                  subtitle: file == null
                      ? subtitle
                      : Text(
                          file!.name,
                          style: const TextStyle(
                              color: AppColors.defaultTextColor),
                        ),
                ),
              ),
              const Gap(
                direction: Axis.horizontal,
              ),
              browseUploadButtonWidget(
                context,
                viewModel,
              ),
            ],
          ),
        ],
      ),
    );
  }
}
