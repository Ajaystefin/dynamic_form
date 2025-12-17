import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:wcas_frontend/core/components/custom_table/table.dart';
import 'package:wcas_frontend/core/constants/constants.dart';
import 'package:wcas_frontend/core/utils/scale.dart';
import 'package:wcas_frontend/features/request/approval/group_position/model.dart';
import 'package:wcas_frontend/models/request/approval/group_position.dart';

class CustomerTable extends StatelessWidget {
  final GroupPositionViewModel viewModel;
  final CustomerPosition customerPosition;

  const CustomerTable(
      {super.key, required this.viewModel, required this.customerPosition});

  @override
  Widget build(BuildContext context) {
    return CustomRawTable(
      key: UniqueKey(),
      autoFitWidth: true,
      columnHeaderHeight: 0,
      showPagination: true,
      rowsPerPage: viewModel.rowsPerPage,
      columns: getPositionsColumns(),
      rows: getPositionsRows(),
    );
  }

  List<TableColumn> getPositionsColumns() {
    return [
      TableColumn(
          label: Text(
        "approval.groupPosition.customerName".tr(),
      )),
      TableColumn(label: Text("approval.groupPosition.existingCrr".tr())),
      TableColumn(label: Text("approval.groupPosition.proposedCrr".tr())),
      TableColumn(
          forcedWidth: 60.w,
          label: Text("approval.groupPosition.fundBasedLimits".tr())),
      TableColumn(
          forcedWidth: 60.w,
          label: Text("approval.groupPosition.nonFundBasedLimits".tr())),
      TableColumn(
          width: 70.w, label: Text("approval.groupPosition.totalLimits".tr())),
      TableColumn(
          forcedWidth: 70.w,
          label: Text("approval.groupPosition.totalTangibleSecurity".tr())),
      TableColumn(
          forcedWidth: 70.w,
          label: Text("approval.groupPosition.ofWhichCashCollateral".tr())),
      TableColumn(
          forcedWidth: 70.w,
          label: Text(
              "approval.groupPosition.totalLimitsNetofTotalTangibleSecurity"
                  .tr())),
      TableColumn(
          forcedWidth: 70.w,
          label: Text(
              "approval.groupPosition.totalLimitsNetofCashCollateralOnly"
                  .tr())),
    ];
  }

  List<List<Widget>> getPositionsRows() {
    final rows = <List<Widget>>[];
    final colCount = getPositionsColumns().length;

    // Row: “Present” label in first column + presentRowValues in remaining cols
    rows.add(
      List.generate(colCount, (col) {
        if (col == 0) {
          return const Padding(
            padding: EdgeInsets.symmetric(vertical: 4.0),
            child: Text('Present'), //Present row label
          );
        }
        // populate with existing CRR (presentRowValues)
        final idx = col - 1;
        if (idx < customerPosition.presentRowValues.length) {
          return Center(child: Text(customerPosition.presentRowValues[idx]));
        }
        return const SizedBox.shrink();
      }),
    );

    // Row: “Proposed” label in first column + proposedRowValues in remaining cols
    rows.add(
      List.generate(colCount, (col) {
        if (col == 0) {
          return const Padding(
            padding: EdgeInsets.symmetric(vertical: 4.0),
            child: Text('Proposed'), // Proposed row label
          );
        }
        // populate with proposed limits
        final idx = col - 1;
        if (idx < customerPosition.proposedRowValues.length) {
          return Center(
            child: Text(
              customerPosition.proposedRowValues[idx],
              style: const TextStyle(color: AppColors.darkBlue),
            ),
          );
        }
        return const SizedBox.shrink();
      }),
    );

    return rows.toList();
  }
}
