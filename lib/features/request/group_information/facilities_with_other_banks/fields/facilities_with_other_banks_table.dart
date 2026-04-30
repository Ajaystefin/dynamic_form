import "package:easy_localization/easy_localization.dart";
import "package:flutter/material.dart";
import "package:wcas_frontend/core/components/custom_table/table.dart";
import "package:wcas_frontend/core/components/tooltip.dart";
import "package:wcas_frontend/core/constants/constants.dart";
import "package:wcas_frontend/core/utils/scale.dart";
import "package:wcas_frontend/core/utils/utils.dart";
import "package:wcas_frontend/features/request/group_information/facilities_with_other_banks/model.dart";
import "package:wcas_frontend/features/request/group_information/facilities_with_other_banks/state.dart";
import "package:wcas_frontend/models/request/group_information/facilities_data.dart";

class FacilitiesWithOtherBanksTable extends StatelessWidget {
  const FacilitiesWithOtherBanksTable(
    this.viewModel, {
    required this.state,
    super.key,
  });
  final FacilitiesWithOtherBanksViewModel viewModel;
  final FacilitiesWithOtherBanksState state;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      spacing: 4,
      children: [
        state.otherBankLoader == LoadingStatus.loading
            ? const Center(child: CircularProgressIndicator())
            : CustomRawTable(
                key: UniqueKey(),
                rowsPerPage: 10,
                showPagination: true,
                autoFitWidth: true,
                columns: getColumns(),
                rows: List.generate(viewModel.facilitiesOtherBanks?.length ?? 0,
                    (index) {
                  final Facility? info = viewModel.facilitiesOtherBanks?[index];
                  return [
                    TextButton(
                      onPressed: (viewModel.canEdit)
                          ? () {
                              viewModel.addOtherBank(
                                context,
                                viewModel.facilitiesOtherBanks?[index],
                              );
                            }
                          : null,
                      child: Text(
                        info?.customerRimNo.toString() ?? "",
                        style: const TextStyle(
                          decoration: TextDecoration.underline,
                          fontSize: 12,
                        ),
                      ),
                    ),
                    // CustomSelectableText(text:
                    // info?.customerRimNo.toString()),
                    CustomTooltip(
                      isRichMessage: true,
                      message: info?.customerName.toString() ?? "",
                      child: Text(info?.customerName.toString() ?? ""),
                    ),

                    // bankNameId (single id -> name)
                    Text(
                      viewModel.buildNames(
                        options: viewModel.bankNameOptions,
                        id: info?.bankNameId,
                      ),
                    ),

                    // facilityWith (list -> names)
                    CustomTooltip(
                      isRichMessage: true,
                      message: viewModel.buildNames(
                        refs: info?.facilityWith,
                        options: viewModel.typeOfFacilityOptions,
                      ),
                      child: Text(
                        viewModel.buildNames(
                          refs: info?.facilityWith,
                          options: viewModel.typeOfFacilityOptions,
                        ),
                      ),
                    ),

                    // securityWith (list -> names)
                    CustomTooltip(
                      isRichMessage: true,
                      message: viewModel.buildNames(
                        refs: info?.securityWith,
                        options: viewModel.securityOptions,
                      ),
                      child: Text(
                        viewModel.buildNames(
                          refs: info?.securityWith,
                          options: viewModel.securityOptions,
                        ),
                      ),
                    ),

                    Text(
                      info?.fundedLimit == null
                          ? "--"
                          : info?.fundedLimit.toString() ?? "",
                      style: const TextStyle(color: AppColors.darkBlue),
                    ),
                    Text(
                      info?.nonFundedLimit == null
                          ? "--"
                          : info?.nonFundedLimit.toString() ?? "",
                      style: const TextStyle(color: AppColors.darkBlue),
                    ),
                    Text(
                      info?.total == null ? "--" : info?.total.toString() ?? "",
                      style: const TextStyle(color: AppColors.darkBlue),
                    ),

                    CustomTooltip(
                      isRichMessage: true,
                      message: info?.comments ?? "",
                      child: Text(
                        info?.comments == null
                            ? "--"
                            : info?.comments.toString() ?? "",
                      ),
                    ),

                    IconButton(
                      onPressed: () {
                        viewModel.deleteOtherBankFacility(context, info);
                      },
                      icon: const Icon(Icons.delete),
                    ),
                  ];
                }),
              ),
      ],
    );
  }

  List<TableColumn> getColumns() {
    return [
      TableColumn(
        label: Text(
          "groupInformation.facilitiesWithOtherBanks.customerRIM".tr(),
        ),
      ),
      TableColumn(
        forcedWidth: 90.w,
        label: Text(
          "groupInformation.facilitiesWithOtherBanks.customerName".tr(),
        ),
      ),
      TableColumn(
        label: Text(
          "groupInformation.facilitiesWithOtherBanks.nameofBanks".tr(),
        ),
      ),
      TableColumn(
        forcedWidth: 90.w,
        label: Text(
          "groupInformation.facilitiesWithOtherBanks.typeOfFacility".tr(),
        ),
      ),
      TableColumn(
        forcedWidth: 90.w,
        label: Text("groupInformation.facilitiesWithOtherBanks.security".tr()),
      ),
      TableColumn(
        forcedWidth: 90.w,
        label: Text("groupInformation.facilitiesWithOtherBanks.funded".tr()),
      ),
      TableColumn(
        forcedWidth: 90.w,
        label: Text("groupInformation.facilitiesWithOtherBanks.nonFunded".tr()),
      ),
      TableColumn(
        forcedWidth: 90.w,
        label: Text("groupInformation.facilitiesWithOtherBanks.total".tr()),
      ),
      TableColumn(
        forcedWidth: 120.w,
        label: Text("groupInformation.facilitiesWithOtherBanks.comments".tr()),
      ),
      TableColumn(
        label: Text("groupInformation.facilitiesWithOtherBanks.delete".tr()),
      ),
    ];
  }
}
