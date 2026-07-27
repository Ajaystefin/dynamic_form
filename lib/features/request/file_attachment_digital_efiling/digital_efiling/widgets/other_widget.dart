import "package:flutter/material.dart";
import "package:wcas_frontend/core/constants/constants.dart";
// import "package:wcas_frontend/features/request/file_attachment_digital_efiling/digital_efiling/model.dart";
import "package:wcas_frontend/models/request/file_attachment/doc_sub_type_data.dart";
import "package:wcas_frontend/repositories/file_attachment_repository.dart";

/// OtherDocumentList stateless widget

class OtherDocumentList extends StatelessWidget {
  /// Creates [OtherDocumentList] instance
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

  /// Document name
  final String documentName;

  /// File name
  final String fileName;

  /// Sub type
  final String subType;

  /// is checked
  final bool isChecked;

  /// onChange function
  final ValueChanged<bool?> onChanged;

  /// DocSubTypeData reference variable
  final DocSubTypeData? docData;

  /// edms drive item id
  final String? edmsDriveItemId;

  /// AttachmentViewModel view model
  final AttachmentViewModel viewModel;

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
                isSelected: value ?? false,
                docData,
              );
            },
          ),
        ),
        GestureDetector(
          behavior: HitTestBehavior.translucent,
          onTap: () {
            viewModel.downloadDocument(
              edmsDriveItemId ?? "",
              docData?.webUrl ?? "",
              docData?.downloadName ?? fileName,
            );
          }, // absorb tap
          child: const Icon(Icons.file_present_outlined, size: 18),
        ),
        const SizedBox(width: 10),
        GestureDetector(
          behavior: HitTestBehavior.translucent,
          onTap: () {
            viewModel.downloadDocument(
              edmsDriveItemId ?? "",
              docData?.webUrl ?? "",
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
