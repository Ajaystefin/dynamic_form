import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:wcas_frontend/core/components/custom_table/table.dart';
import 'package:wcas_frontend/core/components/dropdown/multi_select_dropdown.dart';
import 'package:wcas_frontend/core/components/gap.dart';
import 'package:wcas_frontend/core/components/section_header.dart';
import 'package:wcas_frontend/core/components/textfield.dart';
import 'package:wcas_frontend/core/components/tooltip.dart';
import 'package:wcas_frontend/core/constants/constants.dart';
import 'package:wcas_frontend/core/utils/scale.dart';
import 'package:wcas_frontend/core/utils/utils.dart';
import 'package:wcas_frontend/features/dashboard/home/model.dart';
import 'package:wcas_frontend/features/dashboard/home/state.dart';
import 'package:wcas_frontend/models/request/request.dart';

class DraftTable extends StatelessWidget {
  final HomeViewModel viewModel;
  final HomeState state;
  const DraftTable(this.viewModel, {super.key, required this.state});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Gap(),
        CustomSectionHeader(
            title: viewModel
                .getSummaryText(viewModel.selectedSummary ?? SummaryType.na)),
        const Gap(
          size: GapSize.large,
        ),
        state.tableLoader == LoadingStatus.loading
            ? const Center(child: CircularProgressIndicator())
            : Column(
                children: [
                  CustomRawTable(
                    key: UniqueKey(),
                    rowsPerPage: viewModel.rowsPerPage,
                    isFilterTable: true,
                    autoFitWidth: true,
                    initialPage: viewModel.workListPageNo,
                    onPageChange: (int pageNo) {
                      viewModel.workListPageNo = pageNo;
                    },
                    showPagination: true,
                    rowHeight: 50,
                    columns: [
                      TableColumn(
                          forcedWidth: 130.w,
                          label:
                              _cellWidget("dashboard.home.requestRefNo".tr())),
                      TableColumn(
                          forcedWidth: 140.w,
                          label:
                              _cellWidget("dashboard.home.requestType".tr())),
                      TableColumn(
                          label:
                              _cellWidget("dashboard.home.applicantRIM".tr())),
                      TableColumn(
                          label:
                              _cellWidget("dashboard.home.applicantName".tr())),
                      TableColumn(
                          label: _cellWidget("dashboard.home.requestBy".tr())),
                      TableColumn(
                          label:
                              _cellWidget("dashboard.home.filter.ageing".tr())),
                      if (Utils.checkRoles([
                        UserRole.inquiryUser,
                        UserRole.admin,
                        UserRole.businessAdmin
                      ])) ...[
                        TableColumn(
                            label: _cellWidget(
                                "dashboard.home.pendingSince".tr())),
                        TableColumn(
                            label:
                                _cellWidget("dashboard.home.pendingWith".tr())),
                        TableColumn(
                            forcedWidth: 130.w,
                            label: _cellWidget("dashboard.home.purpose".tr())),
                        TableColumn(
                            label: _cellWidget(
                                "dashboard.home.businessSegment".tr())),
                        TableColumn(
                            label: _cellWidget(
                                "dashboard.home.requestStatus".tr())),
                      ],
                      if (!Utils.checkRoles([
                        UserRole.inquiryUser,
                        UserRole.admin,
                        UserRole.businessAdmin
                      ])) ...[
                        TableColumn(
                            label: _cellWidget(
                                "dashboard.home.dateofCreation".tr())),
                        TableColumn(
                            forcedWidth: 130.w,
                            label: _cellWidget("dashboard.home.purpose".tr())),
                        TableColumn(
                            label: _cellWidget(
                                "dashboard.home.businessSegment".tr())),
                        TableColumn(
                            label: _cellWidget(
                                "dashboard.home.requestStatus".tr())),
                      ],
                      if (Utils.checkRoles([
                        UserRole.admin,
                        UserRole.businessAdmin,
                        UserRole.creditCordinator
                      ]))
                        TableColumn(
                            label: _cellWidget("dashboard.home.action".tr())),
                    ],
                    rowModels: _buildRows(context, viewModel),
                  ),
                  if (viewModel.filteredRequests.isEmpty)
                    const Text("No Data Found"),
                ],
              ),
        const Gap(),
      ],
    );
  }

  List<RowModel> _buildRows(BuildContext context, HomeViewModel viewModel) {
    List<RowModel> rowModels = [];
    var filterRow = RowModel(
        isFilterRow: true,
        color: AppColors.tableHeadingColor,
        widget: [
          _filterField(viewModel.reqRefNoFilter, FilterType.referenceNumber,
              maxLength: 30,
              inputFormatters: [
                FilteringTextInputFormatter.allow(RegExp(r'[a-zA-Z0-9]')),
              ]),
          _filterFieldDropDownRequestStatus(
              viewModel.requestTypeFilter, viewModel.worklistData),
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
          const SizedBox(), // for ageing
          if (Utils.checkRoles(
              [UserRole.inquiryUser, UserRole.admin, UserRole.businessAdmin]))
            const SizedBox(),
          if (Utils.checkRoles([
            UserRole.admin,
            UserRole.businessAdmin,
            UserRole.creditCordinator
          ]))
            const SizedBox(),
        ]);
    for (int i = 0; i < viewModel.filteredRequests.length; i++) {
      Request? request = viewModel.filteredRequests[i];
      if (request?.applicationRefNo != null) {
        rowModels.add(RowModel(
            isFilterRow: false,
            widget: [
              Row(
                children: [
                  TextButton(
                      onPressed: () => viewModel.openApplication(request!, i),
                      child: _cellWidget(
                          request?.applicationRefNo.toString() ?? '',
                          addUnderline: true,
                          businessSegment: request?.businessSegmentEnum)),
                  if (viewModel.state.appRefIndex == i)
                    const SizedBox(
                        width: 14,
                        height: 14,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                        )),
                ],
              ),
              CustomTooltip(
                  message: "${request?.applicationType?.name}",
                  child: _cellWidget(request?.applicationType?.name ?? '',
                      businessSegment: request?.businessSegmentEnum)),
              _cellWidget(request?.customerRimNo.toString() ?? '',
                  businessSegment: request?.businessSegmentEnum),
              _cellWidget(request?.customerName ?? '',
                  businessSegment: request?.businessSegmentEnum),
              _cellWidget(request?.requestedBy ?? '',
                  businessSegment: request?.businessSegmentEnum),
              _cellWidget(request?.ageing ?? '',
                  businessSegment: request
                      ?.businessSegmentEnum), //replace with actual value for Ageiing once API is fixed
              _cellWidget(request?.dateOfCreation ?? "",
                  businessSegment: request?.businessSegmentEnum),
              if (Utils.checkRoles([
                UserRole.inquiryUser,
                UserRole.admin,
                UserRole.businessAdmin
              ]))
                _cellWidget('', businessSegment: request?.businessSegmentEnum),
              CustomTooltip(
                message: request?.purpose ?? "",
                child: _cellWidget(request?.purpose ?? "",
                    overflow: true,
                    businessSegment: request?.businessSegmentEnum),
              ),
              _cellWidget(request?.businessSegment?.name ?? '',
                  businessSegment: request?.businessSegmentEnum),
              _cellWidget(request?.status ?? '',
                  businessSegment: request?.businessSegmentEnum),
              if (Utils.checkRoles([
                UserRole.admin,
                UserRole.businessAdmin,
                UserRole.creditCordinator
              ]))
                TextButton(
                    onPressed: () => viewModel.onActionClicked(context),
                    child: _cellWidget("dashboard.home.assign".tr(),
                        overflow: false,
                        addUnderline: true,
                        businessSegment: request?.businessSegmentEnum)),
            ],
            color: viewModel.getTableColor(request?.businessSegmentEnum)));
      }
    }
    rowModels = addFilterForRowModel(
        rows: rowModels,
        filterRow: filterRow,
        rowsPerPage: viewModel.rowsPerPage);
    return rowModels.isEmpty ? [filterRow] : rowModels;
  }

  Widget _cellWidget(String text,
      {bool overflow = true,
      bool addUnderline = false,
      BusinessSegment? businessSegment}) {
    return Text(
      text,
      overflow: overflow ? TextOverflow.ellipsis : null,
      maxLines: overflow ? 1 : null,
      style: TextStyle(
        fontSize: AppStyle.columnName,
        color: viewModel.showWorkListColors &&
                businessSegment != null &&
                !(businessSegment == BusinessSegment.financialInstitution ||
                    businessSegment == BusinessSegment.na)
            ? AppColors.white
            : AppColors.black,
        decoration: addUnderline ? TextDecoration.underline : null,
      ),
    );
  }

  Widget _filterField(String? text, FilterType filterType,
      {int? maxLength, List<TextInputFormatter>? inputFormatters}) {
    return Row(
      children: [
        Expanded(
          child: CustomTextField(
            // width: 80.w,
            semanticLabel: filterType.name,
            initialValue: text,
            maxLength: maxLength,
            fillColor: AppColors.white,
            filled: true,
            counterText: '',
            inputFormatters: inputFormatters,
            textStyle: const TextStyle(fontSize: 13),
            onSubmitted: (String value) {
              viewModel.onFilter(value: value, filterType: filterType);
            },
          ),
        ),
      ],
    );
  }

  Widget _filterFieldDropDownRequestStatus(
      List<Request>? selectedRequests, List<Request> requests) {
    return Align(
      alignment: AlignmentDirectional.center,
      child: CustomMultiSelectDropdown<Request>(
        isFilterField: true,
        validationMessage: "validation.emptyField".tr(),
        semanticLabel: FilterType.referenceType.name,
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
          String? tooltip =
              data?.map((val) => val.applicationType?.name).join(", ");
          return CustomTooltip(
              showTooltip: tooltip != "",
              message: tooltip ?? "",
              child: const Text(""));
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
}

extension DistinctBy<T> on Iterable<T> {
  Iterable<T> distinctBy(String? Function(T) keySelector) {
    final seen = <String?>{};
    return where((element) => seen.add(keySelector(element)));
  }
}
