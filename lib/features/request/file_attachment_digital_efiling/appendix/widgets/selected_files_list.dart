import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:wcas_frontend/core/components/custom_table/table.dart';
import 'package:wcas_frontend/core/components/gap.dart';
import 'package:wcas_frontend/core/utils/scale.dart';
import 'package:wcas_frontend/features/request/file_attachment_digital_efiling/appendix/model.dart';

class SelectedFilesList extends StatelessWidget {
  final AppendixViewModel viewModel;
  const SelectedFilesList({super.key, required this.viewModel});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const Gap(),
        CustomRawTable(
          key: UniqueKey(),
          rowHeight: 48,
          autoFitWidth: true,
          columnHeaderHeight: 30.w,
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
          width: 45.w,
          label: Text("eDigitalFilingFileAttachments.fileAttachments.sr".tr())),
      TableColumn(width: 45.w, label: const Text("File Name")),
      TableColumn(
          forcedWidth: 100.w,
          label:
              Text("eDigitalFilingFileAttachments.fileAttachments.file".tr())),
      TableColumn(
          forcedWidth: 50.w,
          label: Text(
              "eDigitalFilingFileAttachments.fileAttachments.delete".tr())),
    ];
  }

  List<List<Widget>> _rows() {
    return viewModel.uploadedDocuments.asMap().entries.map((entry) {
      final index = entry.key;
      final doc = entry.value; // AppendixDocument
      final fileName = (doc.fileName?.trim().isNotEmpty ?? false)
          ? doc.fileName!.trim()
          : _basename(doc.documentName ?? 'image');

      return [
        Text((index + 1).toString()),
        Tooltip(
          message: fileName,
          child: Align(
            alignment: Alignment.centerLeft,
            child: Text(fileName, overflow: TextOverflow.ellipsis),
          ),
        ),
        Center(
          child: IconButton(
            onPressed: () {
              // viewModel.previewFile(doc);
            },
            icon: const Icon(Icons.insert_drive_file),
          ),
        ),
        Center(
          child: IconButton(
            icon: const Icon(Icons.remove_circle, color: Colors.red),
            onPressed: () => viewModel.removeFileAt(index),
          ),
        ),
      ];
    }).toList();
  }

  String _basename(String input) {
    final normalized = input.replaceAll('\\', '/');
    final idx = normalized.lastIndexOf('/');
    return idx == -1 ? normalized : normalized.substring(idx + 1);
  }
}
