import "package:flutter/material.dart";
import "package:wcas_frontend/core/components/gap.dart";
import "package:wcas_frontend/core/constants/constants.dart";
import "package:wcas_frontend/models/request/file_attachment/doc_sub_type_data.dart";

/// DocumentIconNameField stateless widget
class DocumentIconNameField extends StatelessWidget {
  /// Creates [DocumentIconNameField] instance
  DocumentIconNameField({super.key, this.docSubTypeData});

  /// DocSubTypeData reference variable
  final DocSubTypeData? docSubTypeData;

  /// List of DocSubTypeData
  final List<DocSubTypeData?> docSubTypeDataList = [];

  @override
  Widget build(BuildContext context) {
    docSubTypeDataList.add(docSubTypeData);
    return ListView.builder(
      shrinkWrap: true,
      itemCount: docSubTypeDataList.length,
      itemBuilder: (BuildContext context, int index) {
        return Row(
          children: [
            const Icon(Icons.insert_drive_file),
            const Gap(
              direction: Axis.horizontal,
            ),
            Expanded(
              child: Text(
                docSubTypeDataList[index]?.docName ?? "",
                style: AppStyle.tableSuffixHeaderStyle,
              ),
            ),
            const Gap(
              direction: Axis.horizontal,
            ),
            Expanded(
              child: Text(
                docSubTypeDataList[index]!.date!.toIso8601String(),
                style: AppStyle.tableSuffixHeaderStyle,
              ),
            ),
          ],
        );
      },
    );
  }
}
