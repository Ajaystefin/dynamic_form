import "package:easy_localization/easy_localization.dart";
import "package:flutter/material.dart";
import "package:wcas_frontend/core/components/custom_table/table.dart";
import "package:wcas_frontend/core/components/textfield.dart";
import "package:wcas_frontend/core/components/tooltip.dart";
import "package:wcas_frontend/core/constants/constants.dart";
import "package:wcas_frontend/core/utils/scale.dart";
import "package:wcas_frontend/core/utils/validators.dart";
import "package:wcas_frontend/features/request/approval/proposed_facilities/model.dart";
import "package:wcas_frontend/models/request/approval/group_position.dart";

/// Displays present or proposed facility positions in a custom raw table.
class PositionsTable extends StatelessWidget {
  /// Creates the positions table widget.
  const PositionsTable({
    required this.viewModel,
    required this.isProposed,
    super.key,
    this.positions,
  });

  /// View model used to provide proposed facilities data and controllers.
  final ProposedFacilitiesViewModel viewModel;

  /// List of position records displayed in the table.
  final List<Position>? positions;

  /// Indicates whether the table displays proposed position data.
  final bool isProposed;

  @override
  Widget build(BuildContext context) {
    return CustomRawTable(
      key: UniqueKey(),
      // rowHeight: null,
      //columnSpacing: 80.w,
      // autoFitWidth: false,
      columnHeaderHeight: 50.w,
      rowsPerPage: viewModel.rowsPerPage,
      columns: getPositionsColumns(),
      rows: getPositionsRows(positions, isProposed: isProposed),
    );
  }

  /// Returns the column definitions for the positions table.
  List<TableColumn> getPositionsColumns() {
    return [
      TableColumn(
        width: 100.w,
        label: Text("approval.proposedFacilities.customerName".tr()),
      ),
      TableColumn(
        forcedWidth: 70.w,
        label: Text("approval.proposedFacilities.existingCRR".tr()),
      ),
      TableColumn(
        forcedWidth: 60.w,
        label: Text(
          "approval.proposedFacilities.proposedCRR".tr(),
        ),
      ), //CLEAN EXPOSURE COLUMN TO BE EDITABLE
      TableColumn(
        width: 50.w,
        label: Text("approval.proposedFacilities.fundBasedLimits".tr()),
      ),
      TableColumn(
        forcedWidth: 50.w,
        label: Text("approval.proposedFacilities.nonFundBasedLimits".tr()),
      ),
      TableColumn(
        width: 50.w,
        label: Text("approval.proposedFacilities.totalLimits".tr()),
      ),
      TableColumn(
        forcedWidth: 60.w,
        label: Text("approval.proposedFacilities.totalTangibleSecurity".tr()),
      ),
      TableColumn(
        forcedWidth: 70.w,
        label: Text("approval.proposedFacilities.ofWhichCashCollateral".tr()),
      ),
      TableColumn(
        forcedWidth: 90.w,
        label: Text(
          "approval.proposedFacilities.totalLimitsNetofTotalTangibleSecurity"
              .tr(),
        ),
      ),
      TableColumn(
        forcedWidth: 90.w,
        label: Text(
          "approval.proposedFacilities.totalLimitsNetofCashCollateralOnly".tr(),
        ),
      ),
      TableColumn(
        forcedWidth: 90.w,
        label: Text("approval.proposedFacilities.cleanExposure".tr()),
      ),
    ];
  }

  /// Returns the row widgets for the given present or proposed positions.
  List<List<Widget>> getPositionsRows(
    List<Position>? positions, {
    required bool isProposed,
  }) {
    if (positions == null) {
      return [];
    }
    return List.generate(positions.length, (index) {
      final position = positions[index];
      final String type = isProposed ? "proposed" : "present";
      final String key = "${position.rimNo}_$type";
      if (viewModel.cleanExposureControllers?[key] == null) {
        viewModel.cleanExposureControllers?[key] =
            TextEditingController(text: "0");
      }
      return [
        CustomTooltip(
          message: position.customerName?.toString() ?? "",
          child: SizedBox(
            child: Text(position.customerName?.toString() ?? ""),
          ),
        ),
        Text(
          position.overriddenCRR?.toString() ?? "",
        ), // mapped as existing crr
        Text(
          position.modelGeneratedCRR?.toString() ?? "",
        ), // mapped as proposed crr
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
        Text(
          position.totalTangibleSecurity?.toString() ?? "",
          style: const TextStyle(color: AppColors.highlightedTextColor),
        ),
        Text(
          position.ofWhichCashCollateral?.toString() ?? "",
          style: const TextStyle(color: AppColors.highlightedTextColor),
        ),
        Text(
          position.totalLimitsNetOfTotalTangibleSecurity?.toString() ?? "",
          style: const TextStyle(color: AppColors.highlightedTextColor),
        ),
        Text(
          position.totalLimitsNetOfCashCollateralOnly?.toString() ?? "",
          style: const TextStyle(color: AppColors.highlightedTextColor),
        ),
        CustomTooltip(
          message: viewModel.cleanExposureValues[key] ?? "0",
          child: (position.order == 3)
              ? CustomTextField(
                  readOnly: viewModel.isReadOnly,
                  // key: ValueKey('cleanExposure_$index'),
                  width: 118,
                  inputFormatters: [
                    DecimalInputFormatter(
                      regEx: RegExp(r"^[0-9,]{0,15}(\.\d{0,6})?$"),
                    ),
                  ],
                  // validator: CustomValidator.requiredField,
                  initialValue: viewModel.cleanExposureControllers?[key]?.text,
                  controller: viewModel.cleanExposureControllers?[key],
                  onChanged: (newValue) => viewModel.updateExposureField(
                    index,
                    position.rimNo,
                    newValue,
                    isProposed: isProposed,
                  ),
                )
              : (position.order == 1)
                  ? Center(
                      child: Text(
                        viewModel.totalProposedExposure.toString(),
                        style: const TextStyle(
                          color: AppColors.highlightedTextColor,
                        ),
                      ),
                    )
                  : Center(
                      child: Text(
                        viewModel.cleanExposureValues[key] ?? "0",
                        style: const TextStyle(
                          color: AppColors.highlightedTextColor,
                        ),
                      ),
                    ),
        ),
      ];
    });
  }
}
