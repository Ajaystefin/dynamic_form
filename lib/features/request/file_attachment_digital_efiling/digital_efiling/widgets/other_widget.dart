import "package:flutter/material.dart";
import "package:wcas_frontend/core/constants/constants.dart";
import "package:wcas_frontend/features/request/file_attachment_digital_efiling/digital_efiling/model.dart";
import "package:wcas_frontend/models/request/file_attachment/doc_sub_type_data.dart";

class OtherDocumentList extends StatelessWidget {
  const OtherDocumentList({
    required this.viewModel,
    required this.documentName,
    required this.fileName,
    required this.subType,
    required this.docData,
    required this.onChanged,
    super.key,
    this.isChecked = false,
    this.edmsDriveItemId,
  });
  final String documentName;
  final String fileName;
  final String subType;
  final bool isChecked;
  final ValueChanged<bool?> onChanged;
  final DocSubTypeData? docData;
  final String? edmsDriveItemId;
  final DigitalEfilingViewModel viewModel;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        GestureDetector(
          behavior: HitTestBehavior.translucent,
          onTap: () {}, // absorb tap
          child: Checkbox(
            key: key,
            value: docData?.isChecked ?? false,
            onChanged: (value) {
              viewModel.toggleDocumentSelection(
                key.toString(),
                value ?? false,
                docData,
              );
            },
          ),
        ),
        const Icon(Icons.file_present_outlined, size: 18),
        const SizedBox(width: 10),
        GestureDetector(
          behavior: HitTestBehavior.translucent,
          onTap: () {
            viewModel.downloadDocument(
              edmsDriveItemId,
              docData?.webUrl,
              docData?.downloadName ?? fileName,
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
