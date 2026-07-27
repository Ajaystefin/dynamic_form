import "package:easy_localization/easy_localization.dart";
import "package:flutter/material.dart";
import "package:wcas_frontend/core/components/custom_table/table.dart";
import "package:wcas_frontend/core/components/dropdown/multi_select_dropdown.dart";
import "package:wcas_frontend/core/components/gap.dart";
import "package:wcas_frontend/core/components/section_header.dart";
import "package:wcas_frontend/core/components/textfield.dart";
import "package:wcas_frontend/core/components/tooltip.dart";
import "package:wcas_frontend/core/constants/constants.dart";
// import "package:wcas_frontend/core/globals.dart";
// import "package:wcas_frontend/core/services/route_service.dart";
import "package:wcas_frontend/core/utils/dialog_helper.dart";
import "package:wcas_frontend/core/utils/scale.dart";
import "package:wcas_frontend/core/utils/utils.dart";
import "package:wcas_frontend/features/dashboard/closed_requests/model.dart";
import "package:wcas_frontend/features/dashboard/closed_requests/state.dart";
import "package:wcas_frontend/models/admin/reference.dart";
import "package:wcas_frontend/models/request/request.dart";
// import "package:wcas_frontend/repositories/auth_repository.dart";

/// Table widget used to display closed request records.
class ClosedRequestTable extends StatelessWidget {
  /// Creates a [ClosedRequestTable].
  const ClosedRequestTable(this.viewModel, {required this.state, super.key});

  /// View model used to manage closed request data.
  final ClosedRequestsViewModel viewModel;

