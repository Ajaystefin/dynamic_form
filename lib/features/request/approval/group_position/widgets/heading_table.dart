import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:wcas_frontend/core/components/custom_table/table.dart';
import 'package:wcas_frontend/core/utils/scale.dart';
import 'package:wcas_frontend/features/request/approval/group_position/model.dart';

class HeadingTable extends StatelessWidget {
  final GroupPositionViewModel viewModel;

  const HeadingTable({
    super.key,
    required this.viewModel,
  });

  @override
  Widget build(BuildContext context) {
    return CustomRawTable(
      key: UniqueKey(),
      autoFitWidth: true,
      columnHeaderHeight: 80.w,
      showPagination: true,
      rowsPerPage: viewModel.rowsPerPage,
      headerColor: Colors.grey.shade200,
      columns: getPositionsColumns(),
      rows: const [],
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
      TableColumn(label: Text("approval.groupPosition.totalLimits".tr())),
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
}
