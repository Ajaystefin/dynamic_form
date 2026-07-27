import "package:easy_localization/easy_localization.dart";
import "package:flutter/material.dart";
import "package:wcas_frontend/core/components/custom_table/table.dart";
import "package:wcas_frontend/core/components/textfield.dart";
import "package:wcas_frontend/core/constants/_server_constants.dart";
import "package:wcas_frontend/core/constants/constants.dart";
import "package:wcas_frontend/core/utils/scale.dart";
import "package:wcas_frontend/core/utils/utils.dart";
import "package:wcas_frontend/features/request/covenants_conditions/select_facilities_dialog/model.dart";
import "package:wcas_frontend/models/request/facility_security/facility.dart";
import "package:wcas_frontend/models/request/facility_security/security.dart";

/// Facilities selection table used in the select facilities dialog.
class SelectFacilitiesTable extends StatelessWidget {
  /// Creates a select facilities table.
  const SelectFacilitiesTable({required this.viewModel, super.key});

  /// Select facilities dialog view model.
  final SelectFacilitiesDialogViewModel viewModel;

  @override
  Widget build(BuildContext context) {
    return CustomRawTable(
      isFilterTable: true,
      key: UniqueKey(),
      columns: createColumns(),
      rowModels: buildRows(viewModel),
      rowsPerPage: viewModel.rowsPerPage,
      initialPage: viewModel.page,
      onPageChange: (int pageNo) {
        viewModel.page = pageNo;
      },
      rowHeight: 50,
    );
  }

  /// Builds table rows for facilities or linked securities mode.
  List<RowModel> buildRows(SelectFacilitiesDialogViewModel viewModel) {
    // Linked Securities mode: render security list
    if (viewModel.isLinkedSecuritiesMode) {
      return _buildSecurityRows(viewModel);
    }

    List<RowModel> rowModels = [];

    final RowModel filterRow = RowModel(
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

    // checkboxes[] is the single authoritative source of truth,
    // already built from selectedIds by _rebuildCheckboxesFromSelection().
    // Do NOT mutate ViewModel state inside build() — it resets selections.
    final List<List<Widget>> dataRows = List<List<Widget>>.generate(
      viewModel.filteredData.length,
      (int index) {
        final Facility facility = viewModel.filteredData[index];
        return [
          if (viewModel.showCheckboxColumn)
            Center(
              child: Checkbox(
                visualDensity: VisualDensity.compact,

                // Read from the authoritative checkboxes[] list (driven by
                // selectedIds),
                // not from getCheckBoxValue() which reads a secondary derived
                // list.
                value: index < viewModel.checkboxes.length &&
                    viewModel.checkboxes[index],

                onChanged: viewModel.canEdit
                    ? (bool? newValue) {
                        viewModel.updateCheckboxAtIndex(
                          index,
                          newValue: newValue ?? false,
                        );
                      }
                    : null,
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
                      (facility.proposedLimitAED ??
                              facility.proposedLimit ??
                              0) ~/
                          1000,
                    ),
                    style: AppStyle.highlightedText,
                  )
                // Non-AED → two texts: "CUR proposedLimit" and
                // "proposedLimitAED"
                : Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // First line: proposedLimitAED
                      Text(
                        Utils.numberFormat(
                          (facility.proposedLimitAED ?? 0) ~/ 1000,
                        ),
                        // Use a lighter style for the AED conversion if you
                        // have one
                        style: AppStyle.highlightedText,
                      ),
                      // Second line: currency + proposedLimit
                      Text(
                        '${(facility.currency ?? '').toUpperCase()} '
                        "${Utils.numberFormat((facility.proposedLimit ?? 0) ~/ 1000)}",
                        style: AppStyle.highlightedGrayText,
                      ),
                      const SizedBox(height: 2),
                    ],
                  ),
          ),
        ];
      },
    );

    for (final List<Widget> rowWidgets in dataRows) {
      rowModels.add(RowModel(isFilterRow: false, widget: rowWidgets));
    }
    rowModels = addFilterForRowModel(
      rows: rowModels,
      filterRow: filterRow,
      rowsPerPage: viewModel.rowsPerPage,
    );

    return rowModels.isEmpty ? [filterRow] : rowModels;
  }

  /// Builds rows for the securities list in Linked Securities mode.
  ///
  /// Uses `viewModel.linkedSecuritiesForLimit` populated by the ViewModel
  List<RowModel> _buildSecurityRows(SelectFacilitiesDialogViewModel viewModel) {
    final NumberFormat formatter = NumberFormat("#,##0");

    final List<RowModel> rowModels = [];

    // filter row placeholders (same number of columns)
    final RowModel filterRow = RowModel(
      isFilterRow: true,
      color: AppColors.tableHeadingColor,
      widget: const [
        SizedBox.shrink(),
        SizedBox.shrink(),
        SizedBox.shrink(),
        SizedBox.shrink(),
      ],
    );

    for (final Security security in viewModel.linkedSecuritiesForLimit) {
      final String presentAmount =
          formatter.format((security.presentSecurityAmount ?? 0) / 1000);

      String proposedAmount = "";
      String proposedAmountAlternateCurrency = "";

      final String proposedCurrency =
          (security.proposedSecurityAmtCurrency?.name ?? "AED")
              .trim()
              .toUpperCase();

      if (proposedCurrency != ServerConstants.aedCurrency) {
        proposedAmount =
            formatter.format((security.aedProposedSecurity ?? 0) / 1000);

        proposedAmountAlternateCurrency =
            "$proposedCurrency ${formatter.format((security.proposedSecurityAmount ?? 0) / 1000)}";
      } else {
        proposedAmount =
            formatter.format((security.proposedSecurityAmount ?? 0) / 1000);
      }

      rowModels.add(
        RowModel(
          isFilterRow: false,
          widget: [
            Center(child: Text(security.securityNumber ?? "")),
            Center(
              child: Text(
                viewModel
                    .securityTypeReferenceNameByCode(security.securityCode),
              ),
            ),
            Align(
              alignment: Alignment.centerRight,
              child: Text(
                presentAmount,
                style: AppStyle.highlightedText,
              ),
            ),
            Align(
              alignment: Alignment.centerRight,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    proposedAmount,
                    style: AppStyle.highlightedText,
                  ),
                  if (proposedAmountAlternateCurrency.isNotEmpty)
                    Text(proposedAmountAlternateCurrency),
                ],
              ),
            ),
          ],
        ),
      );
    }

    // add filter row above
    final List<RowModel> withFilter = addFilterForRowModel(
      rows: rowModels,
      filterRow: filterRow,
      rowsPerPage: viewModel.rowsPerPage,
    );

    return withFilter.isEmpty ? [filterRow] : withFilter;
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

  /// Creates table columns for facilities or linked securities mode.
  List<TableColumn> createColumns() {
    if (viewModel.isLinkedSecuritiesMode) {
      return <TableColumn>[
        TableColumn(forcedWidth: 100.w, label: const Text("Security Number")),
        TableColumn(forcedWidth: 80.w, label: const Text("Type of Security")),
        TableColumn(forcedWidth: 70.w, label: const Text("Present Security")),
        TableColumn(forcedWidth: 90.w, label: const Text("Proposed Security")),
      ];
    }

    return <TableColumn>[
      if (viewModel.showCheckboxColumn)
        TableColumn(
          forcedWidth: 20,
          label: Checkbox(
            visualDensity: VisualDensity.compact,
            value: viewModel.isSelectAll,
            onChanged: viewModel.canEdit
                ? (selectedValue) =>
                    viewModel.toggleSelectAll(selectedValue: selectedValue)
                : null,
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
