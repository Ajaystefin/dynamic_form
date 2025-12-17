import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';

import 'package:wcas_frontend/core/components/custom_table/table.dart';
import 'package:wcas_frontend/core/constants/constants.dart';
import 'package:wcas_frontend/core/utils/dialog_helper.dart';
import 'package:wcas_frontend/core/utils/utils.dart';
import 'package:wcas_frontend/features/request/group_information/add_other_bank_dialog/view.dart';
import 'package:wcas_frontend/features/request/group_information/facilities_with_other_banks/model.dart';
import 'package:wcas_frontend/features/request/group_information/facilities_with_other_banks/state.dart';
import 'package:wcas_frontend/models/request/group_information/facilities_data.dart';

class FacilitiesWithOtherBanksTable extends StatelessWidget {
  final FacilitiesWithOtherBanksViewModel viewModel;
  final FacilitiesWithOtherBanksState state;
  const FacilitiesWithOtherBanksTable(this.viewModel,
      {super.key, required this.state});

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
                rowsPerPage: 5,
                showPagination: true,
                columns: getColumns(),
                rows: List.generate(
                    viewModel.facilitiesOtherBanks?.facilitiesList?.length ?? 0,
                    (index) {
                  final Facility? info =
                      viewModel.facilitiesOtherBanks?.facilitiesList?[index];
                  return [
                    TextButton(
                      onPressed: () {
                        DialogHelper.showCustomDialog(
                          barrierDismissible: false,
                          title:
                              'groupInformation.facilitiesWithOtherBanks.title'
                                  .tr(),
                          content: SizedBox(
                              child: AddOtherBankDialogView(
                            facilities: viewModel
                                .facilitiesOtherBanks?.facilitiesList?[index],
                          )),
                          context: context,
                        );
                      },
                      child: Text(
                        info?.customerRimNo.toString() ?? '',
                        style: const TextStyle(
                            decoration: TextDecoration.underline,
                            decorationColor: AppColors.darkBlue,
                            fontSize: 12),
                      ),
                    ),
                    // CustomSelectableText(text: info?.customerRimNo.toString()),
                    Text(info?.customerName.toString() ?? ''),

                    // bankNameId (single id -> name)
                    Text(
                      viewModel.buildNames(
                        options: viewModel.bankNameOptions,
                        id: info?.bankNameId,
                      ),
                    ),

                    // facilityWith (list -> names)
                    Text(
                      viewModel.buildNames(
                        refs: info?.facilityWith,
                        options: viewModel.typeOfFacilityOptions,
                      ),
                    ),

                    // securityWith (list -> names)
                    Text(
                      viewModel.buildNames(
                        refs: info?.securityWith,
                        options: viewModel.securityOptions,
                      ),
                    ),

                    Text(info?.fundedLimit == null
                        ? "--"
                        : info?.fundedLimit.toString() ?? ''),
                    Text(info?.nonFundedLimit == null
                        ? "--"
                        : info?.nonFundedLimit.toString() ?? ''),
                    Text(info?.total == null
                        ? "--"
                        : info?.total.toString() ?? ''),
                    Text(info?.comments == null
                        ? "--"
                        : info?.comments.toString() ?? ''),
                    (info?.deleted ?? false)
                        ? IconButton(
                            onPressed: () {
                              viewModel.showDeletionDialog(context);
                            },
                            icon: const Icon(Icons.delete))
                        : IconButton(
                            onPressed: () {
                              // click dialog You cannot Delete already Existing Data
                              viewModel.showDeletionDialog(context);
                            },
                            icon: const Icon(Icons.delete))
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
              "groupInformation.facilitiesWithOtherBanks.customerRIM".tr())),
      TableColumn(
          label: Text(
              "groupInformation.facilitiesWithOtherBanks.customerName".tr())),
      TableColumn(
          label: Text(
              "groupInformation.facilitiesWithOtherBanks.nameofBanks".tr())),
      TableColumn(
          label: Text(
              "groupInformation.facilitiesWithOtherBanks.typeOfFacility".tr())),
      TableColumn(
          label:
              Text("groupInformation.facilitiesWithOtherBanks.security".tr())),
      TableColumn(
          label: Text("groupInformation.facilitiesWithOtherBanks.funded".tr())),
      TableColumn(
          label:
              Text("groupInformation.facilitiesWithOtherBanks.nonFunded".tr())),
      TableColumn(
          label: Text("groupInformation.facilitiesWithOtherBanks.total".tr())),
      TableColumn(
          label:
              Text("groupInformation.facilitiesWithOtherBanks.comments".tr())),
      TableColumn(
          label: Text("groupInformation.facilitiesWithOtherBanks.delete".tr())),
    ];
  }
}
