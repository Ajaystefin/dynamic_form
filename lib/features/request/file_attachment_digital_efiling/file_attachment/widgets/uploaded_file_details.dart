import "package:easy_localization/easy_localization.dart";
import "package:flutter/material.dart";
import "package:wcas_frontend/core/components/custom_table/table.dart";
import "package:wcas_frontend/core/components/tooltip.dart";
import "package:wcas_frontend/core/utils/scale.dart";
import "package:wcas_frontend/core/utils/utils.dart";
import "package:wcas_frontend/features/request/file_attachment_digital_efiling/file_attachment/model.dart";
import "package:wcas_frontend/models/request/file_attachment/document.dart";

class UploadedFileDetails extends StatefulWidget {
  const UploadedFileDetails({required this.viewModel, super.key});
  final FileAttachmentViewModel viewModel;

  @override
  State<UploadedFileDetails> createState() => _UploadedFileDetailsState();
}

class _UploadedFileDetailsState extends State<UploadedFileDetails> {
  @override
  Widget build(BuildContext context) {
    switch (widget.viewModel.state.documentsLoaderStatus) {
      case LoadingStatus.loading:
        return const Center(
          child: CircularProgressIndicator(),
        );
      case LoadingStatus.empty:
        return Padding(
          padding: const EdgeInsets.only(left: 8),
          child: Text(
            "eDigitalFilingFileAttachments.fileAttachments.noRecords".tr(),
          ),
        );
      case LoadingStatus.error:
        return Center(
          child: Text(
            widget.viewModel.state.documentListErrorMessage ??
                "common.errorState".tr(),
          ),
        );
      default:
        return _buildView(context);
    }
  }

  Widget _buildView(BuildContext context) {
    final List<Document> documentList = widget.viewModel.uploadedDocuments;

    List<TableColumn> columns = [];
    List<List<Widget>> rows = [];

    columns = [
      // const TableColumn(label: SizedBox()),

      TableColumn(
        label: Text("eDigitalFilingFileAttachments.fileAttachments.sNo".tr()),
      ),
      const TableColumn(label: SizedBox()),
      TableColumn(
        label: Text(
          "eDigitalFilingFileAttachments.fileAttachments.documentType".tr(),
        ),
      ),
      TableColumn(
        label: Text(
          "eDigitalFilingFileAttachments.fileAttachments.groupRim".tr(),
        ),
      ),
      TableColumn(
        forcedWidth: 60.w,
        label: Text(
          "eDigitalFilingFileAttachments.fileAttachments.companyRim".tr(),
        ),
      ),
      TableColumn(
        label: Text(
          "eDigitalFilingFileAttachments.fileAttachments.subType".tr(),
        ),
      ),
      TableColumn(
        label: Text(
          "eDigitalFilingFileAttachments.fileAttachments.subSubType".tr(),
        ),
      ),
      TableColumn(
        label: Text(
          "eDigitalFilingFileAttachments.fileAttachments.subSubSubType".tr(),
        ),
      ),
      TableColumn(
        label: Text(
          "eDigitalFilingFileAttachments.fileAttachments.language".tr(),
        ),
      ),
      TableColumn(
        forcedWidth: 80.w,
        label: Text(
          "eDigitalFilingFileAttachments.fileAttachments.endPeriodEndDate".tr(),
        ),
      ),
      TableColumn(
        forcedWidth: 60.w,
        label: Text(
          "eDigitalFilingFileAttachments.fileAttachments.documentName".tr(),
        ),
      ),
      const TableColumn(label: SizedBox()),
    ];
    rows = documentList.asMap().entries.map((entry) {
      final int i = entry.key; // index within current list
      final document = entry.value; // the document item
      final sr = 0 + i + 1; // serial number

      final fileNames = document.files?.isNotEmpty == true
          ? document.files!.map((f) => f.name).join(", ")
          : "No files";

      return [
        // Checkbox(
        //   activeColor: AppColors.primary,
        //   value: widget.viewModel.selectedRows[document.sno] ?? false,
        //   onChanged: (isSelected) {
        //     setState(() {
        //       widget.viewModel.toggleSelection(document.sno ?? "",
        // isSelected!);
        //     });
        //   },
        // ),
        Text(sr.toString()),
        CustomTooltip(
          message: fileNames,
          child: document.downloadLoader == LoadingStatus.loading
              ? const Padding(
                  padding: EdgeInsets.all(8),
                  child: SizedBox(
                    width: 14,
                    height: 14,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                    ),
                  ),
                )
              : IconButton(
                  onPressed: () {
                    widget.viewModel.downloadViewDocument(document);
                  },
                  icon: const Icon(Icons.insert_drive_file),
                ),
        ),

        Text(document.documentType?.name ?? ""),
        Text(
          (document.groupRim != null && document.groupRim != 0)
              ? document.groupRim.toString()
              : "N/A",
        ),
        CustomTooltip(
          message: document.companyRim ?? "N/A",
          child: Text(document.companyRim ?? "N/A"),
        ),
        Text(document.subType?.name ?? "N/A"),
        Text(document.subSubType?.name ?? "N/A"),
        Text(document.subSubSubType?.name ?? "N/A"),
        Text(document.languageName ?? "N/A"),
        Text(
          document.date != null
              ? DateFormat("dd-MM-yyyy").format(document.date!)
              : "N/A",
        ),
        Text(
          document.documentName?.isNotEmpty == true
              ? document.documentName!
              : "N/A",
        ),
        document.deleteLoader == LoadingStatus.loading
            ? const Padding(
                padding: EdgeInsets.all(8),
                child: SizedBox(
                  width: 14,
                  height: 14,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                  ),
                ),
              )
            : IconButton(
                onPressed: () {
                  widget.viewModel.onDeleteDocumentPressed(document);
                },
                icon: const Icon(Icons.delete),
              ),
      ];
    }).toList();

    return CustomRawTable(
      key: UniqueKey(),
      autoFitWidth: true,
      columnHeaderHeight: 30.w,
      columns: columns,
      rows: rows,
    );
  }
}
