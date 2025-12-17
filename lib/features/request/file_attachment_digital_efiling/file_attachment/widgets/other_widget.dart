import 'package:flutter/material.dart';
import 'package:wcas_frontend/core/constants/constants.dart';

class OtherDocumentList extends StatelessWidget {
  final String documentName;
  final String subType;
  final bool isChecked;
  final ValueChanged<bool?> onChanged;

  const OtherDocumentList({
    super.key,
    required this.documentName,
    required this.subType,
    this.isChecked = false,
    required this.onChanged,
  });

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
        Text(
          documentName,
          style: AppStyle.documentNameStyle,
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