  /// Current state of the closed requests screen.
  final ClosedRequestsState state;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            CustomSectionHeader(title: viewModel.pageHeading),
            const Gap(
              direction: Axis.horizontal,
            ),
            // TextButton(
            //     onPressed: () {
            //       router.go(Routes.home);
            //     },
            //     child: Text(
            //         "<<
            // ${"dashboard.closedRequests.backToRequestStatus".tr()}")),
          ],
        ),
        const Gap(),
        if (state.tableLoader == LoadingStatus.loading)
          const Center(child: CircularProgressIndicator())
        else
          CustomRawTable(
            key: UniqueKey(),
            rowsPerPage: 10,
            isFilterTable: true,
            columns: getColumns(),
            rowModels: _buildRows(context, viewModel),
          ),
        if (viewModel.closedRequests.isEmpty)
          const Center(child: Text("No Data Found")),
      ],
    );
  }

  List<RowModel> _buildRows(
    BuildContext context,
    ClosedRequestsViewModel viewModel,
  ) {
    final List<RowModel> rowModels = [];
    final filterRow = RowModel(
      widget: <Widget>[
        _filterField(viewModel.reqRefNoFilter, FilterType.referenceNumber),
        _filterFieldDropDown(
          viewModel.requestTypeFilter,
          viewModel.closedRequests,
        ),
        _filterField(viewModel.applicantRimFilter, FilterType.applicantRim),
        _filterField(viewModel.applicantNameFilter, FilterType.applicantName),
        _filterField(viewModel.requestedByFilter, FilterType.requestBy),
        const SizedBox(),
        const SizedBox(),
        // const SizedBox(),
        // const SizedBox(),
        _filterFieldDropDownRequestStatus(
          viewModel.reqStatusFilter,
          viewModel.closedRequests,
        ),
        const SizedBox(),
      ],
      isFilterRow: true,
    );

    //Data rows
    // rowModels.add(filterRow);
    for (final Request? request in viewModel.closedRequestFilteredData) {
      if (request?.applicationRefNo != null) {
        rowModels.add(
          RowModel(
            widget: [
              TextButton(
                onPressed: () async {
                  // await AuthRepository.instance
                  //     .updateRole(Globals.user!.currentRole!, request: request);
                  Utils.request = request!;
                  // router.go(Routes.groupBorrowers);
                  await viewModel.openApplication(request, 0);
                },
                child: Text(
                  request?.applicationRefNo.toString() ?? "",
                  style: const TextStyle(
                    fontSize: AppStyle.fontSizeSmall,
                    decoration: TextDecoration.underline,
                    decorationColor: AppColors.darkBlue,
                  ),
                ),
              ),
              CustomTooltip(
                message: request?.requestSubType?.name ?? "",
                child: _rowFields(request?.requestSubType?.name ?? ""),
              ),
              _rowFields(request?.customerRimNo.toString() ?? ""),
              CustomTooltip(
                message: request?.customerName ?? "",
                child: _rowFields(request?.customerName ?? ""),
              ),
              CustomTooltip(
                message: request?.requestedBy ?? "",
                child: _rowFields(request?.requestedBy ?? ""),
              ),
              CustomTooltip(
                message: request?.dateOfCreation ?? "",
                child: _rowFields(request?.dateOfCreation ?? ""),
              ),
              TextButton(
                style: ButtonStyle(
                  padding: WidgetStateProperty.all(EdgeInsets.zero),
                ),
                onPressed: () => DialogHelper.showCommentContentDialog(
                  context,
                  request?.purpose ?? "",
                  "dashboard.closedRequests.purpose".tr(),
                ),
                child: const Text(
                  "View",
                  style: TextStyle(
                    fontSize: AppStyle.fontSizeSmall,
                    color: AppColors.black,
                    decoration: TextDecoration.underline,
                  ),
                ),
              ),
              _rowFields(request?.status ?? ""),
              CustomTooltip(
                message: request?.terminatedReason ?? "",
                child: _rowFields(request?.terminatedReason ?? ""),
              ),
            ],
            isFilterRow: false,
          ),
        );
      }
    }
    final List<RowModel> finalRow = addFilterForRowModel(
      rows: rowModels,
      filterRow: filterRow,
      rowsPerPage: 10,
    );
    return finalRow.isEmpty ? [filterRow] : finalRow;
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

  Widget _filterField(String? text, FilterType filterType) {
    return Align(
      alignment: AlignmentDirectional.center,
      child: CustomTextField(
        initialValue: text,
        semanticLabel: filterType.name,
        maxLength: 30,
        onSubmitted: (String value) {
          viewModel.onFilter(value: value, filterType: filterType);
        },
      ),
    );
  }

  Widget _filterFieldDropDown(
    List<Request>? selectedValue,
    List<Request> requests,
  ) {
    final List<String> customNames = viewModel.customApplicationTypeNames;

    // Split into current (custom) types and check if any historical ones exist
    final List<Request> customItems = requests
        .where((Request e) {
          final String name = (e.requestSubType?.name ?? "").trim();
          return name.isNotEmpty && customNames.contains(name);
        })
        .distinctBy((Request e) => e.requestSubType?.name?.trim())
        .toList();

    final bool hasHistoricalItems = requests.any((Request e) {
      final String name = (e.requestSubType?.name ?? "").trim();
      return name.isNotEmpty && !customNames.contains(name);
    });

    return Align(
      alignment: AlignmentDirectional.center,
      child: CustomMultiSelectDropdown<Request>(
        isFilterField: true,
        validationMessage: "validation.emptyField".tr(),
        dropdownBuilder: (context, data) {
          final String? tooltip =
              data?.map((val) => val.requestSubType?.name).join(", ");
          return CustomTooltip(
            showTooltip: tooltip != "",
            message: tooltip ?? "",
            child: const Text(""),
          );
        },
        items: [
          ...customItems,
          if (hasHistoricalItems)
            Request()
              ..requestSubType = Reference(
                name: "dashboard.home.historicalApplicationTypes".tr(),
              ),
        ],
        // Dedupe the stored filter by name — the sentinel is already in the
        // list if selected
        selectedItems: selectedValue
            ?.distinctBy((Request e) => e.requestSubType?.name?.trim())
            .toList(),
        itemBuilder: (context, item, {isDisabled, isSelected}) {
          return ListTile(
            dense: true,
            title: Text(item.requestSubType?.name ?? ""),
          );
        },
        onSelected: (selectedValue) {
          viewModel.onFilter(
            value: "",
            filterType: FilterType.requestType,
            selectedTypes: selectedValue,
          );
        },
        compareFn: (item1, item2) =>
            item1.requestSubType?.name == item2.requestSubType?.name,
        filterFn: (Request item, String filter) {
          return (item.requestSubType?.name ?? "")
              .toLowerCase()
              .contains(filter.toLowerCase());
        },
        isSearchable: true,
      ),
    );
  }

  Widget _filterFieldDropDownRequestStatus(
    List<Request>? selectedValue,
    List<Request> requests,
  ) {
    return Align(
      alignment: AlignmentDirectional.center,
      child: CustomMultiSelectDropdown<Request>(
        isFilterField: true,
        validationMessage: "validation.emptyField".tr(),
        dropdownBuilder: (context, data) {
          final String? tooltip =
              data?.map((val) => val.requestStatus?.name).join(", ");
          return CustomTooltip(
            showTooltip: tooltip != "",
            message: tooltip ?? "",
            child: const Text(""),
          );
        },
        items: requests
            .where((e) => (e.requestStatus?.name ?? "").trim().isNotEmpty)
            .distinctBy((e) => e.requestStatus?.name?.trim())
            .toList(),
        selectedItems: selectedValue
            ?.distinctBy((e) => e.requestStatus?.name?.trim())
            .toList(),
        // selectedItems: text?.name == null ? null : [text!],
        itemBuilder: (context, item, {isDisabled, isSelected}) {
          return ListTile(
            dense: true,
            title: Text(item.requestStatus?.name ?? ""),
          );
        },
        onSelected: (selectedValue) {
          viewModel.onFilter(
            value: "",
            filterType: FilterType.requestStatus,
            selectedTypes: selectedValue,
          );
        },
        compareFn: (item1, item2) =>
            item1.requestStatus?.name == item2.requestStatus?.name,
        filterFn: (Request item, String filter) {
          return (item.requestStatus?.name ?? item.toString())
              .toLowerCase()
              .contains(filter.toLowerCase());
        },
        isSearchable: true,
      ),
    );
  }

  /// Returns the table columns for the closed request table.
  List<TableColumn> getColumns() {
    return [
      TableColumn(
        forcedWidth: 120.w,
        label: Text("dashboard.closedRequests.requestRefNo".tr()),
      ),
      TableColumn(
        forcedWidth: 150.w,
        label: Text("dashboard.closedRequests.requestType".tr()),
      ),
      TableColumn(
        forcedWidth: 40.w,
        label: Text("dashboard.closedRequests.applicantRIM".tr()),
      ),
      TableColumn(
        forcedWidth: 80.w,
        label: Text("dashboard.closedRequests.applicantName".tr()),
      ),
      TableColumn(
        forcedWidth: 80.w,
        label: Text("dashboard.closedRequests.requestBy".tr()),
      ),
      TableColumn(
        forcedWidth: 120.w,
        label: Text("dashboard.closedRequests.dateofCreation".tr()),
      ),
      TableColumn(
        forcedWidth: 40.w,
        label: Text("dashboard.closedRequests.purpose".tr()),
      ),
      TableColumn(
        forcedWidth: 100.w,
        label: Text("dashboard.closedRequests.requestStatus".tr()),
      ),
      TableColumn(
        forcedWidth: 80.w,
        label: Text("dashboard.closedRequests.reasonforTermination".tr()),
      ),
    ];
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
