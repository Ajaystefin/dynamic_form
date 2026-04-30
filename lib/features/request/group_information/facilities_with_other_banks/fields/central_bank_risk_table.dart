import "package:easy_localization/easy_localization.dart";
import "package:flutter/material.dart";
import "package:wcas_frontend/core/components/custom_table/table.dart";
import "package:wcas_frontend/core/components/tooltip.dart";
import "package:wcas_frontend/core/constants/constants.dart";
import "package:wcas_frontend/core/utils/scale.dart";
import "package:wcas_frontend/core/utils/utils.dart";
import "package:wcas_frontend/features/request/group_information/facilities_with_other_banks/model.dart";
import "package:wcas_frontend/features/request/group_information/facilities_with_other_banks/state.dart";
import "package:wcas_frontend/models/request/group_information/cbrb_data.dart";

class CentralBankRiskTable extends StatelessWidget {
  CentralBankRiskTable(this.viewModel, {required this.state, super.key});
  final FacilitiesWithOtherBanksViewModel viewModel;
  final FacilitiesWithOtherBanksState state;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      spacing: 4,
      children: [
        state.cbrbTableLoader == LoadingStatus.loading
            ? const Center(child: CircularProgressIndicator())
            : CustomRawTable(
                key: UniqueKey(),
                showPagination: true,
                rowsPerPage: 10,
                autoFitWidth: false,
                columns: getColumns(),
                stackedHeaders: stackedHeader,
                rows: List.generate(
                    viewModel.riskBureau?.cbrbDataList?.length ?? 0, (index) {
                  final CBRB? info = viewModel.riskBureau?.cbrbDataList?[index];
                  return [
                    TextButton(
                      onPressed: (viewModel.canEdit)
                          ? () {
                              viewModel.addCBRB(context, info);
                            }
                          : null,
                      child: Text(
                        info?.rimNo.toString() ?? "",
                        style: const TextStyle(
                          decoration: TextDecoration.underline,
                          fontSize: 12,
                        ),
                      ),
                    ),
                    // Text(info?.rimNo == null ? "--" :
                    // info!.rimNo.toString()),
                    CustomTooltip(
                      isRichMessage: true,
                      message: info?.customerName == null
                          ? "--"
                          : info?.customerName.toString() ?? "",
                      child: Text(
                        info?.customerName == null
                            ? "--"
                            : info?.customerName.toString() ?? "",
                      ),
                    ),

                    Text(
                      info?.directLimit == null
                          ? "--"
                          : info!.directLimit.toString(),
                      style: const TextStyle(color: AppColors.darkBlue),
                    ),
                    Text(
                      info?.directOutstanding == null
                          ? "--"
                          : info?.directOutstanding.toString() ?? "",
                      style: const TextStyle(color: AppColors.darkBlue),
                    ),
                    Text(
                      info?.indirectLimit == null
                          ? "--"
                          : info?.indirectLimit.toString() ?? "",
                      style: const TextStyle(color: AppColors.darkBlue),
                    ),
                    Text(
                      info?.indirectOutstanding == null
                          ? "--"
                          : info?.indirectOutstanding.toString() ?? "",
                      style: const TextStyle(color: AppColors.darkBlue),
                    ),
                    Text(
                      info?.noOfBanks == null
                          ? "--"
                          : info?.noOfBanks.toString() ?? "",
                      style: const TextStyle(color: AppColors.darkBlue),
                    ),
                    Text(
                      info?.cbrbClassifications == null
                          ? "--"
                          : info?.cbrbClassifications.toString() ?? "",
                    ),
                    (info?.isDeletable ?? true)
                        ? IconButton(
                            onPressed: () {
                              viewModel.deleteCBRBData(context, info);
                            },
                            icon: const Icon(Icons.delete),
                          )
                        : const SizedBox(),
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
      widget: Text("groupInformation.facilitiesWithOtherBanks.direct".tr()),
    ),
    StackedHeader(
      startIndex: 4,
      endIndex: 5,
      width: 200.w,
      widget: Text("groupInformation.facilitiesWithOtherBanks.indirect".tr()),
    ),
  ];

  List<TableColumn> getColumns() {
    return [
      TableColumn(
        width: 70.w,
        label: Text(
          "groupInformation.facilitiesWithOtherBanks.customerRIM".tr(),
        ),
      ),
      TableColumn(
        width: 100.w,
        label: Text(
          "groupInformation.facilitiesWithOtherBanks.customerName".tr(),
        ),
      ),
      TableColumn(
        width: 100.w,
        label: Text("groupInformation.facilitiesWithOtherBanks.limits".tr()),
        isStacked: true,
      ),
      TableColumn(
        width: 100.w,
        label: Text("groupInformation.facilitiesWithOtherBanks.os".tr()),
        isStacked: true,
      ),
      TableColumn(
        width: 100.w,
        label: Text("groupInformation.facilitiesWithOtherBanks.limits".tr()),
        isStacked: true,
      ),
      TableColumn(
        width: 100.w,
        label: Text("groupInformation.facilitiesWithOtherBanks.os".tr()),
        isStacked: true,
      ),
      TableColumn(
        width: 70.w,
        label: Text(
          "groupInformation.facilitiesWithOtherBanks.numberofBanks".tr(),
        ),
      ),
      TableColumn(
        width: 95.w,
        label: Text(
          "groupInformation.facilitiesWithOtherBanks.CBRBClassification".tr(),
        ),
      ),
      TableColumn(
        width: 45.w,
        label: Text("groupInformation.facilitiesWithOtherBanks.delete".tr()),
      ),
    ];
  }
}
