import "package:flutter/material.dart";
import "package:wcas_frontend/core/components/gap.dart";
import "package:wcas_frontend/core/constants/constants.dart";
import "package:wcas_frontend/models/request/file_attachment/doc_sub_type_data.dart";

class DocumentIconNameField extends StatelessWidget {
  DocumentIconNameField({super.key, this.docSubTypeData});
  final DocSubTypeData? docSubTypeData;
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
