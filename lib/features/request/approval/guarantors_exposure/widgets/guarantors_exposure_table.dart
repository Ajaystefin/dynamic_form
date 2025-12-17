import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:wcas_frontend/core/utils/scale.dart';
import 'package:wcas_frontend/core/utils/text_utils.dart';
import 'package:wcas_frontend/core/components/custom_table/table.dart';
import 'package:wcas_frontend/core/components/tooltip.dart';
import 'package:wcas_frontend/features/request/approval/guarantors_exposure/model.dart';

class GuarantorsExposureTable extends StatelessWidget {
  final GuarantorsExposureViewModel viewModel;
  const GuarantorsExposureTable({super.key, required this.viewModel});

  @override
  Widget build(BuildContext context) {
    return CustomRawTable(
      key: UniqueKey(),
      columnHeaderHeight: 80.w,
      autoFitWidth: true,
      columns: [
        TableColumn(
            forcedWidth: 55.w,
            label: Center(
              child: Text('approval.guarantorsExposure.customerName'.tr()),
            )),
        TableColumn(
            forcedWidth: 90.w,
            label: Center(
              child: Text('approval.guarantorsExposure.guarantorName'.tr()),
            )),
        TableColumn(
            forcedWidth: 50.w,
            label: Center(
              child: Text('approval.guarantorsExposure.existingCrr'.tr()),
            )),
        TableColumn(
            forcedWidth: 50.w,
            label: Center(
              child: Text('approval.guarantorsExposure.proposedCrr'.tr()),
            )),
        TableColumn(
            forcedWidth: 45.w,
            label: Center(
              child: Text('approval.guarantorsExposure.fundBasedLimits'.tr()),
            )),
        TableColumn(
            forcedWidth: 50.w,
            label: Center(
              child:
                  Text('approval.guarantorsExposure.nonFundBasedLimits'.tr()),
            )),
        TableColumn(
            forcedWidth: 45.w,
            label: Center(
              child: Text('approval.guarantorsExposure.totalLimits'.tr()),
            )),
        TableColumn(
            forcedWidth: 80.w,
            label: Center(
              child: Text(
                  'approval.guarantorsExposure.totalTangibleSecurities'.tr()),
            )),
        TableColumn(
            forcedWidth: 50.w,
            label: Center(
              child: Text(
                  'approval.guarantorsExposure.ofWhichCashCollateral'.tr()),
            )),
        TableColumn(
            forcedWidth: 80.w,
            label: Center(
              child: Text(
                  'approval.guarantorsExposure.totalTotalTangibleSecurities'
                      .tr()),
            )),
        TableColumn(
            forcedWidth: 80.w,
            label: Center(
              child: Text(
                  'approval.guarantorsExposure.totalCashColletralOnly'.tr()),
            )),
      ],
      rows: viewModel.guarantorList
          .map((p) => [
                Center(child: Text('${p.rimNo}')),
                CustomTooltip(
                    message: '${p.custName?.capitalizeFirstLetter()}',
                    child: Center(
                        child: Text('${p.custName?.capitalizeFirstLetter()}'))),
                Center(child: Text('${p.presentNetSecurity}')),
                Center(child: Text('${p.presentNetCC}')),
                Center(child: Text('${p.fundedPresentLimit}')),
                Center(child: Text('${p.nonFundedPresentLimit}')),
                Center(child: Text('${p.tangiblePresentSecurity}')),
                Center(child: Text('${p.ccPresentSecurity}')),
                Center(child: Text('${p.totalTangiblePresentSecurity}')),
                Center(child: Text('${p.hasFacility}')),
                Center(child: Text('${p.totalPresentLimits}')),
              ])
          .toList(),
    );
  }
}
