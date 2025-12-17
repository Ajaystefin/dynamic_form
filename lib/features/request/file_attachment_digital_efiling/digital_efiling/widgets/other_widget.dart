import 'package:flutter/material.dart';
import 'package:wcas_frontend/core/constants/constants.dart';
import 'package:wcas_frontend/features/request/file_attachment_digital_efiling/digital_efiling/model.dart';

class OtherDocumentList extends StatelessWidget {
  final String documentName;
  final String subType;
  final bool isChecked;
  final ValueChanged<bool?> onChanged;
  final String? edmsDriveItemId;
  final DigitalEfilingViewModel viewModel;

  const OtherDocumentList(
      {super.key,
      required this.viewModel,
      required this.documentName,
      required this.subType,
      this.isChecked = false,
      required this.onChanged,
      this.edmsDriveItemId});

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
        const Icon(Icons.file_present_outlined, size: 18.0),
        const SizedBox(width: 10),
        GestureDetector(
          behavior: HitTestBehavior.translucent,
          onTap: () {
            viewModel.downloadDocument(edmsDriveItemId, documentName);
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
