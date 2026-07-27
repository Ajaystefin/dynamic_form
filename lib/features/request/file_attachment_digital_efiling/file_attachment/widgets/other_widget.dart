import "package:flutter/material.dart";
import "package:wcas_frontend/core/constants/constants.dart";
import "package:wcas_frontend/features/request/file_attachment_digital_efiling/file_attachment/model.dart";
import "package:wcas_frontend/models/request/file_attachment/doc_sub_type_data.dart";

/// OtherDocumentList stateless widget
class OtherDocumentList extends StatelessWidget {
  /// Creates [OtherDocumentList] instance
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

  /// document name
  final String documentName;

  /// sub type
  final String subType;

  /// is checked flag
  final bool isChecked;

  /// onChanged callback function
  final ValueChanged<bool?> onChanged;

  ///DocSubTypeData reference variable
  final DocSubTypeData documentData;

  /// edms Drive Item Id
  final String? edmsDriveItemId;

  /// FileAttachmentViewModel view model to handle actions
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
        GestureDetector(
          behavior: HitTestBehavior.translucent,
          onTap: () {
            viewModel.downloadDocument(
              edmsDriveItemId ?? "",
              documentData.webUrl ?? "",
              documentData.downloadName ?? documentName,
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
              documentData.webUrl ?? "",
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
