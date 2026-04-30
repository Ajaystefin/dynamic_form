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

class CustomerTable extends StatelessWidget {
  const CustomerTable({
    required this.viewModel,
    required this.customerPosition,
    required this.order,
    super.key,
  });
  final GroupPositionViewModel viewModel;
  final CustomerPosition customerPosition;
  final int order;

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
        // debugPrint(
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
                      false,
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
          // debugPrint(
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
                        true,
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
