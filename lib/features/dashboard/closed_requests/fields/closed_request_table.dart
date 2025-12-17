import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:wcas_frontend/core/components/dropdown/multi_select_dropdown.dart';
import 'package:wcas_frontend/core/components/gap.dart';
import 'package:wcas_frontend/core/components/tooltip.dart';
import 'package:wcas_frontend/core/constants/constants.dart';
import 'package:wcas_frontend/core/globals.dart';
import 'package:wcas_frontend/core/services/route_service.dart';
import 'package:wcas_frontend/core/utils/scale.dart';
import 'package:wcas_frontend/features/dashboard/closed_requests/model.dart';
import 'package:wcas_frontend/features/dashboard/closed_requests/state.dart';

import 'package:wcas_frontend/core/components/custom_table/table.dart';
import 'package:wcas_frontend/core/components/section_header.dart';
import 'package:wcas_frontend/core/components/textfield.dart';
import 'package:wcas_frontend/core/utils/utils.dart';
import 'package:wcas_frontend/models/request/request.dart';
import 'package:wcas_frontend/repositories/auth_repository.dart';

class ClosedRequestTable extends StatelessWidget {
  final ClosedRequestsViewModel viewModel;
  final ClosedRequestsState state;
  const ClosedRequestTable(this.viewModel, {super.key, required this.state});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            CustomSectionHeader(title: viewModel.pageHeading),
            const Gap(
              size: GapSize.medium,
              direction: Axis.horizontal,
            ),
            TextButton(
                onPressed: () {
                  router.go(Routes.home);
                },
                child: Text(
                    "<< ${"dashboard.closedRequests.backToRequestStatus".tr()}")),
          ],
        ),
        const Gap(size: GapSize.medium),
        state.tableLoader == LoadingStatus.loading
            ? const Center(child: CircularProgressIndicator())
            : CustomRawTable(
                key: UniqueKey(),
                rowsPerPage: 10,
                showPagination: true,
                isFilterTable: true,
                columns: getColumns(),
                rows: _buildRows(viewModel),
              ),
      ],
    );
  }

  List<List<Widget>> _buildRows(ClosedRequestsViewModel viewModel) {
    List<List<Widget>> rowModels = [];
    final filterRow = <Widget>[
      _filterField(viewModel.reqRefNoFilter, FilterType.referenceNumber),
      _filterFieldDropDown(
          viewModel.requestTypeFilter, viewModel.closedRequests),
      _filterField(viewModel.applicantRimFilter, FilterType.applicantRim),
      _filterField(viewModel.applicantNameFilter, FilterType.applicantName),
      const SizedBox(),
      const SizedBox(),
      const SizedBox(),
      const SizedBox(),
      // _filterFieldDropDownRequestStatus(
      //     viewModel.requestStatusFilter, viewModel.itemsRequestStatusList),
      const SizedBox(),
    ];

    //Data rows
    rowModels.add(filterRow);
    for (Request? request in viewModel.closedRequestFilteredData) {
      if (request?.applicationRefNo != null) {
        rowModels.add([
          TextButton(
            onPressed: () async {
              await AuthRepository.instance
                  .updateRole(Globals.user!.currentRole!, request: request);
              Utils.setRequest(request!);
              router.go(Routes.groupBorrowers);
            },
            child: Text(
              request?.applicationRefNo.toString() ?? '',
              style: const TextStyle(
                fontSize: AppStyle.fontSizeSmall,
                decoration: TextDecoration.underline,
                decorationColor: AppColors.darkBlue,
              ),
            ),
          ),
          //Text(request?.applicationRefNo.toString() ?? ''),
          CustomTooltip(
            message: request?.applicationType?.name ?? '',
            child: Text(request?.applicationType?.name ?? ''),
          ),
          Text(request?.customerRimNo.toString() ?? ''),
          CustomTooltip(
            message: request?.customerName ?? '',
            child: Text(request?.customerName ?? ''),
          ),
          Text(request?.requestedBy ?? ''),
          CustomTooltip(
            message: request?.createdDate.toString() ?? '',
            child: Text(request?.createdDate.toString() ?? ''),
          ),
          CustomTooltip(
            message: request?.purpose ?? '',
            child: Text(request?.purpose ?? ''),
          ),
          Text(request?.status ?? ''),
          CustomTooltip(
            message: request?.terminatedReason ?? '',
            child: Text(request?.terminatedReason ?? ''),
          ),
        ]);
      }
    }
    List<List<Widget>> finalRow =
        addFilter(rows: rowModels, filterRow: filterRow, rowsPerPage: 10);
    return finalRow.isEmpty ? [filterRow] : finalRow;
  }

  Widget _filterField(String? text, FilterType filterType) {
    return Align(
      alignment: AlignmentDirectional.center,
      child: CustomTextField(
        initialValue: text,
        semanticLabel: filterType.name,
        maxLength: 30,
        counterText: '',
        onSubmitted: (String value) {
          viewModel.onFilter(value: value, filterType: filterType);
        },
      ),
    );
  }

  Widget _filterFieldDropDown(
      List<Request>? selectedValue, List<Request> requests) {
    return Align(
      alignment: AlignmentDirectional.center,
      child: CustomMultiSelectDropdown<Request>(
        isFilterField: true,
        validationMessage: "validation.emptyField".tr(),
        dropdownBuilder: (context, data) {
          String? tooltip =
              data?.map((val) => val.applicationType?.name).join(", ");
          return CustomTooltip(
              showTooltip: tooltip != "",
              message: tooltip ?? "",
              child: const Text(""));
        },
        items: requests
            .where((e) => (e.applicationType?.name ?? "").trim().isNotEmpty)
            .distinctBy((e) => e.applicationType?.name?.trim())
            .toList(),
        selectedItems: selectedValue
            ?.distinctBy((e) => e.applicationType?.name?.trim())
            .toList(),
        // selectedItems: text?.name == null ? null : [text!],
        itemBuilder: (context, item, isDisabled, isSelected) {
          return ListTile(
            dense: true,
            title: Text(item.applicationType?.name ?? ""),
          );
        },
        onSelected: (selectedValue) {
          viewModel.onFilter(
              value: "",
              filterType: FilterType.referenceType,
              selectedTypes: selectedValue);
        },
        isSearchable: true,
      ),
    );
  }

  // Widget _filterFieldDropDownRequestStatus(
  //     List<Reference>? selectedRef, List<Reference> requestStatus) {
  //   return Align(
  //     alignment: AlignmentDirectional.center,
  //     child: CustomMultiSelectDropdown<Reference>(
  //       width: 250,
  //       validationMessage: "validation.emptyField".tr(),
  //       items: requestStatus
  //           .where((e) => (e.name ?? "").trim().isNotEmpty)
  //           .distinctBy((e) => e.name?.trim())
  //           .toList(),
  //       semanticLabel: FilterType.referenceType.name,
  //       selectedItems: selectedRef?.distinctBy((e) => e.name?.trim()).toList(),
  //       onSelected: (selectedValue) {
  //         if (selectedValue.isNotEmpty) {
  //           viewModel.onFilter(
  //               filterType: FilterType.referenceType,
  //               value: "",
  //               selectedTypes: selectedValue);
  //         }
  //       },
  //       dropdownBuilder: (context, data) {
  //         String? tooltip = data?.map((val) => val.name).join(", ");
  //         return CustomTooltip(
  //             showTooltip: tooltip != "",
  //             message: tooltip ?? "",
  //             child: const Text(""));
  //       },
  //       itemBuilder: (context, item, isDisabled, isSelected) {
  //         return ListTile(
  //           dense: true,
  //           title: Text(item.name ?? ""),
  //         );
  //       },
  //       isSearchable: true,
  //     ),
  //   );
  // }

  List<TableColumn> getColumns() {
    return [
      TableColumn(
          forcedWidth: 120.w,
          label: Text("dashboard.closedRequests.requestRefNo".tr())),
      TableColumn(
          forcedWidth: 150.w,
          label: Text("dashboard.closedRequests.requestType".tr())),
      TableColumn(
          forcedWidth: 40.w,
          label: Text("dashboard.closedRequests.applicantRIM".tr())),
      TableColumn(
          forcedWidth: 80.w,
          label: Text("dashboard.closedRequests.applicantName".tr())),
      TableColumn(
          forcedWidth: 80.w,
          label: Text("dashboard.closedRequests.requestBy".tr())),
      TableColumn(
          forcedWidth: 120.w,
          label: Text("dashboard.closedRequests.dateofCreation".tr())),
      TableColumn(
          forcedWidth: 120.w,
          label: Text("dashboard.closedRequests.purpose".tr())),
      TableColumn(
          forcedWidth: 100.w,
          label: Text("dashboard.closedRequests.requestStatus".tr())),
      TableColumn(
          forcedWidth: 80.w,
          label: Text("dashboard.closedRequests.reasonforTermination".tr())),
    ];
  }
}

extension DistinctBy<T> on Iterable<T> {
  Iterable<T> distinctBy(String? Function(T) keySelector) {
    final seen = <String?>{};
    return where((element) => seen.add(keySelector(element)));
  }
}
