import "package:easy_localization/easy_localization.dart";
import "package:flutter/material.dart";
import "package:wcas_frontend/core/components/custom_table/table.dart";
import "package:wcas_frontend/core/utils/scale.dart";
import "package:wcas_frontend/features/request/approval/group_position/model.dart";

/// Displays the heading table for group position customer exposure details.
class HeadingTable extends StatelessWidget {
  /// Creates the heading table widget.
  const HeadingTable({
    required this.viewModel,
    super.key,
  });

  /// View model used to provide table configuration values.
  final GroupPositionViewModel viewModel;

  @override
  Widget build(BuildContext context) {
    return CustomRawTable(
      key: UniqueKey(),
      columnHeaderHeight: 80.w,
      rowsPerPage: viewModel.rowsPerPage,
      headerColor: Colors.grey.shade200,
      columns: getPositionsColumns(),
      rows: const [],
    );
  }

  /// Returns the column definitions for the group position heading table.
  List<TableColumn> getPositionsColumns() {
    return [
      TableColumn(
        label: Text(
          "approval.groupPosition.customerName".tr(),
        ),
      ),
      TableColumn(label: Text("approval.groupPosition.existingCrr".tr())),
      TableColumn(label: Text("approval.groupPosition.proposedCrr".tr())),
      TableColumn(
        forcedWidth: 60.w,
        label: Text("approval.groupPosition.fundBasedLimits".tr()),
      ),
      TableColumn(
        forcedWidth: 60.w,
        label: Text("approval.groupPosition.nonFundBasedLimits".tr()),
      ),
      TableColumn(label: Text("approval.groupPosition.totalLimits".tr())),
      TableColumn(
        forcedWidth: 60.w,
        label: Text("approval.groupPosition.totalTangibleSecurity".tr()),
      ),
      TableColumn(
        forcedWidth: 70.w,
        label: Text("approval.groupPosition.ofWhichCashCollateral".tr()),
      ),
      TableColumn(
        forcedWidth: 70.w,
        label: Text(
          "approval.groupPosition.totalLimitsNetofTotalTangibleSecurity".tr(),
        ),
      ),
      TableColumn(
        forcedWidth: 70.w,
        label: Text(
          "approval.groupPosition.totalLimitsNetofCashCollateralOnly".tr(),
        ),
      ),
      TableColumn(
        forcedWidth: 70.w,
        label: Text("approval.groupPosition.cleanExposure".tr()),
      ),
    ];
  }
}
