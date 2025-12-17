import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:wcas_frontend/core/components/accordion.dart';
import 'package:wcas_frontend/core/components/custom_table/table.dart';
import 'package:wcas_frontend/core/components/tooltip.dart';
import 'package:wcas_frontend/core/utils/scale.dart';
import 'package:wcas_frontend/features/request/file_attachment_digital_efiling/file_attachment/model.dart';
import 'package:wcas_frontend/features/request/file_attachment_digital_efiling/file_attachment/widgets/other_widget.dart';
import '../../../../../models/request/file_attachment/doc_sub_type_data.dart';

Widget creditApplicationTable(
    FileAttachmentViewModel viewModel, DocSubTypeData? tableData) {
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

Widget _buildFileAccordian(FileAttachmentViewModel viewModel) {
  final ExpansionTileController expansionController = ExpansionTileController();

  return CustomAccordion(
    title: "Files",
    expansionController: expansionController,
    initiallyExpanded: true,
    children: List.generate(1, (index) {
      final key = "DocumentCredit_$index";
      final isChecked = viewModel.isDocumentSelected(key);

      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 4.0),
        child: OtherDocumentList(
          documentName: "Document Credit",
          isChecked: isChecked,
          onChanged: (value) {
            viewModel.toggleDocumentSelection(key, value ?? false);
          },
          subType: "Type Credit",
          key: ValueKey("doc_$index"),
        ),
      );
    }),
  );
}

List<List<Widget>> getDocumentsTableRows(
    FileAttachmentViewModel viewModel, DocSubTypeData? tableData) {
  List<List<Widget>> widgets = [];

  widgets.add([
    _buildFileAccordian(viewModel),
    Text("${tableData?.applicationID}"),
    Text(DateFormat('dd-MM-yyyy').format(tableData?.date ?? DateTime.now())),
    Text("${tableData?.subType}"),
    CustomTooltip(
        message: tableData?.summary.toString() ?? "",
        child: Text("${tableData?.summary}")),
    Text("${tableData?.decision}"),
  ]);
  return widgets;
}
