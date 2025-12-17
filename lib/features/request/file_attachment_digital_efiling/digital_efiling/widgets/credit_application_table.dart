import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:wcas_frontend/core/components/accordion.dart';
import 'package:wcas_frontend/core/components/custom_table/table.dart';
import 'package:wcas_frontend/core/components/tooltip.dart';
import 'package:wcas_frontend/core/utils/scale.dart';
import 'package:wcas_frontend/features/request/file_attachment_digital_efiling/digital_efiling/model.dart';
import 'package:wcas_frontend/features/request/file_attachment_digital_efiling/digital_efiling/widgets/other_widget.dart';
import 'package:wcas_frontend/models/request/file_attachment/doc_sub_type.dart';
import 'package:wcas_frontend/models/request/file_attachment/doc_sub_type_data.dart';
import 'package:wcas_frontend/models/request/file_attachment/file_details.dart';

Widget creditApplicationTable(
    DigitalEfilingViewModel viewModel, List<DocSubTypeDetail>? tableDataRaw) {
  // filter here
  final tableData = dedupeAndAggregateFiles(tableDataRaw);
  return CustomRawTable(
    key: UniqueKey(),
    // headerColor: AppColors.tableHeadingColor,
    autoFitWidth: true,
    columnHeaderHeight: 30.w,
    rowHeight: 90.w,
    columns: getDocumentsTableColumns(),
    rowModels: getDocumentsTableRows(viewModel, tableData),
  );
}

List<TableColumn> getDocumentsTableColumns() {
  List<TableColumn> columns = [
    const TableColumn(label: Text('Files'), columnWidth: FixedColumnWidth(350)),
    TableColumn(
        label: Text(
            "eDigitalFilingFileAttachments.fileAttachments.applicationId"
                .tr())),
    TableColumn(
        label: Text("eDigitalFilingFileAttachments.fileAttachments.date".tr())),
    TableColumn(
        label: Text(
            "eDigitalFilingFileAttachments.fileAttachments.applicationType"
                .tr())),
    TableColumn(
        label: Text(
            "eDigitalFilingFileAttachments.fileAttachments.requestSummary"
                .tr())),
    TableColumn(
        label: Text(
            "eDigitalFilingFileAttachments.fileAttachments.decision".tr())),
  ];

  return columns;
}

List<RowModel>? getDocumentsTableRows(
    DigitalEfilingViewModel viewModel, List<DocSubTypeDetail>? tableData) {
  List<RowModel>? rows = tableData?.map((doc) {
    return RowModel(widget: [
      _buildFileAccordian(viewModel, doc.data?.files ?? []),
      // Text("${doc.data?.fileName}"),
      Text("${doc.data?.applicationID}"),
      Text(DateFormat('dd-MM-yyyy').format(doc.data?.date ?? DateTime.now())),
      Text("${doc.data?.subType}"),
      CustomTooltip(
          message: doc.data?.summary.toString() ?? "",
          child: Text("${doc.data?.summary}")),
      Text("${doc.data?.decision}"),
    ], isFilterRow: false);
  }).toList();

  return rows;
}

Widget _buildFileAccordian(
    DigitalEfilingViewModel viewModel, List<FileDetails> files) {
  final ExpansionTileController expansionController = ExpansionTileController();

  return CustomAccordion(
    title: "common.files".tr(),
    expansionController: expansionController,
    initiallyExpanded: true, // ensure it's expanded initially
    children: List.generate(files.length, (index) {
      final key = "DocumentCredit_$index";
      final isChecked = files[index].isChecked;

      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 4.0),
        child: OtherDocumentList(
          viewModel: viewModel,
          documentName: files[index].fileName ?? "NA",
          isChecked: isChecked,
          onChanged: (value) {
            viewModel.toggleDocumentSelection(
                key, value ?? false, files[index]);
          },
          subType: "",
          edmsDriveItemId: files[index].fileId,
          key: ValueKey("doc_$index"),
        ),
      );
    }),
  );
}

FileDetails? buildDetailFileFromData(DocSubTypeData? data,
    {String? fallbackName}) {
  if (data == null) return null;

  // Prefer docName, then fileName, then external fallbackName (e.g., item.name)
  final String? name = () {
    final dn = data.docName?.trim();
    if (dn != null && dn.isNotEmpty) return dn;
    final fn = data.fileName?.trim();
    if (fn != null && fn.isNotEmpty) return fn;
    final fb = fallbackName?.trim();
    if (fb != null && fb.isNotEmpty) return fb;
    return null;
  }();

  // Attempt to get a fileId if available (e.g., edmsDriveItemId or similar)
  final String? fileId =
      data.edmsDriveItemId?.trim(); // adjust to your field name

  // If you have a path source, set it (or leave null)
  final String? path = data.webUrl?.trim(); // adjust if you have such a field

  if (name == null && fileId == null && path == null) {
    return null; // nothing to build
  }

  return FileDetails(
    fileName: name,
    filePath: path,
    fileId: fileId,
  );
}

/// Dedupes by (appRefNo, decision) and aggregates file names into `files`.
List<DocSubTypeDetail> dedupeAndAggregateFiles(
    List<DocSubTypeDetail>? tableData) {
  if (tableData == null || tableData.isEmpty) return const <DocSubTypeDetail>[];

  final Map<String, DocSubTypeDetail> byKey = {};

  for (final item in tableData) {
    final data = item.data;
    if (data == null) continue;

    final appRefNo = data.appRefNo?.trim() ?? '';
    final decision = data.decision?.trim() ?? '';
    final key = '$appRefNo|$decision';

    // Build a DetailFile from this item’s data
    final FileDetails? fileEntry =
        buildDetailFileFromData(data, fallbackName: item.name);

    if (!byKey.containsKey(key)) {
      // Keep first occurrence
      final List<FileDetails> files = (data.files is List)
          ? (data.files as List).whereType<FileDetails>().toList()
          : <FileDetails>[];

      if (fileEntry != null && !files.contains(fileEntry)) {
        files.add(fileEntry);
      }
      item.data?.files = files;
      byKey[key] = item;
    } else {
      // Merge into kept record
      final kept = byKey[key]!;
      final List<FileDetails> keptFiles = (kept.data?.files is List)
          ? (kept.data!.files as List).whereType<FileDetails>().toList()
          : <FileDetails>[];

      if (fileEntry != null && !keptFiles.contains(fileEntry)) {
        keptFiles.add(fileEntry);
      }
      kept.data?.files = keptFiles;

      // Optional: merge other non-null fields if needed
      // kept.data!.docName ??= data.docName;
      // kept.data!.fileName ??= data.fileName;
    }
  }

  return byKey.values.toList();
}
