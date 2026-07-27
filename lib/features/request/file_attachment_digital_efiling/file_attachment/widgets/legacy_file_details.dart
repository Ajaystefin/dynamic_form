import "package:easy_localization/easy_localization.dart";
import "package:flutter/material.dart";
import "package:wcas_frontend/core/components/custom_table/table.dart";
import "package:wcas_frontend/core/components/tooltip.dart";
import "package:wcas_frontend/core/utils/scale.dart";
import "package:wcas_frontend/core/utils/utils.dart";
import "package:wcas_frontend/features/request/file_attachment_digital_efiling/file_attachment/model.dart";
import "package:wcas_frontend/models/request/file_attachment/doc_sub_type.dart";

/// LegacyFileDetails stateless widget
class LegacyFileDetails extends StatefulWidget {
  /// Creates [LegacyFileDetails] instance
  const LegacyFileDetails({required this.viewModel, super.key});

  /// FileAttachmentViewModel view model to handle actions
  final FileAttachmentViewModel viewModel;

  @override
  State<LegacyFileDetails> createState() => _LegacyFileDetailsState();
}

class _LegacyFileDetailsState extends State<LegacyFileDetails> {
  int legacyFilesTable = 0;
  @override
  Widget build(BuildContext context) {
    switch (widget.viewModel.state.legacyLoaderStatus) {
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
        return _buildView(context, widget.viewModel);
    }
  }

  Widget _buildView(BuildContext context, FileAttachmentViewModel viewModel) {
    final List<DocSubTypeDetail> documentList = widget.viewModel.legacyFiles;

    List<TableColumn> columns = [];
    List<List<Widget>> rows = [];

    columns = [
      TableColumn(
        forcedWidth: 20.w,
        label: Text("eDigitalFilingFileAttachments.fileAttachments.sNo".tr()),
      ),
      TableColumn(
        forcedWidth: 20.w,
        label: const SizedBox(),
      ),
      TableColumn(
        label: Text(
          "eDigitalFilingFileAttachments.fileAttachments.documentName".tr(),
        ),
      ),
      TableColumn(
        forcedWidth: 40.w,
        label: Text(
          "eDigitalFilingFileAttachments.fileAttachments.date".tr(),
        ),
      ),
    ];
    rows = documentList.asMap().entries.map((entry) {
      final int i = entry.key; // index within current list
      final document = entry.value; // the document item
      final sr = 0 + i + 1; // serial number

      return [
        Text(sr.toString()),
        CustomTooltip(
          message: document.name ?? "",
          child: IconButton(
            onPressed: () {
              viewModel.downloadDocument(
                document.data?.edmsDriveItemId ?? "",
                document.data?.webUrl ?? "",
                document.name ?? "",
              );
            },
            icon: const Icon(Icons.insert_drive_file),
          ),
        ),
        Text(
          document.name ?? "N/A",
        ),
        Text(
          document.data?.date != null
              ? DateFormat("dd-MM-yyyy")
                  .format(document.data?.date ?? DateTime.now())
              : "N/A",
        ),
      ];
    }).toList();

    return CustomRawTable(
      key: UniqueKey(),
      columnHeaderHeight: 30.w,
      columns: columns,
      rows: rows,
      rowsPerPage: 15,
      initialPage:legacyFilesTable ,
      onPageChange: (int pageNo) {
        legacyFilesTable = pageNo;
      },
    );
  }
}
