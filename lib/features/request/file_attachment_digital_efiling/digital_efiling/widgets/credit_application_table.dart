import "package:easy_localization/easy_localization.dart";
import "package:flutter/material.dart";
import "package:wcas_frontend/core/components/custom_table/table.dart";
import "package:wcas_frontend/core/constants/constants.dart";
import "package:wcas_frontend/core/utils/scale.dart";
import "package:wcas_frontend/features/request/file_attachment_digital_efiling/digital_efiling/widgets/other_widget.dart";
import "package:wcas_frontend/models/request/file_attachment/doc_sub_type.dart";
import "package:wcas_frontend/models/request/file_attachment/doc_sub_type_data.dart";
import "package:wcas_frontend/repositories/file_attachment_repository.dart";

/// Credit aplicaiton table widget
Widget creditApplicationTable(
  BuildContext context,
  AttachmentViewModel viewModel,
  List<DocSubTypeDetail>? tableDataRaw,
) {
  // filter here
  final List<DocSubTypeDetail> tableData =
      dedupeAndAggregateFiles(tableDataRaw);

  final int maxFilesLength = tableData
      .map((t) => t.data?.files?.length ?? 0)
      .fold(0, (max, len) => len > max ? len : max);

  return CustomRawTable(
    key: UniqueKey(),
    columnHeaderHeight: 30.w,
    rowHeight: maxFilesLength * 28.w,
    columns: getDocumentsTableColumns(),
    rowModels: getDocumentsTableRows(context, viewModel, tableData),
  );
}

/// return list of TableColumn
List<TableColumn> getDocumentsTableColumns() {
  final List<TableColumn> columns = [
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
    const TableColumn(label: Text("Files"), columnWidth: FixedColumnWidth(350)),
    TableColumn(
      label: Text(
        "eDigitalFilingFileAttachments.fileAttachments.decision".tr(),
      ),
    ),
  ];

  return columns;
}

/// returns list of RowModel
List<RowModel>? getDocumentsTableRows(
  BuildContext context,
  AttachmentViewModel viewModel,
  List<DocSubTypeDetail>? tableData,
) {
  final List<RowModel> rows = (tableData ?? []).map((doc) {
    return RowModel(
      widget: [
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
        _buildFileAccordian(
          viewModel,
          doc.data?.files ?? [],
          doc.data,
        ),
        Text("${doc.data?.decision}"),
      ],
      isFilterRow: false,
    );
  }).toList();

  return rows;
}

Widget _buildFileAccordian(
  AttachmentViewModel viewModel,
  List<DocSubTypeData> files,
  DocSubTypeData? docData,
) {
  // final ExpansionTileController expansionController = ExpansionTileController();

  return Column(
    children: List.generate(files.length, (index) {
      final key = "DocumentCredit_$index";

      return OtherDocumentList(
        docData: files[index],
        viewModel: viewModel,
        documentName: files[index].fileName ?? "NA",
        fileName: files[index].fileName ?? "",
        isChecked: files[index].isChecked,
        onChanged: (value) {
          viewModel.toggleDocumentSelection(
            key,
            isSelected: value ?? false,
            files[index],
          );
        },
        subType: "",
        edmsDriveItemId: files[index].edmsDriveItemId,
        key: ValueKey("doc_$index"),
      );
    }),
  );
}

/// builds detail file from date
DocSubTypeData? buildDetailFileFromData(
  DocSubTypeData? data, {
  String? fallbackName,
}) {
  if (data == null) {
    return null;
  }

  // Prefer docName, then fileName, then external fallbackName (e.g., item.name)
  final String? name = () {
    final dn = data.docName?.trim();
    if (dn != null && dn.isNotEmpty) {
      return dn;
    }
    final fn = data.fileName?.trim();
    if (fn != null && fn.isNotEmpty) {
      return fn;
    }
    final fb = fallbackName?.trim();
    if (fb != null && fb.isNotEmpty) {
      return fb;
    }
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

  return DocSubTypeData(
    fileName: name,
    webUrl: path,
    edmsDriveItemId: edmsDriveItemId,
    date: data.date,
    groupId: data.groupId,
    docTypeId: data.docTypeId,
    downloadName: data.fileName,
    isChecked: data.isChecked,
    rimNo: data.rimNo,
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
    if (data == null) {
      continue;
    }

    final String appRefNo = data.appRefNo?.trim() ?? "";
    final String decision = data.decision?.trim() ?? "";

    // Avoid collapsing invalid rows
    if (appRefNo.isEmpty && decision.isEmpty) {
      continue;
    }

    final String key = "$appRefNo|$decision";

    final DocSubTypeData? fileEntry =
        buildDetailFileFromData(data, fallbackName: item.name);

    final DocSubTypeDetail aggregate = result.putIfAbsent(key, () {
      data.files = <DocSubTypeData>[];
      return item;
    });

    final Set<DocSubTypeData> existingFiles =
        (aggregate.data?.files ?? <DocSubTypeData>[])
            .whereType<DocSubTypeData>()
            .toSet();

    if (fileEntry != null) {
      existingFiles.add(fileEntry);
    }

    aggregate.data?.files = existingFiles.toList();
  }

  return result.values.toList();
}
