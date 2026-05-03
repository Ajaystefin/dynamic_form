import "package:easy_localization/easy_localization.dart";
import "package:flutter/material.dart";
import "package:wcas_frontend/core/components/custom_table/table.dart";
import "package:wcas_frontend/core/components/textfield.dart";
import "package:wcas_frontend/core/constants/_server_constants.dart";
import "package:wcas_frontend/core/constants/constants.dart";
import "package:wcas_frontend/core/utils/scale.dart";
import "package:wcas_frontend/core/utils/utils.dart";
import "package:wcas_frontend/features/request/covenants_conditions/select_facilities_dialog/model.dart";

class SelectFacilitiesTable extends StatelessWidget {
  const SelectFacilitiesTable({required this.viewModel, super.key});
  final SelectFacilitiesDialogViewModel viewModel;

  @override
  Widget build(BuildContext context) {
    return CustomRawTable(
      isFilterTable: true,
      autoFitWidth: true,
      key: UniqueKey(),
      columns: createColumns(),
      rowModels: buildRows(viewModel),
      rowsPerPage: viewModel.rowsPerPage,
      initialPage: viewModel.page,
      onPageChange: (int pageNo) {
        viewModel.page = pageNo;
      },
      showPagination: true,
      rowHeight: 50,
    );
  }

  List<RowModel> buildRows(SelectFacilitiesDialogViewModel viewModel) {
    List<RowModel> rowModels = [];

    final filterRow = RowModel(
      isFilterRow: true,
      color: AppColors.tableHeadingColor,
      widget: [
        if (viewModel.showCheckboxColumn) const SizedBox(),
        _createFilterField(viewModel.rimFilterCtrl, Filter.rimNo),
        _createFilterField(viewModel.limitNumFilterCtrl, Filter.limitNumber),
        _createFilterField(viewModel.projFilterCtrl, Filter.limitLabel),
        _createFilterField(viewModel.descFilterCtrl, Filter.limitDescription),
        const SizedBox(),
      ],
    );

    // NOTE: checkboxes[] is the single authoritative source of truth,
    // already built from selectedIds by _rebuildCheckboxesFromSelection().
    // Do NOT mutate ViewModel state inside build() — it resets selections.

    final dataRows = List<List<Widget>>.generate(
      viewModel.filteredData.length,
      (int index) {
        final facility = viewModel.filteredData[index];
        return [
          if (viewModel.showCheckboxColumn)
            Center(
              child: Checkbox(
                visualDensity: VisualDensity.compact,
                // Read from the authoritative checkboxes[] list (driven by
                // selectedIds),
                // not from getCheckBoxValue() which reads a secondary derived
                // list.
                value: index < viewModel.checkboxes.length
                    ? viewModel.checkboxes[index]
                    : false,
                onChanged: (bool? newValue) {
                  viewModel.updateCheckboxAtIndex(index, newValue ?? false);
                },
              ),
            ),
          Center(child: Text("${facility.rimNo}")),
          Center(
            child: TextButton(
              onPressed: () async {
                viewModel.onPressedLimitNo(facilityItem: facility);
              },
              child: Text(facility.limitNumber ?? ""),
            ),
          ),
          Center(child: Text(facility.limitLabel ?? "")),
          Center(
            child: Text(
              viewModel.limitDescriptionReferenceName(
                options: viewModel.facilityTypeOptions,
                id: facility.limitCode,
              ),
            ),
          ),
          Center(
            child: (facility.currency?.toUpperCase() ==
                    ServerConstants.aedCurrency)
                // AED → single text: proposedLimitAED
                ? Text(
                    Utils.numberFormat(
                      facility.proposedLimitAED ?? facility.proposedLimit ?? 0,
                    ),
                    style: AppStyle.highlightedText,
                  )
                // Non-AED → two texts: "CUR proposedLimit" and
                // "proposedLimitAED"
                : Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      // First line: proposedLimitAED
                      Text(
                        Utils.numberFormat(facility.proposedLimitAED ?? 0),
                        // Use a lighter style for the AED conversion if you
                        // have one
                        style: AppStyle.highlightedText,
                      ),
                      // Second line: currency + proposedLimit
                      Text(
                        '${(facility.currency ?? '').toUpperCase()} '
                        "${Utils.numberFormat(facility.proposedLimit ?? 0)}",
                        style: AppStyle.highlightedGrayText,
                      ),
                      const SizedBox(height: 2),
                    ],
                  ),
          ),
        ];
      },
    );

    // Wrap each data row into RowModel (unchanged structure)
    for (final rowWidgets in dataRows) {
      rowModels.add(RowModel(isFilterRow: false, widget: rowWidgets));
    }

    // 👉 If you want 6 data rows + filter, add +1 here:
    rowModels = addFilterForRowModel(
      rows: rowModels,
      filterRow: filterRow,
      rowsPerPage:
          viewModel.rowsPerPage, // <-- adjust to avoid dropping index 0
    );

    return rowModels.isEmpty ? [filterRow] : rowModels;
  }

  Widget _createFilterField(String? text, Filter filter) {
    return SizedBox(
      child: CustomTextField(
        initialValue: text,
        onSubmitted: (String value) {
          viewModel.onFilter(filter, value: value);
        },
      ),
    );
  }

  List<TableColumn> createColumns() {
    return <TableColumn>[
      if (viewModel.showCheckboxColumn)
        TableColumn(
          forcedWidth: 20,
          label: Checkbox(
            visualDensity: VisualDensity.compact,
            value: viewModel.isSelectAll,
            onChanged: viewModel.toggleSelectAll,
          ),
        ),
      TableColumn(
        forcedWidth: 100.w,
        label: Text("covenantsConditions.selectFacilityDialog.rimNo".tr()),
      ),
      TableColumn(
        forcedWidth: 100.w,
        label: Text(
          "covenantsConditions.selectFacilityDialog.limitNumber".tr(),
        ),
      ),
      TableColumn(
        forcedWidth: 100.w,
        label: Text(
          "covenantsConditions.selectFacilityDialog.projectName".tr(),
        ),
      ),
      TableColumn(
        forcedWidth: 100.w,
        label: SizedBox(
          child: Text(
            "covenantsConditions.selectFacilityDialog.limitDescription".tr(),
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ),
      TableColumn(
        forcedWidth: 100.w,
        label: Text(
          "covenantsConditions.selectFacilityDialog.proposedLimit".tr(),
          overflow: TextOverflow.ellipsis,
        ),
      ),
    ];
  }
}
