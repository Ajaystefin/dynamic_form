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

/// Displays the Central Bank Risk Bureau data table.
class CentralBankRiskTable extends StatelessWidget {
  /// Creates a [CentralBankRiskTable] widget.
  CentralBankRiskTable(this.viewModel, {required this.state, super.key});

  /// View model used by the widget.
  final FacilitiesWithOtherBanksViewModel viewModel;

  /// State used by the widget.
  final FacilitiesWithOtherBanksState state;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      spacing: 4,
      children: [
        if (state.cbrbTableLoader == LoadingStatus.loading)
          const Center(child: CircularProgressIndicator())
        else
          CustomRawTable(
            key: UniqueKey(),
            rowsPerPage: 10,
            autoFitWidth: false,
            columns: getColumns(),
            stackedHeaders: stackedHeader,
            rows: List.generate(viewModel.riskBureau?.cbrbDataList?.length ?? 0,
                (index) {
              final CBRB? info = viewModel.riskBureau?.cbrbDataList?[index];
              final int rimNo = info?.rimNo ?? 0;
              // RIM is valid only if > 0
              final bool hasValidRim = rimNo > 0;
              return [
                if (hasValidRim)
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
                if (!hasValidRim) Container(),
                // Text(info?.rimNo == null ? "--" :
                // info!.rimNo.toString()),

                CustomTooltip(
                  // isRichMessage: true,
                  message: info?.customerName == null
                      ? "--"
                      : info?.customerName.toString() ?? "",
                  child: hasValidRim
                      ? Text(info?.customerName.toString() ?? "")
                      : TextButton(
                          onPressed: (viewModel.canEdit)
                              ? () {
                                  viewModel.addCBRB(context, info);
                                }
                              : null,
                          child: Text(
                            info?.customerName == null
                                ? "--"
                                : info?.customerName.toString() ?? "",
                            style: const TextStyle(
                              decoration: TextDecoration.underline,
                              fontSize: 12,
                            ),
                          ),
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
                if ((info?.isDeletable ?? true) && viewModel.canEdit)
                  IconButton(
                    onPressed: () {
                      viewModel.deleteCBRBData(context, info);
                    },
                    icon: const Icon(Icons.delete),
                  )
                else
                  const SizedBox(),
              ];
            }),
          ),
      ],
    );
  }

  /// Stacked headers displayed in the Central Bank Risk table.
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

  /// Returns the columns displayed in the Central Bank Risk table.
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
