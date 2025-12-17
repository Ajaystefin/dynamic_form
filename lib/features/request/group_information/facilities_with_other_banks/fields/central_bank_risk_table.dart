import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';

import 'package:wcas_frontend/core/components/custom_table/table.dart';
import 'package:wcas_frontend/core/constants/constants.dart';
import 'package:wcas_frontend/core/utils/dialog_helper.dart';
import 'package:wcas_frontend/core/utils/scale.dart';
import 'package:wcas_frontend/core/utils/utils.dart';
import 'package:wcas_frontend/features/request/group_information/add_cbrb_dialog/view.dart';
import 'package:wcas_frontend/features/request/group_information/facilities_with_other_banks/model.dart';
import 'package:wcas_frontend/features/request/group_information/facilities_with_other_banks/state.dart';
import 'package:wcas_frontend/models/request/group_information/cbrb_data.dart';

class CentralBankRiskTable extends StatelessWidget {
  final FacilitiesWithOtherBanksViewModel viewModel;
  final FacilitiesWithOtherBanksState state;
  CentralBankRiskTable(this.viewModel, {super.key, required this.state});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      spacing: 4,
      children: [
        state.tableLoader == LoadingStatus.loading
            ? const Center(child: CircularProgressIndicator())
            : CustomRawTable(
                key: UniqueKey(),
                showPagination: true,
                autoFitWidth: false,
                columns: getColumns(),
                stackedHeaders: stackedHeader,
                rows: List.generate(
                    viewModel.riskBureau?.cbrbDataList?.length ?? 0, (index) {
                  final CBRB? info = viewModel.riskBureau?.cbrbDataList?[index];
                  return [
                    TextButton(
                      onPressed: () {
                        DialogHelper.showCustomDialog(
                          barrierDismissible: false,
                          title:
                              'groupInformation.facilitiesWithOtherBanks.title_central'
                                  .tr(),
                          content: SizedBox(
                              child: AddCbrbDialogView(
                            cbrb: info,
                          )),
                          context: context,
                        );
                      },
                      child: Text(
                        info?.rimNo.toString() ?? '',
                        style: const TextStyle(
                            decoration: TextDecoration.underline,
                            decorationColor: AppColors.darkBlue,
                            fontSize: 12),
                      ),
                    ),
                    // Text(info?.rimNo == null ? "--" : info!.rimNo.toString()),
                    Text(info?.customerName == null
                        ? "--"
                        : info?.customerName.toString() ?? ''),
                    Text(info?.fundedLimitAllBanks == null
                        ? "--"
                        : info!.fundedLimitAllBanks.toString()),
                    Text(info?.fundedOutstandingAllBanks == null
                        ? "--"
                        : info?.fundedOutstandingAllBanks.toString() ?? ''),
                    Text(info?.nonFundedLimitAllBanks == null
                        ? "--"
                        : info?.nonFundedLimitAllBanks.toString() ?? ''),
                    Text(info?.nonFundedOutstandingAllBanks == null
                        ? "--"
                        : info?.nonFundedOutstandingAllBanks.toString() ?? ''),
                    Text(info?.noOfBanks == null
                        ? "--"
                        : info?.noOfBanks.toString() ?? ''),
                    Text(
                      info?.cbrbClassifications == null
                          ? "--"
                          : info?.cbrbClassifications.toString() ?? '',
                    ),
                  ];
                }),
              ),
      ],
    );
  }

  final List<StackedHeader> stackedHeader = [
    StackedHeader(
        startIndex: 2,
        endIndex: 3,
        width: 200.w,
        widget: Text("groupInformation.facilitiesWithOtherBanks.direct".tr())),
    StackedHeader(
        startIndex: 4,
        endIndex: 5,
        width: 200.w,
        widget:
            Text("groupInformation.facilitiesWithOtherBanks.indirect".tr())),
  ];

  List<TableColumn> getColumns() {
    return [
      TableColumn(
          width: 70.w,
          label: Text(
              "groupInformation.facilitiesWithOtherBanks.customerRIM".tr())),
      TableColumn(
          width: 100.w,
          label: Text(
              "groupInformation.facilitiesWithOtherBanks.customerName".tr())),
      TableColumn(
          width: 100.w,
          label: Text("groupInformation.facilitiesWithOtherBanks.limits".tr()),
          isStacked: true),
      TableColumn(
          width: 100.w,
          label: Text("groupInformation.facilitiesWithOtherBanks.os".tr()),
          isStacked: true),
      TableColumn(
          width: 100.w,
          label: Text("groupInformation.facilitiesWithOtherBanks.limits".tr()),
          isStacked: true),
      TableColumn(
          width: 100.w,
          label: Text("groupInformation.facilitiesWithOtherBanks.os".tr()),
          isStacked: true),
      TableColumn(
          width: 120.w,
          label: Text(
              "groupInformation.facilitiesWithOtherBanks.numberofBanks".tr())),
      TableColumn(
          width: 95.w,
          label: Text(
              "groupInformation.facilitiesWithOtherBanks.CBRBClassification"
                  .tr())),
    ];
  }
}
