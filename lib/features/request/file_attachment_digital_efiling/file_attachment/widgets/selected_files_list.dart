import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:wcas_frontend/core/components/custom_table/table.dart';
import 'package:wcas_frontend/core/components/gap.dart';
import 'package:wcas_frontend/core/components/tooltip.dart';
import 'package:wcas_frontend/core/utils/scale.dart';
import 'package:wcas_frontend/features/request/file_attachment_digital_efiling/file_attachment/model.dart';

class SelectedFilesList extends StatelessWidget {
  final FileAttachmentViewModel viewModel;
  const SelectedFilesList({super.key, required this.viewModel});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const Gap(),
        CustomRawTable(
          key: UniqueKey(),
          autoFitWidth: true,
          columnHeaderHeight: 32.w,
          columns: _columns(),
          rows: _rows(),
        ),
        const Gap(),
      ],
    );
  }

  List<TableColumn> _columns() {
    return [
      TableColumn(
          label: Text("eDigitalFilingFileAttachments.digitalEfiling.sr".tr())),
      TableColumn(
          label: Text(
              "eDigitalFilingFileAttachments.digitalEfiling.docType".tr())),
      TableColumn(
          label: Text(
              "eDigitalFilingFileAttachments.digitalEfiling.groupRim".tr())),
      TableColumn(
          label: Text(
              "eDigitalFilingFileAttachments.digitalEfiling.companyRim".tr())),
      TableColumn(
          label: Text(
              "eDigitalFilingFileAttachments.digitalEfiling.subType".tr())),
      TableColumn(
          label: Text(
              "eDigitalFilingFileAttachments.digitalEfiling.subSubType".tr())),
      TableColumn(
          forcedWidth: 60.w,
          label: Text(
              "eDigitalFilingFileAttachments.digitalEfiling.applicationId"
                  .tr())),
      TableColumn(
          forcedWidth: 80.w,
          label: Text(
              "eDigitalFilingFileAttachments.digitalEfiling.endPeriodEndDate"
                  .tr())),
      TableColumn(
          label: Text(
              "eDigitalFilingFileAttachments.digitalEfiling.language".tr())),
      TableColumn(
          forcedWidth: 60.w,
          label: Text(
              "eDigitalFilingFileAttachments.digitalEfiling.documentName"
                  .tr())),
      TableColumn(
          label:
              Text("eDigitalFilingFileAttachments.digitalEfiling.file".tr())),
      TableColumn(label: Text("common.delete".tr())),
    ];
  }

  List<List<Widget>> _rows() {
    return viewModel.selectedDocuments.asMap().entries.map((p) {
      final doc = viewModel.selectedDocuments[p.key];
      final fileNames = doc.files?.isNotEmpty == true
          ? doc.files!.map((f) => f.name).join(", ")
          : "No files";

      return [
        Text((p.key + 1).toString()),
        Text(doc.documentType?.name.toString() ?? "N/A"),
        Text(doc.groupRim != null ? doc.groupRim.toString() : "N/A"),
        Text(doc.companyRim ?? "N/A"),
        Text(doc.subType?.name ?? "N/A"),
        Text(doc.subSubType?.name ?? "N/A"),
        Text(
            doc.applicationId?.isNotEmpty == true ? doc.applicationId! : "N/A"),
        Text(doc.date != null
            ? DateFormat('dd-MM-yyyy').format(doc.date!)
            : "N/A"),
        Text(doc.language?.name ?? "N/A"),
        Text(doc.documentName?.isNotEmpty == true ? doc.documentName! : "N/A"),
        CustomTooltip(
          message: fileNames,
          child: IconButton(
            onPressed: () {
              // Optional: trigger file preview or action
            },
            icon: const Icon(Icons.insert_drive_file),
          ),
        ),
        IconButton(
          icon: const Icon(Icons.remove_circle, color: Colors.red),
          onPressed: () {
            viewModel.removeFileAt(p.key);
          },
        ),
      ];
    }).toList();
  }
}
