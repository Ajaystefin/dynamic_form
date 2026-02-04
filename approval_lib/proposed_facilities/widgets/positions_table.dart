import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:wcas_frontend/core/components/custom_table/table.dart';
import 'package:wcas_frontend/core/components/tooltip.dart';
import 'package:wcas_frontend/core/constants/constants.dart';
import 'package:wcas_frontend/core/utils/scale.dart';
import 'package:wcas_frontend/features/request/approval/proposed_facilities/model.dart';
import 'package:wcas_frontend/models/request/approval/group_position.dart';

class PositionsTable extends StatelessWidget {
  final ProposedFacilitiesViewModel viewModel;
  final List<Position>? positions;

  const PositionsTable({
    super.key,
    required this.viewModel,
    this.positions,
  });

  @override
  Widget build(BuildContext context) {
    return CustomRawTable(
      key: UniqueKey(),
      showPagination: true,
      // rowHeight: null,
      //columnSpacing: 80.w,
      // autoFitWidth: false,
      columnHeaderHeight: 50.w,
      rowsPerPage: viewModel.rowsPerPage,
      columns: getPositionsColumns(),
      rows: getPositionsRows(positions),
    );
  }

  List<TableColumn> getPositionsColumns() {
    return [
      TableColumn(
          width: 100.w,
          label: Text("approval.proposedFacilities.customerName".tr())),
      TableColumn(
          forcedWidth: 70.w,
          label: Text("approval.proposedFacilities.modelGenCRR".tr())),
      TableColumn(
          forcedWidth: 60.w,
          label: Text("approval.proposedFacilities.overriddenCRR"
              .tr())), //CLEAN EXPOSURE COLUMN TO BE EDITABLE
      TableColumn(
          width: 60.w,
          label: Text("approval.proposedFacilities.fundBasedLimits".tr())),
      TableColumn(
          forcedWidth: 80.w,
          label: Text("approval.proposedFacilities.nonFundBasedLimits".tr())),
      TableColumn(
          width: 50.w,
          label: Text("approval.proposedFacilities.totalLimits".tr())),
      TableColumn(
          forcedWidth: 60.w,
          label:
              Text("approval.proposedFacilities.totalTangibleSecurity".tr())),
      TableColumn(
          forcedWidth: 70.w,
          label:
              Text("approval.proposedFacilities.ofWhichCashCollateral".tr())),
      TableColumn(
          forcedWidth: 90.w,
          label: Text(
              "approval.proposedFacilities.totalLimitsNetofTotalTangibleSecurity"
                  .tr())),
      TableColumn(
          forcedWidth: 90.w,
          label: Text(
              "approval.proposedFacilities.totalLimitsNetofCashCollateralOnly"
                  .tr())),
    ];
  }

  List<List<Widget>> getPositionsRows(List<Position>? positions) {
    if (positions == null) return [];

    return List.generate(positions.length, (index) {
      final position = positions[index];
      return [
        CustomTooltip(
          message: position.customerName?.toString() ?? "",
          child: SizedBox(
            child: Text(position.customerName?.toString() ?? ""),
          ),
        ),
        Text(position.modelGeneratedCRR?.toString() ?? ""),
        Text(position.overriddenCRR?.toString() ?? ""),
        Text(
          position.fundBasedLimits?.toString() ?? "",
          style: const TextStyle(color: AppColors.highlightedTextColor),
        ),
        Text(
          position.nonFundBasedLimits?.toString() ?? "",
          style: const TextStyle(color: AppColors.highlightedTextColor),
        ),
        Text(
          position.totalLimits?.toString() ?? "",
          style: const TextStyle(color: AppColors.highlightedTextColor),
        ),
        Text(position.totalTangibleSecurity?.toString() ?? "",
            style: const TextStyle(color: AppColors.highlightedTextColor)),
        Text(position.ofWhichCashCollateral?.toString() ?? "",
            style: const TextStyle(color: AppColors.highlightedTextColor)),
        Text(position.totalLimitsNetOfTotalTangibleSecurity?.toString() ?? "",
            style: const TextStyle(color: AppColors.highlightedTextColor)),
        Text(position.totalLimitsNetOfCashCollateralOnly?.toString() ?? "",
            style: const TextStyle(color: AppColors.highlightedTextColor)),
      ];
    });
  }
}
