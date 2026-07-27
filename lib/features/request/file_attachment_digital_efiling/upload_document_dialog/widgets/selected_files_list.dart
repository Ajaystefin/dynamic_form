import "package:easy_localization/easy_localization.dart";
import "package:flutter/material.dart";
import "package:wcas_frontend/core/components/custom_table/table.dart";
import "package:wcas_frontend/core/components/gap.dart";
import "package:wcas_frontend/core/components/tooltip.dart";
import "package:wcas_frontend/core/utils/scale.dart";
import "package:wcas_frontend/features/request/file_attachment_digital_efiling/upload_document_dialog/model.dart";

/// SelectedFilesList stateless widget
class SelectedFilesList extends StatelessWidget {
  /// Creates [SelectedFilesList] instance
  const SelectedFilesList({required this.viewModel, super.key});

  /// UploadDocumentDialogViewModel view model to handle actions
  final UploadDocumentDialogViewModel viewModel;

  @override
  Widget build(BuildContext context) {
    if (viewModel.selectedDocuments.isEmpty) {
      return const SizedBox();
    }

    return Column(
      children: [
        const Gap(),
        CustomRawTable(
          key: UniqueKey(),
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
        label: Text("eDigitalFilingFileAttachments.digitalEfiling.sr".tr()),
      ),
      TableColumn(
        label: Text(
          "eDigitalFilingFileAttachments.digitalEfiling.docType".tr(),
        ),
      ),
      TableColumn(
        label: Text(
          "eDigitalFilingFileAttachments.digitalEfiling.groupRim".tr(),
        ),
      ),
      TableColumn(
        forcedWidth: 60.w,
        label: Text(
          "eDigitalFilingFileAttachments.digitalEfiling.companyRim".tr(),
        ),
      ),
      TableColumn(
        label: Text(
          "eDigitalFilingFileAttachments.digitalEfiling.subType".tr(),
        ),
      ),
      TableColumn(
        label: Text(
          "eDigitalFilingFileAttachments.digitalEfiling.subSubType".tr(),
        ),
      ),
      TableColumn(
        forcedWidth: 60.w,
        label: Text(
          "eDigitalFilingFileAttachments.digitalEfiling.applicationId".tr(),
        ),
      ),
      TableColumn(
        forcedWidth: 60.w,
        label: Text(
          "eDigitalFilingFileAttachments.digitalEfiling.endPeriodEndDate".tr(),
        ),
      ),
      TableColumn(
        label: Text(
          "eDigitalFilingFileAttachments.digitalEfiling.language".tr(),
        ),
      ),
      TableColumn(
        forcedWidth: 70.w,
        label: Text(
          "eDigitalFilingFileAttachments.digitalEfiling.documentName".tr(),
        ),
      ),
      TableColumn(
        label: Text("eDigitalFilingFileAttachments.digitalEfiling.file".tr()),
      ),
      TableColumn(label: Text("common.delete".tr())),
    ];
  }

  List<List<Widget>> _rows() {
    return viewModel.selectedDocuments
        .asMap()
        .entries
        .map(
          (p) => [
            Text((p.key + 1).toString()),
            Text(viewModel.selectedDocuments[p.key].documentType?.name ?? ""),
            Text(
              viewModel.selectedDocuments[p.key].groupRim != null
                  ? viewModel.selectedDocuments[p.key].groupRim.toString()
                  : "N/A",
            ),
            CustomTooltip(
              message:
                  viewModel.selectedDocuments[p.key].companyRim?.isNotEmpty ??
                          false
                      ? viewModel.selectedDocuments[p.key].companyRim!
                      : "N/A",
              child: Text(
                viewModel.selectedDocuments[p.key].companyRim?.isNotEmpty ??
                        false
                    ? viewModel.selectedDocuments[p.key].companyRim!
                    : "N/A",
              ),
            ),
            Text(viewModel.selectedDocuments[p.key].subType?.name ?? "N/A"),
            Text(
              viewModel.selectedDocuments[p.key].subSubType?.name ?? "N/A",
            ),
            Text(
              viewModel.selectedDocuments[p.key].applicationId?.isNotEmpty ??
                      false
                  ? viewModel.selectedDocuments[p.key].applicationId!
                  : "N/A",
            ),
            Text(
              viewModel.selectedDocuments[p.key].date != null
                  ? DateFormat("dd-MM-yyyy")
                      .format(viewModel.selectedDocuments[p.key].date!)
                  : "N/A",
            ),
            Text(viewModel.selectedDocuments[p.key].language?.name ?? "N/A"),
            Text(
              viewModel.selectedDocuments[p.key].documentName?.isNotEmpty ??
                      false
                  ? viewModel.selectedDocuments[p.key].documentName!
                  : "N/A",
            ),
            CustomTooltip(
              message:
                  viewModel.selectedDocuments[p.key].files?.isNotEmpty ?? false
                      ? viewModel.selectedDocuments[p.key].files!
                          .map((f) => f.name)
                          .join(", ")
                      : "No files",
              child: IconButton(
                onPressed: () {
                  viewModel.downloadViewDocument(
                    viewModel.selectedDocuments[p.key],
                  );
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
          ],
        )
        .toList();
  }
}
