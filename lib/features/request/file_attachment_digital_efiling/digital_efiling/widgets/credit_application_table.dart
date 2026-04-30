import "package:easy_localization/easy_localization.dart";
import "package:flutter/material.dart";
import "package:wcas_frontend/core/components/accordion.dart";
import "package:wcas_frontend/core/components/custom_table/table.dart";
import "package:wcas_frontend/core/constants/constants.dart";
import "package:wcas_frontend/core/utils/scale.dart";
import "package:wcas_frontend/features/request/file_attachment_digital_efiling/digital_efiling/model.dart";
import "package:wcas_frontend/features/request/file_attachment_digital_efiling/digital_efiling/widgets/other_widget.dart";
import "package:wcas_frontend/models/request/file_attachment/doc_sub_type.dart";
import "package:wcas_frontend/models/request/file_attachment/doc_sub_type_data.dart";
import "package:wcas_frontend/models/request/file_attachment/file_details.dart";

Widget creditApplicationTable(
  BuildContext context,
  DigitalEfilingViewModel viewModel,
  List<DocSubTypeDetail>? tableDataRaw,
) {
  // filter here
  final List<DocSubTypeDetail> tableData =
      dedupeAndAggregateFiles(tableDataRaw);
  return CustomRawTable(
    key: UniqueKey(),
    // headerColor: AppColors.tableHeadingColor,
    autoFitWidth: true,
    columnHeaderHeight: 30.w,
    rowHeight: 90.w,
    columns: getDocumentsTableColumns(),
    rowModels: getDocumentsTableRows(context, viewModel, tableData),
  );
}

List<TableColumn> getDocumentsTableColumns() {
  final List<TableColumn> columns = [
    const TableColumn(label: Text("Files"), columnWidth: FixedColumnWidth(350)),
    TableColumn(
      label: Text(
        "eDigitalFilingFileAttachments.fileAttachments.applicationId".tr(),
      ),
    ),
    TableColumn(
      label: Text("eDigitalFilingFileAttachments.fileAttachments.date".tr()),
    ),
    TableColumn(
      label: Text(
        "eDigitalFilingFileAttachments.fileAttachments.applicationType".tr(),
      ),
    ),
    TableColumn(
      label: Text(
        "eDigitalFilingFileAttachments.fileAttachments.requestSummary".tr(),
      ),
    ),
    TableColumn(
      label: Text(
        "eDigitalFilingFileAttachments.fileAttachments.decision".tr(),
      ),
    ),
  ];

  return columns;
}

List<RowModel>? getDocumentsTableRows(
  BuildContext context,
  DigitalEfilingViewModel viewModel,
  List<DocSubTypeDetail>? tableData,
) {
  final List<RowModel> rows = (tableData ?? [])
      .map(
        (doc) => RowModel(
          widget: [
            SingleChildScrollView(
              child: SizedBox(
                height: (((doc.data?.files?.length ?? 1) * 45) + 50),
                child: Column(
                  children: [
                    Expanded(
                      child: _buildFileAccordian(
                        viewModel,
                        doc.data?.files ?? [],
                        doc.data,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Text("${doc.data?.appRefNo}"),
            Text(
              DateFormat("dd-MM-yyyy")
                  .format(doc.data?.decisionDate ?? DateTime.now()),
            ),
            Text(doc.data?.subSubType?.name ?? ""),
            TextButton(
              style: ButtonStyle(
                padding: WidgetStateProperty.all(EdgeInsets.zero),
              ),
              onPressed: () =>
                  viewModel.viewRequestSummary(doc.data?.appRefNo, context),
              child: Text(
                "common.view".tr(),
                style: const TextStyle(
                  fontSize: AppStyle.columnName,
                  decoration: TextDecoration.underline,
                ),
              ),
            ),
            Text("${doc.data?.decision}"),
          ],
          isFilterRow: false,
        ),
      )
      .toList();

  return rows;
}

Widget _buildFileAccordian(
  DigitalEfilingViewModel viewModel,
  List<FileDetails> files,
  DocSubTypeData? docData,
) {
  final ExpansibleController expansionController = ExpansibleController();

  return CustomAccordion(
    title: "common.files".tr(),
    expansionController: expansionController,
    initiallyExpanded: true, // ensure it's expanded initially
    children: List.generate(files.length, (index) {
      final key = "DocumentCredit_$index";
      final isChecked = files[index].isChecked;

      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 4),
        child: OtherDocumentList(
          docData: docData,
          viewModel: viewModel,
          documentName: files[index].fileName ?? "NA",
          fileName: files[index].fileName ?? "",
          isChecked: isChecked,
          onChanged: (value) {
            viewModel.toggleDocumentSelection(
              key,
              value ?? false,
              files[index],
            );
          },
          subType: "",
          edmsDriveItemId: files[index].edmsDriveItemId,
          key: ValueKey("doc_$index"),
        ),
      );
    }),
  );
}

FileDetails? buildDetailFileFromData(
  DocSubTypeData? data, {
  String? fallbackName,
}) {
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
  final String? edmsDriveItemId =
      data.edmsDriveItemId?.trim(); // adjust to your field name

  // If you have a path source, set it (or leave null)
  final String? path = data.webUrl?.trim(); // adjust if you have such a field

  if (name == null && edmsDriveItemId == null && path == null) {
    return null; // nothing to build
  }

  return FileDetails(
    fileName: name,
    filePath: path,
    edmsDriveItemId: edmsDriveItemId,
    date: data.date,
    groupId: data.groupId,
    docTypeId: data.docType?.id,
    downloadName: data.fileName,
  );
}

/// Dedupes by (appRefNo, decision) and aggregates file names into `files`.
List<DocSubTypeDetail> dedupeAndAggregateFiles(
  List<DocSubTypeDetail>? tableData,
) {
  if (tableData == null || tableData.isEmpty) {
    return const <DocSubTypeDetail>[];
  }

  final Map<String, DocSubTypeDetail> result = {};

  for (final DocSubTypeDetail item in tableData) {
    final DocSubTypeData? data = item.data;
    if (data == null) continue;

    final String appRefNo = data.appRefNo?.trim() ?? "";
    final String decision = data.decision?.trim() ?? "";

    // Avoid collapsing invalid rows
    if (appRefNo.isEmpty && decision.isEmpty) continue;

    final String key = "$appRefNo|$decision";

    final FileDetails? fileEntry =
        buildDetailFileFromData(data, fallbackName: item.name);

    final DocSubTypeDetail aggregate = result.putIfAbsent(key, () {
      data.files = <FileDetails>[];
      return item;
    });

    final Set<FileDetails> existingFiles =
        (aggregate.data?.files ?? <FileDetails>[])
            .whereType<FileDetails>()
            .toSet();

    if (fileEntry != null) {
      existingFiles.add(fileEntry);
    }

    aggregate.data?.files = existingFiles.toList();
  }

  return result.values.toList();
}
