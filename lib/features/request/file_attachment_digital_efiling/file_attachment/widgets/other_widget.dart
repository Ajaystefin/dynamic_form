import "package:flutter/material.dart";
import "package:wcas_frontend/core/constants/constants.dart";
import "package:wcas_frontend/features/request/file_attachment_digital_efiling/file_attachment/model.dart";
import "package:wcas_frontend/models/request/file_attachment/file_details.dart";

class OtherDocumentList extends StatelessWidget {
  const OtherDocumentList({
    required this.viewModel,
    required this.documentName,
    required this.subType,
    required this.documentData,
    required this.onChanged,
    super.key,
    this.isChecked = false,
    this.edmsDriveItemId,
  });
  final String documentName;
  final String subType;
  final bool isChecked;
  final ValueChanged<bool?> onChanged;
  final FileDetails documentData;
  final String? edmsDriveItemId;
  final FileAttachmentViewModel viewModel;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        GestureDetector(
          behavior: HitTestBehavior.translucent,
          onTap: () {}, // absorb tap
          child: Checkbox(
            value: isChecked,
            onChanged: onChanged,
          ),
        ),
        const Icon(Icons.file_present_outlined, size: 18),
        const SizedBox(width: 10),
        GestureDetector(
          behavior: HitTestBehavior.translucent,
          onTap: () {
            viewModel.downloadDocument(
              edmsDriveItemId,
              documentData.webUrl ?? documentData.filePath,
              documentData.downloadName ?? documentName,
            );
          }, // absorb tap
          child: Text(
            documentName,
            style: AppStyle.documentNameStyle,
          ),
        ),
        const SizedBox(width: 50),
        Text(
          subType,
          style: AppStyle.documentSubTypeStyle,
        ),
      ],
    );
  }
}
