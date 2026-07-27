import "package:easy_localization/easy_localization.dart";
import "package:flutter/material.dart";

import "package:wcas_frontend/core/components/custom_table/table.dart";
import "package:wcas_frontend/core/components/tooltip.dart";
import "package:wcas_frontend/core/constants/constants.dart";
import "package:wcas_frontend/core/utils/scale.dart";
import "package:wcas_frontend/features/request/approval/guarantors_exposure/model.dart";

/// Displays guarantors exposure details in a custom raw table.
class GuarantorsExposureTable extends StatelessWidget {
  /// Creates the guarantors exposure table widget.
  const GuarantorsExposureTable({required this.viewModel, super.key});

  /// View model used to provide guarantors exposure data and calculated values.
  final GuarantorsExposureViewModel viewModel;

  @override
  Widget build(BuildContext context) {
    return CustomRawTable(
      key: UniqueKey(),
      columnHeaderHeight: 80.w,
      columns: [
        // TableColumn(
        //     forcedWidth: 55.w,
        //     label: Center(
        //       child: Text('approval.guarantorsExposure.customerName'.tr()),
        //     )),
        TableColumn(
          forcedWidth: 90.w,
          label: Center(
            child: Text("approval.guarantorsExposure.guarantorName".tr()),
          ),
        ),
        // TableColumn(
        //     forcedWidth: 50.w,
        //     label: Center(
        //       child: Text('approval.guarantorsExposure.existingCrr'.tr()),
        //     )),
        // TableColumn(
        //     forcedWidth: 50.w,
        //     label: Center(
        //       child: Text('approval.guarantorsExposure.proposedCrr'.tr()),
        //     )),
        TableColumn(
          forcedWidth: 45.w,
          label: Center(
            child: Text("approval.guarantorsExposure.fundBasedLimits".tr()),
          ),
        ),
        TableColumn(
          forcedWidth: 50.w,
          label: Center(
            child: Text("approval.guarantorsExposure.nonFundBasedLimits".tr()),
          ),
        ),
        TableColumn(
          forcedWidth: 45.w,
          label: Center(
            child: Text("approval.guarantorsExposure.totalLimits".tr()),
          ),
        ),
        TableColumn(
          forcedWidth: 80.w,
          label: Center(
            child: Text(
              "approval.guarantorsExposure.totalTangibleSecurities".tr(),
            ),
          ),
        ),
        TableColumn(
          forcedWidth: 50.w,
          label: Center(
            child: Text(
              "approval.guarantorsExposure.ofWhichCashCollateral".tr(),
            ),
          ),
        ),
        TableColumn(
          forcedWidth: 80.w,
          label: Center(
            child: Text(
              "approval.guarantorsExposure.totalTotalTangibleSecurities".tr(),
            ),
          ),
        ),
        TableColumn(
          forcedWidth: 80.w,
          label: Center(
            child: Text(
              "approval.guarantorsExposure.totalCashColletralOnly".tr(),
            ),
          ),
        ),
        TableColumn(
          forcedWidth: 80.w,
          label: Center(
            child: Text("approval.guarantorsExposure.cleanExposure".tr()),
          ),
        ),
      ],
      rows: viewModel.guarantorList
          .map(
            (p) => [
              // Center(child: Text('${p.rimNo}')),
              CustomTooltip(
                message: "${p.custName?.trim()}",
                child: Center(child: Text("${p.custName?.trim()}")),
              ),
              // Center(child: Text('${p.presentNetSecurity}')),
              // Center(child: Text('${p.presentNetCC}')),
              Center(child: Text("${p.fundedPresentLimit}")),
              Center(child: Text("${p.nonFundedPresentLimit}")),
              // Center(child: Text('${p.tangiblePresentSecurity}')),
              Center(
                child: Text(
                  "${p.totalFundNonfund ?? 0}",
                ),
              ), // total = funded + non funded
              Center(child: Text("${p.totalTangiblePresentSecurity}")),
              Center(child: Text("${p.totalCCPresentSecurity}")),
              Center(
                child: Text(
                  "${p.calTotalTangible ?? 0}",
                ),
              ), // = total - totalTangiblePresentSecurity
              Center(
                child: Text(
                  "${p.calofWhichCash ?? 0}",
                ),
              ), // = total - ofwhichco
              Center(
                child: Text(
                  "${viewModel.cleanExposureValues[p.rimNo.toString()] ?? 0}",
                  style: const TextStyle(color: AppColors.highlightedTextColor),
                ),
              ), // clean exposure (check json key)
            ],
          )
          .toList(),
    );
  }
}
