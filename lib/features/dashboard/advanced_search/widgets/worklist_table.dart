import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:wcas_frontend/core/components/dropdown/multi_select_dropdown.dart';
import 'package:wcas_frontend/core/components/textfield.dart';
import 'package:wcas_frontend/core/components/tooltip.dart';
import 'package:wcas_frontend/core/constants/constants.dart';
import 'package:wcas_frontend/core/utils/scale.dart';
import 'package:wcas_frontend/core/utils/utils.dart';
import 'package:wcas_frontend/features/dashboard/advanced_search/model.dart';

import 'package:wcas_frontend/core/components/custom_table/table.dart';
import 'package:wcas_frontend/features/dashboard/advanced_search/state.dart';
import 'package:wcas_frontend/models/request/request.dart';

class WorklistTable extends StatelessWidget {
  final AdvancedSearchViewModel viewModel;
  final AdvancedSearchState state;
  const WorklistTable(this.viewModel, this.state, {super.key});

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
                rowModels: _buildRows()),
          ],
        );

      default:
        return Container();
    }
  }

  List<RowModel> _buildRows() {
    List<RowModel> rowModels = [];
    var filterRow = RowModel(
        color: AppColors.tableHeadingColor,
        isFilterRow: true,
        widget: [
          _filterField(viewModel.reqRefNoFilter, FilterType.referenceNumber,
              maxLength: 13,
              inputFormatters: [
                FilteringTextInputFormatter.allow(RegExp(r'[a-zA-Z0-9]')),
              ]),
          _filterFieldDropDownRequestStatus(
              viewModel.selectedFilterTypeData, viewModel.workList),
          _filterField(
            viewModel.applicantRimFilter,
            FilterType.applicantRim,
            maxLength: 15,
            inputFormatters: [FilteringTextInputFormatter.digitsOnly],
          ),
          _filterField(viewModel.applicantNameFilter, FilterType.applicantName,
              inputFormatters: [
                FilteringTextInputFormatter.allow(RegExp(r'[a-zA-Z0-9]'))
              ],
              maxLength: 50),
          const SizedBox(),
          const SizedBox(),
          const SizedBox(),
          const SizedBox(),
          const SizedBox(),
        ]);

    //Data rows
    rowModels.add(filterRow);
    for (Request? request in viewModel.filteredWorkList) {
      if (request?.applicationRefNo != null) {
        rowModels.add(RowModel(widget: [
          CustomTooltip(
              message: request?.applicationRefNo.toString() ?? '',
              child: _rowFields(request?.applicationRefNo.toString() ?? '')),
          CustomTooltip(
              message: request?.requestType?.name ?? '',
              child: _rowFields(request?.requestType?.name ?? '')),
          CustomTooltip(
              message: request?.customerRimNo.toString() ?? '',
              child: _rowFields(request?.customerRimNo.toString() ?? '')),
          CustomTooltip(
              message: request?.customerName ?? '',
              child: _rowFields(request?.customerName ?? '')),
          CustomTooltip(
              message: request?.requestedBy ?? '',
              child: _rowFields(request?.requestedBy ?? '')),
          CustomTooltip(
              message: request?.createdDate.toString() ?? '',
              child: _rowFields(request?.createdDate.toString() ?? '')),
          CustomTooltip(
              message: request?.customerRimNo.toString() ?? '',
              child: _rowFields(request?.customerRimNo.toString() ?? '')),
          CustomTooltip(
              message: request?.purpose ?? '',
              child: _rowFields(request?.purpose ?? '')),
          CustomTooltip(
              message: request?.status ?? '',
              child: _rowFields(viewModel.getRequestStatusNameById(
                      int.parse(request?.status ?? "0")) ??
                  '')),
        ], isFilterRow: false));
      }
    }

    rowModels = addFilterForRowModel(
        rows: rowModels, filterRow: filterRow, rowsPerPage: 5);
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

  Widget _filterField(String? text, FilterType filterType,
      {int? maxLength, List<TextInputFormatter>? inputFormatters}) {
    return CustomTextField(
      initialValue: text,
      fillColor: AppColors.white,
      filled: true,
      counterText: '',
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
      List<Request>? selectedRequests, List<Request> requests) {
    return Align(
      alignment: AlignmentDirectional.center,
      child: CustomMultiSelectDropdown<Request>(
        validationMessage: "validation.emptyField".tr(),
        items: requests
            .where((e) => (e.applicationType?.name ?? "").trim().isNotEmpty)
            .distinctBy((e) => e.applicationType?.name?.trim())
            .toList(),
        selectedItems: selectedRequests
            ?.distinctBy((e) => e.applicationType?.name?.trim())
            .toList(),
        onSelected: (selectedValue) {
          viewModel.onFilter(
              filterType: FilterType.referenceType,
              value: "",
              selectedTypes: selectedValue);
        },
        fillColor: AppColors.white,
        dropdownBuilder: (context, data) {
          return dropdownMultiItemBuildScrollWidget(
              data,
              (index) => Chip(
                    materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    labelStyle: const TextStyle(fontSize: AppStyle.columnName),
                    label: Text("${data?[index].applicationType?.name}"),
                  ));
        },
        itemBuilder: (context, item, isDisabled, isSelected) {
          return ListTile(
            dense: true,
            title: Text("${item.applicationType?.name}"),
          );
        },
        isSearchable: true,
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
        forcedWidth: 150.w,
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
        forcedWidth: 100.w,
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
