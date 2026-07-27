// lib/features/request/file_attachment_digital_efiling/appendix/widgets/selected_files_list.dart

import "package:easy_localization/easy_localization.dart";
import "package:file_picker/file_picker.dart";
import "package:flutter/material.dart";
import "package:flutter_bloc/flutter_bloc.dart";
import "package:wcas_frontend/core/components/custom_table/table.dart";
import "package:wcas_frontend/core/components/gap.dart";
import "package:wcas_frontend/core/components/icon_button.dart";
import "package:wcas_frontend/core/constants/constants.dart";
import "package:wcas_frontend/core/utils/scale.dart";
// ViewModel (exposed from your feature)
import "package:wcas_frontend/features/request/file_attachment_digital_efiling/appendix/model.dart"
    show AppendixViewModel;
import "package:wcas_frontend/models/request/file_attachment/appendix.dart"
    show FiAppendixXlsxRow;

/// SelectedFilesList stateless widget
class SelectedFilesList extends StatelessWidget {
  /// Creates [SelectedFilesList] instance

  const SelectedFilesList({
    required this.viewModel,
    required this.files,
    super.key,
    this.onRemove,
    this.onPreview,
  });

  /// AppendixViewModel view model to handle actions
  final AppendixViewModel viewModel; // passed-in VM instance
  /// List of PlatformFile
  final List<PlatformFile> files;

  /// onRemove callback function
  final void Function(int index)? onRemove;

  /// onPreview callback function
  final void Function(int index)? onPreview;

  @override
  Widget build(BuildContext context) {
    //Listen so the table rebuilds when fiServerRows changes
    final AppendixViewModel viewModelWatched =
        context.watch<AppendixViewModel>();

    // Local files
    final List<PlatformFile> localFiles = files;
    final bool hasLocalFiles = localFiles.isNotEmpty;

    // Server-fetched Excel rows
    final List<FiAppendixXlsxRow> serverRows = viewModelWatched.fiServerRows;
    final bool hasServerRows = serverRows.isNotEmpty;

    // Local files win; use server rows only when no local files exist
    final bool showServerRows = !hasLocalFiles && hasServerRows;

    if (!hasLocalFiles && !hasServerRows) {
      return const SizedBox.shrink(); // <–– Hides the table completely
    }

    return Column(
      children: [
        const Gap(),
        CustomRawTable(
          // Force re-render when counts change (helps Flutter Web)
          key: ValueKey(
            "server:${serverRows.length}_local:${localFiles.length}",
          ),
          rowHeight: 48,
          autoFitWidth: false,
          columnHeaderHeight: 30.w,
          columns: showServerRows ? _excelColumns() : _localColumns(),
          rows: showServerRows
              ? _excelRows(context, viewModelWatched)
              : _localRows(context, localFiles),
        ),
        const Gap(),
      ],
    );
  }

  // ---------------------------------------------------------------------------
  // LOCAL FILES TABLE
  // ---------------------------------------------------------------------------

  List<TableColumn> _localColumns() {
    return [
      TableColumn(
        width: 25.w,
        label: Text("eDigitalFilingFileAttachments.fileAttachments.sr".tr()),
      ),
      TableColumn(
        width: 575.w,
        label: Text("admin.fileAccess.fileName".tr()),
      ),
      TableColumn(
        forcedWidth: 100.w,
        label: Text("eDigitalFilingFileAttachments.fileAttachments.file".tr()),
      ),
      TableColumn(
        forcedWidth: 50.w,
        label:
            Text("eDigitalFilingFileAttachments.fileAttachments.delete".tr()),
      ),
    ];
  }

  List<List<Widget>> _localRows(
    BuildContext context,
    List<PlatformFile> files,
  ) {
    return files.asMap().entries.map((entry) {
      final int index = entry.key;
      final PlatformFile file = entry.value;

      final String fileName = file.name.trim().isNotEmpty
          ? file.name.trim()
          : viewModel.basename(file.name);

      return [
        Text("${index + 1}"),
        Tooltip(
          message: fileName,
          child: Align(
            alignment: Alignment.centerLeft,
            child: Text(fileName, overflow: TextOverflow.ellipsis),
          ),
        ),
        Center(
          child: IconButton(
            icon: const Icon(Icons.insert_drive_file),
            onPressed: () {
              if (onPreview != null) {
                onPreview!(index);
              } else {
                viewModel.onPreviewSelectedFile(
                  index: index,
                  files: files,
                  context: context,
                );
              }
            },
          ),
        ),
        Center(
          child: dynamicIcon(
            icon: Icons.delete,
            iconColor: AppColors.buttonBackground,
            onTap: () async {
              await viewModel.removeFromRenderedList(files, index);
            },
          ),
        ),
      ];
    }).toList();
  }

  // ---------------------------------------------------------------------------
  // SERVER (EXCEL) TABLE
  // ---------------------------------------------------------------------------

  List<TableColumn> _excelColumns() {
    return [
      TableColumn(
        width: 120.w,
        label: Text("ccsys.customerInformation.rimNo".tr()),
      ),
      TableColumn(
        width: 180.w,
        label: Text("dashboard.home.applicationRefNo".tr()),
      ),
      TableColumn(
        width: 260.w,
        label: Text("admin.fileAccess.fileName".tr()),
      ),
      TableColumn(
        forcedWidth: 60.w,
        label:
            Text("eDigitalFilingFileAttachments.fileAttachments.delete".tr()),
      ),
    ];
  }

  List<List<Widget>> _excelRows(
    BuildContext context,
    AppendixViewModel viewModelWatched,
  ) {
    final rows = viewModelWatched.fiServerRows;

    return rows.map((row) {
      final String fileName = viewModelWatched.fileNamesToText(row.fileNames);
      final bool canDelete =
          row.appendixXlsxId != null && row.appendixXlsxId! > 0;

      return [
        Text("${row.rimNo}"), // CORRECT
        Text(row.appRefNo),
        Text(fileName),
        Center(
          child: dynamicIcon(
            icon: Icons.delete,
            iconColor:
                canDelete ? AppColors.buttonBackground : AppColors.darkGrey,
            onTap: canDelete
                ? () async =>
                    viewModelWatched.deleteFiServerRow(row.appendixXlsxId)
                : null,
          ),
        ),
      ];
    }).toList();
  }
}
