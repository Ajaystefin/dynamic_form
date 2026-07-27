import "package:easy_localization/easy_localization.dart";
import "package:flutter/material.dart";
import "package:wcas_frontend/core/components/custom_table/table.dart";
import "package:wcas_frontend/core/components/textfield.dart";
import "package:wcas_frontend/core/components/tooltip.dart";
import "package:wcas_frontend/core/constants/constants.dart";
import "package:wcas_frontend/core/utils/scale.dart";
import "package:wcas_frontend/core/utils/validators.dart";
import "package:wcas_frontend/features/request/approval/group_position/model.dart";
import "package:wcas_frontend/models/request/approval/group_position.dart";

/// Displays customer position details in a custom raw table.
class CustomerTable extends StatelessWidget {
  /// Creates a customer position table.
  const CustomerTable({
    required this.viewModel,
    required this.customerPosition,
    required this.order,
    super.key,
  });

  /// View model used to manage group position data and table controllers.
  final GroupPositionViewModel viewModel;

  /// Customer position data used to build table rows.
  final CustomerPosition customerPosition;

  /// Order used to determine editable and summary row behavior.
  final int order;

  @override
  Widget build(BuildContext context) {
    return CustomRawTable(
      key: UniqueKey(),
      columnHeaderHeight: 0,
      rowsPerPage: viewModel.rowsPerPage,
      columns: getPositionsColumns(),
      rows: getPositionsRows(),
    );
  }

  /// Returns the table columns for customer position details.
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
      TableColumn(
        width: 60.w,
        label: Text("approval.groupPosition.totalLimits".tr()),
      ),
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
        label: Text("approval.groupPosition.closeExposure".tr()),
      ),
    ];
  }

  /// Returns the table rows for present and proposed customer position values.
  List<List<Widget>> getPositionsRows() {
    final rows = <List<Widget>>[];
    final colCount = getPositionsColumns().length;
    // Row: “Present” label in first column + presentRowValues in remaining cols
    rows.add(
      List.generate(colCount, (col) {
        final String key = "${customerPosition.rimNo}_present";
        if (col == 0) {
          return const Padding(
            padding: EdgeInsets.symmetric(vertical: 4),
            child: Text("Present"), //Present row label
          );
        }
        // populate with existing CRR (presentRowValues)
        final idx = col - 1;
        if (idx < customerPosition.presentRowValues.length) {
          return Center(child: Text(customerPosition.presentRowValues[idx]));
        }
        // logger.i(
        //     "clean exposure present ${col ==
        // customerPosition.presentRowValues.length} $col $colCount
        // ${customerPosition.presentRowValues.length}");
        // clean exposure (check json key)
        if (col == 10) {
          if (viewModel.cleanExposureControllers[key] == null) {
            viewModel.cleanExposureControllers[key] =
                TextEditingController(text: "0");
          }
          return (order == 3)
              ? CustomTooltip(
                  message: viewModel.cleanExposureValues[key] ?? "0",
                  child: CustomTextField(
                    readOnly: viewModel.isReadOnly,
                    width: 118,
                    inputFormatters: [
                      DecimalInputFormatter(
                        regEx: RegExp(r"^[0-9,]{0,15}(\.\d{0,6})?$"),
                      ),
                    ],
                    // validator: !viewModel.isFIApplication
                    //     ? CustomValidator.requiredField
                    //     : null,
                    initialValue:
                        viewModel.cleanExposureControllers[key]?.text ?? "0",
                    controller: viewModel.cleanExposureControllers[key],
                    onChanged: (newValue) => viewModel.updateExposureField(
                      1,
                      customerPosition.rimNo,
                      newValue,
                      isProposed: false,
                    ),
                  ),
                )
              : (order == 1)
                  ? Center(
                      child: Text(
                        viewModel.totalPresentExposure.toString(),
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
                    );
        }
        return const SizedBox.shrink();
      }),
    );

    // Row: “Proposed” label in first column + proposedRowValues in remaining
    // cols
    if (customerPosition.proposedRowValues.isNotEmpty) {
      rows.add(
        List.generate(colCount, (col) {
          final String key = "${customerPosition.rimNo}_proposed";
          if (col == 0) {
            return const Padding(
              padding: EdgeInsets.symmetric(vertical: 4),
              child: Text("Proposed"), // Proposed row label
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
          // logger.i(
          //     "clean exposure proposed ${colCount ==
          // customerPosition.presentRowValues.length} $col $colCount
          // ${customerPosition.presentRowValues.length}");
          // clean exposure (check json key)
          if (col == 10) {
            if (viewModel.cleanExposureControllers[key] == null) {
              viewModel.cleanExposureControllers[key] =
                  TextEditingController(text: "0");
            }
            return (order == 3)
                ? CustomTooltip(
                    message: viewModel.cleanExposureValues[key] ?? "0",
                    child: CustomTextField(
                      readOnly: viewModel.isReadOnly,
                      width: 118,
                      inputFormatters: [
                        DecimalInputFormatter(
                          regEx: RegExp(r"^[0-9,]{0,15}(\.\d{0,6})?$"),
                        ),
                      ],
                      // validator: !viewModel.isFIApplication
                      //     ? CustomValidator.requiredField
                      //     : null,
                      initialValue:
                          viewModel.cleanExposureControllers[key]?.text ?? "0",
                      controller: viewModel.cleanExposureControllers[key],
                      onChanged: (newValue) => viewModel.updateExposureField(
                        1,
                        customerPosition.rimNo,
                        newValue,
                        isProposed: true,
                      ),
                    ),
                  )
                : (order == 1)
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
                      );
          }
          return const SizedBox.shrink();
        }),
      );
    }

    return rows.toList();
  }
}
