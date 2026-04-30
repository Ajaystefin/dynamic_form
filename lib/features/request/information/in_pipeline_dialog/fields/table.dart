import "package:easy_localization/easy_localization.dart";
import "package:flutter/material.dart";
import "package:go_router/go_router.dart";
import "package:wcas_frontend/core/components/custom_table/table.dart";
import "package:wcas_frontend/core/components/tooltip.dart";
import "package:wcas_frontend/core/constants/constants.dart";
import "package:wcas_frontend/core/globals.dart";
import "package:wcas_frontend/core/utils/scale.dart";
import "package:wcas_frontend/core/utils/utils.dart";
import "package:wcas_frontend/features/request/information/in_pipeline_dialog/model.dart";
import "package:wcas_frontend/features/request/information/in_pipeline_dialog/state.dart";
import "package:wcas_frontend/models/admin/reference.dart";

class InPipelineTable extends StatelessWidget {
  const InPipelineTable({
    required this.viewModel,
    required this.state,
    super.key,
  });
  final InPipelineDialogViewModel viewModel;
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
              showPagination: true,
              key: UniqueKey(),
              columns: getTableColumns(viewModel),
              rows: List.generate(viewModel.pipelineRequestDetails.length,
                  (index) {
                final info = viewModel.pipelineRequestDetails[index];
                return [
                  TextButton(
                    onPressed: () {
                      if (context.mounted) {
                        Globals.request?.isCreateRequest = false;
                        Globals.request?.applicationRefNo =
                            info.applicationRefNo;

                        final String? requestType = info.requestType;
                        final String? subType = info.subType;

                        if (requestType == null || subType == null) {
                          Globals.request?.applicationType = null;
                          return;
                        }

                        Globals.request?.applicationType =
                            viewModel.applicationType.firstWhere(
                          (item) =>
                              item.reference4 == requestType &&
                              item.reference1 == subType,
                          orElse: () => Reference(
                            name: "",
                            reference1: "",
                            reference4: "",
                          ),
                        );
                        context.push(Routes.requestInformation);
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
