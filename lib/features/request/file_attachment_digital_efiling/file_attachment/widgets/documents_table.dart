import "package:easy_localization/easy_localization.dart";
import "package:flutter/material.dart";
import "package:wcas_frontend/core/components/accordion_file_tree.dart";
// ignore: unused_import
import "package:wcas_frontend/core/components/box_layout.dart";
import "package:wcas_frontend/core/components/custom_table/table.dart";
import "package:wcas_frontend/core/constants/constants.dart";
import "package:wcas_frontend/core/utils/scale.dart";
import "package:wcas_frontend/features/request/file_attachment_digital_efiling/file_attachment/model.dart";
import "package:wcas_frontend/models/admin/file_access.dart";
import "package:wcas_frontend/models/request/file_attachment/doc_sub_type_data.dart";

Widget documentsTable(
  FileAttachmentViewModel viewModel,
  DocSubTypeData? tableData,
) {
  return CustomRawTable(
    key: UniqueKey(),
    // headerColor: AppColors.tableHeadingColor,
    autoFitWidth: true,
    columnHeaderHeight: 30.w,
    rowHeight: 90.w,
    columns: getDocumentsTableColumns(),
    rows: getDocumentsTableRows(viewModel, tableData),
  );
}

List<TableColumn> getDocumentsTableColumns() {
  final List<TableColumn> columns = [
    const TableColumn(label: Text(""), columnWidth: FixedColumnWidth(350)),
    TableColumn(
      label: Text(
        "eDigitalFilingFileAttachments.fileAttachments.applicationId".tr(),
      ),
    ),
    TableColumn(
      label: Text("eDigitalFilingFileAttachments.fileAttachments.date".tr()),
    ),
    TableColumn(
      label: Text("eDigitalFilingFileAttachments.fileAttachments.subType".tr()),
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

Widget _buildFileTreeNode(FileAccess file, {int level = 0}) {
  if (file.children?.isEmpty ?? true) {
    return ListTile(
      dense: true,
      leading: const SizedBox(),
      title: Text(
        file.name ?? "",
        style: AppStyle.tableSuffixHeaderStyle,
      ),
      // trailing: trailingWidget(file),
    );
  }
  return CustomFileAccordion(
    title: file.name ?? "",
    textStyle: AppStyle.tableSuffixHeaderStyle,
    accordionType: AccordionFileType.teritory,
    // trailing: trailingWidget(file),
    showLeadingIcon: file.children?.isNotEmpty ?? false,
    children: (file.children?.isEmpty ?? true)
        ? []
        : List.generate(file.children!.length, (index) {
            return Padding(
              padding: const EdgeInsets.only(left: 14),
              child: _buildFileTreeNode(file.children![index]),
            );
          }),
  );
}

List<List<Widget>> getDocumentsTableRows(
  FileAttachmentViewModel viewModel,
  DocSubTypeData? tableData,
) {
  final List<List<Widget>> widgets = [];

  widgets.add([
    SingleChildScrollView(
      child: _buildFileTreeNode(viewModel.fileAccesses[1], level: 0),
    ),
    Text("${tableData?.applicationID}"),
    Text("${tableData?.date}"),
    Text("${tableData?.subType}"),
    Text("${tableData?.summary}"),
    Text("${tableData?.decision}"),
  ]);
  return widgets;
}
