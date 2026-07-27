import "package:easy_localization/easy_localization.dart";
import "package:flutter/material.dart";
import "package:wcas_frontend/core/components/custom_table/table.dart";
import "package:wcas_frontend/core/components/textfield.dart";
import "package:wcas_frontend/core/constants/constants.dart";
import "package:wcas_frontend/core/utils/scale.dart";
import "package:wcas_frontend/core/utils/utils.dart";
import "package:wcas_frontend/features/request/approval/limit_caps/model.dart";
import "package:wcas_frontend/models/request/approval/limit_detail.dart";

/// Displays the limit caps details in a custom raw table.
class LimitCapsTable extends StatelessWidget {
  /// Creates the limit caps table widget.
  const LimitCapsTable({
    required this.viewModel,
    super.key,
  });

  /// View model used to provide limit caps data, filters, and pagination values.
  final LimitCapsViewModel viewModel;

  @override
  Widget build(BuildContext context) {
    return CustomRawTable(
      key: UniqueKey(),
      columnSpacing: 80.w,
      rowsPerPage: viewModel.rowsPerPage,
      columnHeaderHeight: AppStyle.singleRowColumnHeaderHeight.w,
      columns: getPositionsColumns(),
      rowHeight: AppStyle.singleRowColumnHeaderHeight.w,
      rows: buildRows(),
    );
  }

  /// Returns the column definitions for the limit caps table.
  List<TableColumn> getPositionsColumns() {
    return [
      TableColumn(
        forcedWidth: 100.w,
        label: Center(child: Text("approval.limitCaps.rimNO".tr())),
      ),
      TableColumn(
        forcedWidth: 140.w,
        label: Center(child: Text("approval.limitCaps.customerName".tr())),
      ),
      TableColumn(
        label: Center(child: Text("approval.limitCaps.presentLimit".tr())),
      ),
      TableColumn(
        label: Center(child: Text("approval.limitCaps.proposedLimit".tr())),
      ),
    ];
  }

  /// Builds the filter row and data rows for the limit caps table.
  List<List<Widget>> buildRows() {
    List<List<Widget>> dataRows = [];

    final filterRow = <Widget>[
      _createFilterField(), // under rim
      const SizedBox(), // under Customer Name
      const SizedBox(), // under Present Limit
      const SizedBox(), // under Proposed Limit
    ];
    // if (viewModel.filteredlimitDetail.isEmpty) return [];

    dataRows.add(filterRow);
    // 2) Data rows
    for (final LimitDetail? limitDetail in viewModel.filteredlimitDetail) {
      dataRows.add([
        Text(limitDetail?.rimNo?.toString() ?? ""),
        Text(limitDetail?.custName ?? ""),
        Text(limitDetail?.presentLimit?.toString() ?? ""),
        Text(limitDetail?.proposedLimit?.toString() ?? ""),
      ]);
    }
    // dataRows.addAll(List<List<Widget>>.generate(
    //   viewModel.filteredlimitDetail.length,
    //   (index) {
    //     LimitDetail? limitDetail = viewModel.filteredlimitDetail[index];
    //     return [
    //       Text(limitDetail?.rimNo?.toString() ?? ""),
    //       Text(limitDetail?.custName ?? ""),
    //       Text(limitDetail?.presentLimit?.toString() ?? ""),
    //       Text(limitDetail?.proposedLimit?.toString() ?? ""),
    //     ];
    //   },
    // ));

    dataRows = addFilter(
      rows: dataRows,
      filterRow: filterRow,
      rowsPerPage: viewModel.rowsPerPage,
    );
    return dataRows.isEmpty ? [filterRow] : dataRows;
  }

  Widget _createFilterField() {
    return SizedBox(
      child: CustomTextField(
        initialValue: viewModel.filterRim,
        semanticLabel: FilterType.applicantRim.name,
        onSubmitted: (value) {
          viewModel.onFilter(value: value);
        },
      ),
    );
  }
}
