import "package:easy_localization/easy_localization.dart";
import "package:flutter/material.dart";
import "package:flutter/services.dart";
import "package:wcas_frontend/core/components/custom_table/table.dart";
import "package:wcas_frontend/core/components/gap.dart";
import "package:wcas_frontend/core/components/section_header.dart";
import "package:wcas_frontend/core/components/textfield.dart";
import "package:wcas_frontend/core/components/tooltip.dart";
import "package:wcas_frontend/core/constants/constants.dart";
import "package:wcas_frontend/core/utils/dialog_helper.dart";
import "package:wcas_frontend/core/utils/scale.dart";
import "package:wcas_frontend/core/utils/utils.dart";
import "package:wcas_frontend/features/dashboard/closed_requests/model.dart";
import "package:wcas_frontend/features/dashboard/closed_requests/state.dart";
import "package:wcas_frontend/models/request/request.dart";

/// Table widget used to display pending CCSYS worklist tasks.
class WorklistTable extends StatelessWidget {
  /// Creates a [WorklistTable].
  const WorklistTable({
    required this.viewModel,
    required this.state,
    super.key,
  });

  /// View model used to manage closed request worklist data.
  final ClosedRequestsViewModel viewModel;

  /// Current state of the closed requests screen.
  final ClosedRequestsState state;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      spacing: 4,
      children: [
        const CustomSectionHeader(title: "Pending CCSYS Tasks"),
        const Gap(),
        CustomRawTable(
          key: UniqueKey(),
          rowsPerPage: 5,
          isFilterTable: true,
          columns: getColumns(),
          rowModels: _buildRows(context),
        ),
        if (viewModel.filteredWorkList.isEmpty)
          const Center(child: Text("No Data Found")),
      ],
    );
  }

  List<RowModel> _buildRows(BuildContext context) {
    List<RowModel> rowModels = [];
    final filterRow = RowModel(
      color: AppColors.tableHeadingColor,
      isFilterRow: true,
      widget: [
        _filterField(
          viewModel.reqRefNoFilter,
          FilterType.referenceNumber,
          maxLength: 13,
          inputFormatters: [
            FilteringTextInputFormatter.allow(RegExp("[a-zA-Z0-9]")),
          ],
        ),
        const SizedBox(),
        _filterField(
          viewModel.applicantRimFilter,
          FilterType.applicantRim,
          maxLength: 15,
          inputFormatters: [FilteringTextInputFormatter.digitsOnly],
        ),
        _filterField(
          viewModel.applicantNameFilter,
          FilterType.applicantName,
          inputFormatters: [
            FilteringTextInputFormatter.allow(RegExp("[a-zA-Z0-9]")),
          ],
          maxLength: 50,
        ),
        const SizedBox(),
        const SizedBox(),
        const SizedBox(),
        const SizedBox(),
        const SizedBox(),
      ],
    );
    for (int i = 0; i < viewModel.filteredWorkList.length; i++) {
      final Request request = viewModel.filteredWorkList[i];
      if (request.applicationRefNo != null) {
        rowModels.add(
          RowModel(
            isFilterRow: false,
            widget: [
              Row(
                children: [
                  TextButton(
                    onPressed: () => viewModel.openApplication(request, i),
                    child: _cellWidget(
                      request.applicationRefNo.toString(),
                      addUnderline: true,
                    ),
                  ),
                  if (viewModel.state.appRefIndex == i)
                    const SizedBox(
                      width: 14,
                      height: 14,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                      ),
                    ),
                ],
              ),
              CustomTooltip(
                message: request.requestType?.name ?? "",
                child: _rowFields(request.applicationType?.name),
              ),
              CustomTooltip(
                message: request.customerRimNo.toString(),
                child: _rowFields(request.customerRimNo.toString()),
              ),
              CustomTooltip(
                message: request.customerName ?? "",
                child: _rowFields(request.customerName ?? ""),
              ),
              CustomTooltip(
                message: request.requestedBy ?? "",
                child: _rowFields(request.requestedBy ?? ""),
              ),
              CustomTooltip(
                message: request.dateOfCreation ?? "",
                child: _rowFields(request.dateOfCreation ?? ""),
              ),
              CustomTooltip(
                message: request.pendingWith ?? "",
                child: _rowFields(request.pendingWith ?? ""),
              ),
              TextButton(
                style: ButtonStyle(
                  padding: WidgetStateProperty.all(EdgeInsets.zero),
                ),
                onPressed: () => DialogHelper.showCommentContentDialog(
                  context,
                  request.purpose ?? "",
                  "dashboard.advancedSearch.purpose".tr(),
                ),
                child: _cellWidget("View", addUnderline: true),
              ),
              CustomTooltip(
                message: request.status ?? "",
                child: _rowFields(
                  request.status == null
                      ? ""
                      : viewModel.getRequestStatusNameById(
                            request.status ?? "0",
                          ) ??
                          "",
                ),
              ),
            ],
          ),
        );
      }
    }

    rowModels = addFilterForRowModel(
      rows: rowModels,
      filterRow: filterRow,
      rowsPerPage: 5,
    );
    return rowModels.isEmpty ? [filterRow] : rowModels;
  }

  /// Returns the table columns for the worklist table.
  List<TableColumn> getColumns() {
    return [
      TableColumn(
        forcedWidth: 120.w,
        label: Text("dashboard.advancedSearch.requestRefNo".tr()),
      ),
      TableColumn(
        forcedWidth: 80.w,
        label: Text("dashboard.advancedSearch.requestType".tr()),
      ),
      TableColumn(
        forcedWidth: 80.w,
        label: Text("dashboard.advancedSearch.applicantRIM".tr()),
      ),
      TableColumn(
        forcedWidth: 100.w,
        label: Text("dashboard.advancedSearch.applicantName".tr()),
      ),
      TableColumn(label: Text("dashboard.advancedSearch.requestBy".tr())),
      TableColumn(
        forcedWidth: 120.w,
        label: Text("dashboard.advancedSearch.dateofCreation".tr()),
      ),
      TableColumn(
        label: Text("dashboard.advancedSearch.pendingWith".tr()),
      ),
      TableColumn(
        forcedWidth: 40.w,
        label: Text("dashboard.advancedSearch.purpose".tr()),
      ),
      TableColumn(
        label: Text("dashboard.advancedSearch.requestStatus".tr()),
      ),
    ];
  }

  Widget _rowFields(String? text) {
    return Text(
      text ?? "",
      maxLines: 1,
      textAlign: TextAlign.start,
      style: const TextStyle(
        overflow: TextOverflow.ellipsis,
      ),
    );
  }

  Widget _filterField(
    String? text,
    FilterType filterType, {
    int? maxLength,
    List<TextInputFormatter>? inputFormatters,
  }) {
    return CustomTextField(
      initialValue: text,
      fillColor: AppColors.white,
      filled: true,
      maxLength: maxLength,
      inputFormatters: inputFormatters,
      textStyle: const TextStyle(fontSize: 14),
      onSubmitted: (String value) {
        text = value;
        viewModel.onFilterWorklistTable(value: value, filterType: filterType);
      },
    );
  }

  Widget _cellWidget(
    String text, {
    bool overflow = true,
    bool addUnderline = false,
  }) {
    return Text(
      text,
      overflow: overflow ? TextOverflow.ellipsis : null,
      maxLines: overflow ? 1 : null,
      style: TextStyle(
        fontSize: AppStyle.columnName,
        decoration: addUnderline ? TextDecoration.underline : null,
      ),
    );
  }
}

/// Extension that adds distinct-by-key filtering to iterables.
extension DistinctBy<T> on Iterable<T> {
  /// Returns iterable elements distinct by the selected key.
  Iterable<T> distinctBy(String? Function(T) keySelector) {
    final seen = <String?>{};
    return where((element) => seen.add(keySelector(element)));
  }
}
