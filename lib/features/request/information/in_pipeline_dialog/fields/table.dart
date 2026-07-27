import "package:easy_localization/easy_localization.dart";
import "package:flutter/material.dart";
// import "package:go_router/go_router.dart";
import "package:wcas_frontend/core/components/custom_table/table.dart";
import "package:wcas_frontend/core/components/tooltip.dart";
import "package:wcas_frontend/core/constants/constants.dart";
import "package:wcas_frontend/core/globals.dart";
import "package:wcas_frontend/core/utils/scale.dart";
import "package:wcas_frontend/core/utils/utils.dart";
import "package:wcas_frontend/features/request/information/in_pipeline_dialog/model.dart";
import "package:wcas_frontend/features/request/information/in_pipeline_dialog/state.dart";

/// Displays the In-Pipeline records table within the
/// In-Pipeline dialog.
///
/// Presents pipeline data and supports user interactions
/// related to viewing and selecting pipeline records.
class InPipelineTable extends StatelessWidget {
  /// Creates an [InPipelineTable].
  const InPipelineTable({
    required this.viewModel,
    required this.state,
    super.key,
  });

  /// View model that manages pipeline data and user actions
  /// within the dialog.
  final InPipelineDialogViewModel viewModel;

  /// Current state of the In-Pipeline dialog.
  final InPipelineDialogState state;

  @override
  Widget build(BuildContext context) {
    switch (state.loaderStatus) {
      case LoadingStatus.loading:
        return const Center(child: CircularProgressIndicator());
      case LoadingStatus.empty:
      case LoadingStatus.error:
        return const Center(child: Text("No Data Found"));
      default:
        return Column(
          children: [
            CustomRawTable(
              rowsPerPage: 8,
              key: UniqueKey(),
              columns: getTableColumns(viewModel),
              rows: List.generate(viewModel.pipelineRequestDetails.length,
                  (index) {
                final info = viewModel.pipelineRequestDetails[index];
                return [
                  TextButton(
                    onPressed: () {
                      if (context.mounted) {
                        viewModel.openApplication(
                          context,
                          info,
                          Globals.request!,
                        );
                      }
                    },
                    child: Text(
                      info.applicationRefNo.toString(),
                      style: const TextStyle(
                        decoration: TextDecoration.underline,
                        fontSize: AppStyle.columnName,
                        decorationColor: AppColors.darkBlue,
                      ),
                    ),
                  ),
                  Center(
                    child: Text(
                      DateFormat("dd/MM/yyyy").format(
                        DateTime.parse(
                          info.creditAppDate.toString(),
                        ),
                      ),
                    ),
                  ),
                  Text(info.requestType.toString()),
                  Text(
                    info.purpose
                        .toString()
                        .replaceAll(RegExp("<[^>]*>"), "") // Remove HTML tags
                        .replaceAll("&nbsp;", " ") // Handle non-breaking spaces
                        .replaceAll(
                          "\u00A0",
                          " ",
                        ) // Replace non-breaking spaces
                        .trim(),
                  ),
                  CustomTooltip(
                    message: info.status ?? "",
                    child: Text(
                      info.status == null ? "" : info.status.toString(),
                      textAlign: TextAlign.start,
                      overflow: TextOverflow.ellipsis,
                      maxLines: 1,
                    ),
                  ),
                ];
              }),
            ),
            if (viewModel.pipelineRequestDetails.isEmpty)
              const Text("No Data Found"),
          ],
        );
    }
  }

  /// Builds the column configuration for the In-Pipeline table.
  ///
  /// Returns the list of columns used to display application
  /// reference details, CA date, request type, purpose, and
  /// current status within the In-Pipeline dialog.
  List<TableColumn> getTableColumns(InPipelineDialogViewModel viewModel) {
    return [
      TableColumn(
        forcedWidth: 130.w,
        label: Text("requestInformation.pipelineDialog.applicationRefNo".tr()),
      ),
      TableColumn(
        forcedWidth: 80.w,
        label: Text("requestInformation.pipelineDialog.caDate".tr()),
      ),
      TableColumn(
        label: Text("requestInformation.pipelineDialog.requestType".tr()),
      ),
      TableColumn(
        forcedWidth: 80.w,
        label: Text("requestInformation.pipelineDialog.purpose".tr()),
      ),
      TableColumn(
        forcedWidth: 130.w,
        label: Text("requestInformation.pipelineDialog.status".tr()),
      ),
    ];
  }
}
