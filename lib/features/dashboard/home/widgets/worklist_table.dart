import "package:easy_localization/easy_localization.dart";
import "package:flutter/material.dart";
import "package:flutter/services.dart";
import "package:wcas_frontend/core/components/custom_table/table.dart";
import "package:wcas_frontend/core/components/dropdown/multi_select_dropdown.dart";
import "package:wcas_frontend/core/components/gap.dart";
import "package:wcas_frontend/core/components/section_header.dart";
import "package:wcas_frontend/core/components/textfield.dart";
import "package:wcas_frontend/core/components/tooltip.dart";
import "package:wcas_frontend/core/constants/constants.dart";
import "package:wcas_frontend/core/utils/dialog_helper.dart";
import "package:wcas_frontend/core/utils/scale.dart";
import "package:wcas_frontend/core/utils/utils.dart";
import "package:wcas_frontend/features/dashboard/home/model.dart";
import "package:wcas_frontend/features/dashboard/home/state.dart";
import "package:wcas_frontend/models/admin/reference.dart";
import "package:wcas_frontend/models/request/request.dart";

class DraftTable extends StatelessWidget {
  const DraftTable(this.viewModel, {required this.state, super.key});
  final HomeViewModel viewModel;
  final HomeState state;

  @override
  Widget build(BuildContext context) {
    final bool showAssignColumn = viewModel.showAssignUser;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Gap(),
        CustomSectionHeader(
          title: viewModel
              .getSummaryText(viewModel.selectedSummary ?? SummaryType.na),
        ),
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
                        label: _cellWidget(
                          "dashboard.home.requestRefNo".tr(),
                          color: AppColors.black,
                        ),
                      ),
                      TableColumn(
                        forcedWidth: 130.w,
                        label: _cellWidget(
                          "dashboard.home.requestType".tr(),
                          color: AppColors.black,
                        ),
                      ),
                      TableColumn(
                        label: _cellWidget(
                          "dashboard.home.applicantRIM".tr(),
                          color: AppColors.black,
                        ),
                      ),
                      TableColumn(
                        label: _cellWidget(
                          "dashboard.home.applicantName".tr(),
                          color: AppColors.black,
                        ),
                      ),
                      TableColumn(
                        label: _cellWidget(
                          "dashboard.home.requestBy".tr(),
                          color: AppColors.black,
                        ),
                      ),
                      TableColumn(
                        label: _cellWidget(
                          "dashboard.home.receivedFrom".tr(),
                          color: AppColors.black,
                        ),
                      ),
                      TableColumn(
                        label: _cellWidget(
                          "dashboard.home.filter.ageing".tr(),
                          color: AppColors.black,
                        ),
                      ),
                      TableColumn(
                        label: _cellWidget(
                          "dashboard.home.pendingSince".tr(),
                          color: AppColors.black,
                        ),
                      ),
                      if (Utils.checkRoles([
                        UserRole.inquiryUser,
                        UserRole.admin,
                        UserRole.businessAdmin,
                      ])) ...[
                        TableColumn(
                          label: _cellWidget(
                            "dashboard.home.pendingWith".tr(),
                            color: AppColors.black,
                          ),
                        ),
                        TableColumn(
                          forcedWidth: 40.w,
                          label: _cellWidget(
                            "dashboard.home.purpose".tr(),
                            color: AppColors.black,
                          ),
                        ),
                        TableColumn(
                          label: _cellWidget(
                            "dashboard.home.customerSegment".tr(),
                            color: AppColors.black,
                          ),
                        ),
                        TableColumn(
                          forcedWidth: 100.w,
                          label: _cellWidget(
                            "dashboard.home.requestStatus".tr(),
                            color: AppColors.black,
                          ),
                        ),
                      ],
                      if (!Utils.checkRoles([
                        UserRole.inquiryUser,
                        UserRole.admin,
                        UserRole.businessAdmin,
                      ])) ...[
                        if (Utils.checkRoles([
                          UserRole.documentationMaker,
                          UserRole.documentationChecker,
                          UserRole.ccuChecker,
                          UserRole.ccuMaker,
                        ])) ...[
                          TableColumn(
                            label: _cellWidget(
                              "dashboard.home.dateofRequest".tr(),
                              color: const Color.fromARGB(255, 3, 2, 2),
                            ),
                          ),
                        ] else ...[
                          TableColumn(
                            label: _cellWidget(
                              "dashboard.home.dateofCreation".tr(),
                              color: AppColors.black,
                            ),
                          ),
                        ],
                        TableColumn(
                          forcedWidth: 40.w,
                          label: _cellWidget(
                            "dashboard.home.purpose".tr(),
                            color: AppColors.black,
                          ),
                        ),
                        TableColumn(
                          label: _cellWidget(
                            "dashboard.home.customerSegment".tr(),
                            color: AppColors.black,
                          ),
                        ),
                        TableColumn(
                          forcedWidth: 100.w,
                          label: _cellWidget(
                            "dashboard.home.requestStatus".tr(),
                            color: AppColors.black,
                          ),
                        ),
                      ],
                      if (showAssignColumn)
                        TableColumn(
                          label: _cellWidget("dashboard.home.action".tr()),
                        ),
                    ],
                    rowModels: _buildRows(context, viewModel, showAssignColumn),
                  ),
                  if (viewModel.filteredRequests.isEmpty)
                    const Text("No Data Found"),
                ],
              ),
        const Gap(),
      ],
    );
  }

  List<RowModel> _buildRows(
    BuildContext context,
    HomeViewModel viewModel,
    bool showAssignColumn,
  ) {
    List<RowModel> rowModels = [];
    final filterRow = RowModel(
      isFilterRow: true,
      color: AppColors.tableHeadingColor,
      widget: [
        _filterField(
          viewModel.reqRefNoFilter,
          FilterType.referenceNumber,
          maxLength: 30,
          inputFormatters: [
            FilteringTextInputFormatter.allow(RegExp("[a-zA-Z0-9]")),
          ],
        ),
        _filterFieldDropDownRequestStatus(
          viewModel.requestTypeFilter,
          viewModel.worklistData,
        ),
        _filterField(
          viewModel.applicantRimFilter,
          FilterType.applicantRim,
          maxLength: 10,
          inputFormatters: [FilteringTextInputFormatter.digitsOnly],
        ),
        _filterField(
          viewModel.applicantNameFilter,
          FilterType.applicantName,
          inputFormatters: [
            FilteringTextInputFormatter.allow(RegExp("[a-zA-Z0-9 ]")),
          ],
          maxLength: 122,
        ),
        _filterField(
          viewModel.requestByFilter,
          FilterType.requestBy,
          maxLength: 50,
        ), // Request By
        _filterField(
          viewModel.receivedFromFilter,
          FilterType.receivedFrom,
          maxLength: 50,
        ), // Received From
        const SizedBox(), // Ageing
        const SizedBox(), // Pending Since
        if (Utils.checkRoles([
          UserRole.inquiryUser,
          UserRole.admin,
          UserRole.businessAdmin,
        ])) ...[
          const SizedBox(), // Pending With
          const SizedBox(), // Purpose
          _filterFieldDropDownBusinessSegment(
            viewModel.businessSegmentListFilter,
            viewModel.worklistData,
          ), // Business Segment
          _filterFieldDropDownStatus(
            viewModel.requestStatusListFilter,
            viewModel.worklistData,
          ), // Request Status
        ] else ...[
          const SizedBox(), // Date of Creation
          const SizedBox(), // Purpose
          _filterFieldDropDownBusinessSegment(
            viewModel.businessSegmentListFilter,
            viewModel.worklistData,
          ), // Business Segment
          _filterFieldDropDownStatus(
            viewModel.requestStatusListFilter,
            viewModel.worklistData,
          ), // Request Status
        ],
        if (showAssignColumn) const SizedBox(),
      ],
    );
    for (int i = 0; i < viewModel.filteredRequests.length; i++) {
      final Request? request = viewModel.filteredRequests[i];
      if (request?.applicationRefNo != null) {
        rowModels.add(
          RowModel(
            isFilterRow: false,
            widget: [
              Row(
                children: [
                  TextButton(
                    style: ButtonStyle(
                      padding: WidgetStateProperty.all(EdgeInsets.zero),
                    ),
                    onPressed: () => viewModel.openApplication(request!, i),
                    child: _cellWidget(
                      request?.applicationRefNo.toString() ?? "",
                      addUnderline: true,
                      businessSegment: request?.businessSegmentEnum,
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
                message: "${request?.applicationType?.name}",
                child: _cellWidget(
                  request?.applicationType?.name ?? "",
                  businessSegment: request?.businessSegmentEnum,
                ),
              ),
              _cellWidget(
                request?.customerRimNo.toString() ?? "",
                businessSegment: request?.businessSegmentEnum,
              ),
              _cellWidget(
                request?.customerName ?? "",
                businessSegment: request?.businessSegmentEnum,
              ),
              _cellWidget(
                request?.requestedBy ?? "",
                businessSegment: request?.businessSegmentEnum,
              ),
              _cellWidget(
                request?.receivedFrom ?? "",
                businessSegment: request?.businessSegmentEnum,
              ),
              _cellWidget(
                request?.ageing ?? "",
                businessSegment: request?.businessSegmentEnum,
              ), //replace with actual value for Ageiing once API is fixed
              _cellWidget(
                request?.pendingSince ?? "",
                businessSegment: request?.businessSegmentEnum,
              ),
              if (!Utils.checkRoles([
                UserRole.inquiryUser,
                UserRole.admin,
                UserRole.businessAdmin,
              ]))
                _cellWidget(
                  request?.dateOfCreation ?? "",
                  businessSegment: request?.businessSegmentEnum,
                ),
              if (Utils.checkRoles([
                UserRole.inquiryUser,
                UserRole.admin,
                UserRole.businessAdmin,
              ]))
                _cellWidget(
                  request?.pendingWith ?? "",
                  businessSegment: request?.businessSegmentEnum,
                ),
              TextButton(
                style: ButtonStyle(
                  padding: WidgetStateProperty.all(EdgeInsets.zero),
                ),
                onPressed: () => DialogHelper.showCommentContentDialog(
                  context,
                  request?.purpose ?? "",
                  "dashboard.home.purpose".tr(),
                ),
                child: _cellWidget(
                  "View",
                  overflow: false,
                  addUnderline: true,
                  businessSegment: request?.businessSegmentEnum,
                ),
              ),
              _cellWidget(
                request?.businessSegment?.name ?? "",
                businessSegment: request?.businessSegmentEnum,
              ),
              _cellWidget(
                request?.status ?? "",
                businessSegment: request?.businessSegmentEnum,
              ),
              if (showAssignColumn)
                TextButton(
                  onPressed: () => viewModel.onActionClicked(
                    context,
                    request?.applicationRefNo,
                    viewModel.selectedAssignToDetail,
                  ),
                  child: _cellWidget(
                    viewModel.selectedAssignToDetail?.assignLinkName ?? "",
                    overflow: false,
                    addUnderline: true,
                    businessSegment: request?.businessSegmentEnum,
                  ),
                ),
            ],
            color: viewModel.getTableColor(request?.businessSegmentEnum),
          ),
        );
      }
    }
    rowModels = addFilterForRowModel(
      rows: rowModels,
      filterRow: filterRow,
      rowsPerPage: viewModel.rowsPerPage,
    );
    return rowModels.isEmpty ? [filterRow] : rowModels;
  }

  Widget _cellWidget(
    String text, {
    bool overflow = true,
    bool addUnderline = false,
    BusinessSegment? businessSegment,
    Color? color,
  }) {
    return Text(
      text,
      overflow: overflow ? TextOverflow.ellipsis : null,
      maxLines: overflow ? 1 : null,
      style: TextStyle(
        fontSize: AppStyle.columnName,
        color: color ?? viewModel.getTableTextColor(businessSegment),
        decoration: addUnderline ? TextDecoration.underline : null,
      ),
    );
  }

  Widget _filterField(
    String? text,
    FilterType filterType, {
    int? maxLength,
    List<TextInputFormatter>? inputFormatters,
  }) {
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
            counterText: "",
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
    List<Request>? selectedRequests,
    List<Request> requests,
  ) {
    final List<String> customNames = viewModel.customApplicationTypeNames;

    // Split into current (custom) types and check if any historical ones exist
    final List<Request> customItems = requests
        .where((Request e) {
          final String name = (e.applicationType?.name ?? "").trim();
          return name.isNotEmpty && customNames.contains(name);
        })
        .distinctBy((Request e) => e.applicationType?.name?.trim())
        .toList();

    final bool hasHistoricalItems = requests.any((Request e) {
      final String name = (e.applicationType?.name ?? "").trim();
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
              ..applicationType = Reference(
                name: "dashboard.home.historicalApplicationTypes".tr(),
              ),
        ],
        // Dedupe the stored filter by name — the sentinel is already in the
        // list if selected
        selectedItems: selectedRequests
            ?.distinctBy((Request e) => e.applicationType?.name?.trim())
            .toList(),
        onSelected: (selectedValue) {
          viewModel.onFilter(
            filterType: FilterType.referenceType,
            value: "",
            selectedTypes: selectedValue,
          );
        },
        fillColor: AppColors.white,
        dropdownBuilder: (context, data) {
          final String? tooltip =
              data?.map((val) => val.applicationType?.name).join(", ");
          return CustomTooltip(
            showTooltip: tooltip != "",
            message: tooltip ?? "",
            child: const Text(""),
          );
        },
        itemBuilder: (context, item, isDisabled, isSelected) {
          return ListTile(
            dense: true,
            title: Text(item.applicationType?.name ?? ""),
          );
        },
        compareFn: (item1, item2) =>
            item1.applicationType?.name == item2.applicationType?.name,
        filterFn: (Request item, String filter) {
          return (item.applicationType?.name ?? "")
              .toLowerCase()
              .contains(filter.toLowerCase());
        },
        isSearchable: true,
      ),
    );
  }

  Widget _filterFieldDropDownStatus(
    List<String>? selectedStatuses,
    List<Request> requests,
  ) {
    final List<Request> distinctStatusRequests = requests
        .where((e) => (e.status ?? "").trim().isNotEmpty)
        .distinctBy((e) => e.status?.trim())
        .toList();

    final List<Request> mappedSelectedRequests = selectedStatuses != null
        ? distinctStatusRequests
            .where((req) => selectedStatuses.contains(req.status))
            .toList()
        : [];

    return Align(
      alignment: AlignmentDirectional.center,
      child: CustomMultiSelectDropdown<Request>(
        isFilterField: true,
        validationMessage: "validation.emptyField".tr(),
        semanticLabel: FilterType.requestStatus.name,
        items: distinctStatusRequests,
        selectedItems: mappedSelectedRequests,
        onSelected: (selectedValue) {
          viewModel.onFilter(
            filterType: FilterType.requestStatus,
            value: "",
            selectedTypes: selectedValue,
          );
        },
        fillColor: AppColors.white,
        dropdownBuilder: (context, data) {
          final String? tooltip = data?.map((val) => val.status).join(", ");
          return CustomTooltip(
            showTooltip: tooltip != "" && tooltip != null,
            message: tooltip ?? "",
            child: const Text(""),
          );
        },
        itemBuilder: (context, item, isDisabled, isSelected) {
          return ListTile(
            dense: true,
            title: Text(
              "${item.status}",
              style: const TextStyle(fontSize: 10),
            ),
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

  Widget _filterFieldDropDownBusinessSegment(
    List<String>? selectedSegments,
    List<Request> requests,
  ) {
    final List<Request> distinctSegmentRequests = requests
        .where((e) => (e.businessSegment?.name ?? "").trim().isNotEmpty)
        .distinctBy((e) => e.businessSegment?.name?.trim())
        .toList();

    final List<Request> mappedSelectedRequests = selectedSegments != null
        ? distinctSegmentRequests
            .where(
              (req) => selectedSegments.contains(req.businessSegment?.name),
            )
            .toList()
        : [];

    return Align(
      alignment: AlignmentDirectional.center,
      child: CustomMultiSelectDropdown<Request>(
        isFilterField: true,
        validationMessage: "validation.emptyField".tr(),
        semanticLabel: FilterType.businessSegment.name,
        items: distinctSegmentRequests,
        selectedItems: mappedSelectedRequests,
        onSelected: (selectedValue) {
          viewModel.onFilter(
            filterType: FilterType.businessSegment,
            value: "",
            selectedTypes: selectedValue,
          );
        },
        fillColor: AppColors.white,
        dropdownBuilder: (context, data) {
          final String? tooltip =
              data?.map((val) => val.businessSegment?.name).join(", ");
          return CustomTooltip(
            showTooltip: tooltip != "" && tooltip != null,
            message: tooltip ?? "",
            child: const Text(""),
          );
        },
        itemBuilder: (context, item, isDisabled, isSelected) {
          return ListTile(
            dense: true,
            title: Text(
              "${item.businessSegment?.name}",
              style: const TextStyle(fontSize: 10),
            ),
          );
        },
        compareFn: (item1, item2) =>
            item1.businessSegment?.name == item2.businessSegment?.name,
        filterFn: (Request item, String filter) {
          return (item.businessSegment?.name ?? item.toString())
              .toLowerCase()
              .contains(filter.toLowerCase());
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
