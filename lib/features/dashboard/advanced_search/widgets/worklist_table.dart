import "package:easy_localization/easy_localization.dart";
import "package:flutter/material.dart";
import "package:flutter/services.dart";
import "package:wcas_frontend/core/components/custom_table/table.dart";
import "package:wcas_frontend/core/components/dropdown/multi_select_dropdown.dart";
import "package:wcas_frontend/core/components/textfield.dart";
import "package:wcas_frontend/core/components/tooltip.dart";
import "package:wcas_frontend/core/constants/constants.dart";
import "package:wcas_frontend/core/utils/dialog_helper.dart";
import "package:wcas_frontend/core/utils/scale.dart";
import "package:wcas_frontend/core/utils/utils.dart";
import "package:wcas_frontend/features/dashboard/advanced_search/model.dart";
import "package:wcas_frontend/features/dashboard/advanced_search/state.dart";
import "package:wcas_frontend/models/admin/reference.dart";
import "package:wcas_frontend/models/request/request.dart";

class WorklistTable extends StatelessWidget {
  const WorklistTable(this.viewModel, this.state, {super.key});
  final AdvancedSearchViewModel viewModel;
  final AdvancedSearchState state;

  @override
  Widget build(BuildContext context) {
    switch (state.tableloader) {
      case LoadingStatus.loading:
        return const Center(child: CircularProgressIndicator());
      case LoadingStatus.loaded:
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          spacing: 4,
          children: [
            CustomRawTable(
              key: UniqueKey(),
              rowsPerPage: 5,
              isFilterTable: true,
              showPagination: true,
              columns: getColumns(),
              rowModels: _buildRows(context),
            ),
          ],
        );

      default:
        return Container();
    }
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
        _filterFieldDropDownRequestStatus(
          viewModel.selectedFilterTypeData,
          viewModel.workList,
        ),
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
                      businessSegment: request.businessSegmentEnum,
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
                message: request.reqRefType?.name ?? "",
                child: _rowFields(request.reqRefType?.name),
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
                message: (request.createdDate ?? "").toString(),
                child: _rowFields((request.createdDate ?? "").toString()),
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
                  viewModel.getRequestStatusNameById(request.status) ?? "",
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
      counterText: "",
      maxLength: maxLength,
      inputFormatters: inputFormatters,
      textStyle: const TextStyle(fontSize: 14),
      onSubmitted: (String value) {
        text = value;
        viewModel.onFilter(value: value, filterType: filterType);
      },
    );
  }

  Widget _filterFieldDropDownRequestStatus(
    List<Request>? selectedRequests,
    List<Request> requests,
  ) {
    final List<String> customNames = viewModel.customApplicationTypeNames;

    // Split into current (custom) types and check if any historical ones exist
    final List<Request> customItems = requests
        .where((Request e) {
          final String name = (e.reqRefType?.name ?? "").trim();
          return name.isNotEmpty && customNames.contains(name);
        })
        .distinctBy((Request e) => e.reqRefType?.name?.trim())
        .toList();

    final bool hasHistoricalItems = requests.any((Request e) {
      final String name = (e.reqRefType?.name ?? "").trim();
      return name.isNotEmpty && !customNames.contains(name);
    });

    return Align(
      alignment: AlignmentDirectional.center,
      child: CustomMultiSelectDropdown<Request>(
        isFilterField: true,
        validationMessage: "validation.emptyField".tr(),
        semanticLabel: FilterType.referenceType.name,
        items: [
          ...customItems,
          if (hasHistoricalItems)
            Request()
              ..reqRefType = Reference(
                name: "dashboard.home.historicalApplicationTypes".tr(),
              ),
        ],
        // Dedupe the stored filter by name — the sentinel is already in the
        // list if selected
        selectedItems: selectedRequests
            ?.distinctBy((Request e) => e.reqRefType?.name?.trim())
            .toList(),
        onSelected: (selectedValue) {
          viewModel.onFilter(
            filterType: FilterType.applicationType,
            value: "",
            selectedTypes: selectedValue,
          );
        },
        fillColor: AppColors.white,
        dropdownBuilder: (context, data) {
          final String? tooltip =
              data?.map((val) => val.reqRefType?.name).join(", ");
          return CustomTooltip(
            showTooltip: tooltip != "",
            message: tooltip ?? "",
            child: const Text(""),
          );
        },
        itemBuilder: (context, item, isDisabled, isSelected) {
          return ListTile(
            dense: true,
            title: Text("${item.reqRefType?.name}"),
          );
        },
        compareFn: (item1, item2) =>
            item1.reqRefType?.name == item2.reqRefType?.name,
        filterFn: (Request item, String filter) {
          return (item.reqRefType?.name ?? "")
              .toLowerCase()
              .contains(filter.toLowerCase());
        },
        isSearchable: true,
      ),
    );
  }

  Widget _cellWidget(
    String text, {
    bool overflow = true,
    bool addUnderline = false,
    BusinessSegment? businessSegment,
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
        forcedWidth: 80.w,
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
}

extension DistinctBy<T> on Iterable<T> {
  Iterable<T> distinctBy(String? Function(T) keySelector) {
    final seen = <String?>{};
    return where((element) => seen.add(keySelector(element)));
  }
}
