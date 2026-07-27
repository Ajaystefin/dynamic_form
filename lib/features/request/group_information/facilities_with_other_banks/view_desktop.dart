import "package:easy_localization/easy_localization.dart";
import "package:flutter/material.dart";
import "package:flutter_bloc/flutter_bloc.dart";

import "package:wcas_frontend/core/components/add_item_button.dart";
import "package:wcas_frontend/core/components/box_layout.dart";
import "package:wcas_frontend/core/components/button.dart";
import "package:wcas_frontend/core/components/gap.dart";
import "package:wcas_frontend/core/components/section_header.dart";
import "package:wcas_frontend/core/components/selectable_text.dart";
import "package:wcas_frontend/core/components/top_section/top_section_details.dart";
import "package:wcas_frontend/core/constants/constants.dart";
import "package:wcas_frontend/core/globals.dart";
import "package:wcas_frontend/core/utils/utils.dart";
import "package:wcas_frontend/features/layout/view.dart";
import "package:wcas_frontend/features/request/group_information/facilities_with_other_banks/fields/cbrb_commnets.dart";
import "package:wcas_frontend/features/request/group_information/facilities_with_other_banks/fields/central_bank_risk_table.dart";
import "package:wcas_frontend/features/request/group_information/facilities_with_other_banks/fields/facilities_with_cbd_commnets.dart";
import "package:wcas_frontend/features/request/group_information/facilities_with_other_banks/fields/facilities_with_other_banks_table.dart";
import "package:wcas_frontend/features/request/group_information/facilities_with_other_banks/model.dart";
import "package:wcas_frontend/features/request/group_information/facilities_with_other_banks/state.dart";

/// Desktop view for the Facilities with Other Banks feature.
class ViewDesktop extends StatelessWidget {
  /// Creates a [ViewDesktop] widget.
  const ViewDesktop({super.key});

  @override
  Widget build(BuildContext context) {
    final FacilitiesWithOtherBanksViewModel viewModel =
        context.read<FacilitiesWithOtherBanksViewModel>();
    return BlocBuilder<FacilitiesWithOtherBanksViewModel,
        FacilitiesWithOtherBanksState>(
      builder: (context, state) {
        return Layout(
          child: _body(context, state, viewModel),
        );
      },
    );
  }

  Widget _body(
    BuildContext context,
    FacilitiesWithOtherBanksState state,
    FacilitiesWithOtherBanksViewModel viewModel,
  ) {
    switch (state.loaderStatus) {
      case LoadingStatus.loading:
        return const Center(
          child: CircularProgressIndicator(),
        );
      case LoadingStatus.error:
        return Center(
          child: Text("common.errorState".tr()),
        );
      default:
        return BoxLayout(
          child: SingleChildScrollView(
            child: Form(
              key: viewModel.formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  CustomSectionHeader(
                    title:
                        "groupInformation.facilitiesWithOtherBanks.title".tr(),
                  ),
                  const Gap(),
                  Column(
                    children: [
                      BoxLayout(
                        child: TopSectionDetails(
                          request: Globals.request!,
                        ),
                      ),
                      BoxLayout(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                CustomSelectableText(
                                  text: "groupInformation."
                                          "facilitiesWithOtherBanks"
                                          ".title_central"
                                      .tr(),
                                  semanticsLabel: "groupInformation."
                                          "facilitiesWithOtherBanks"
                                          ".title_central"
                                      .tr(),
                                  style: AppStyle.tableHeaderStyle,
                                ),
                                const Gap(),
                                CustomSelectableText(
                                  text: "groupInformation."
                                          "facilitiesWithOtherBanks.aed"
                                      .tr(),
                                  style: AppStyle.tableSuffixHeaderStyle,
                                  semanticsLabel: "groupInformation."
                                          "facilitiesWithOtherBanks.aed"
                                      .tr(),
                                ),
                              ],
                            ),
                            const Gap(),
                            CentralBankRiskTable(viewModel, state: state),
                            if ((viewModel.riskBureau?.cbrbDataList ?? [])
                                .isEmpty)
                              const Center(child: Text("No data ")),
                            const Gap(),
                            if (viewModel.canEdit)
                              AddItemButton(
                                onTap: () => viewModel.addCBRB(context, null),
                                isLeftSided: true,
                                child: Text(
                                  "groupInformation."
                                          "facilitiesWithOtherBanks.addCBRB"
                                      .tr(),
                                  style: const TextStyle(
                                    fontSize: AppStyle.fontSizeSmall,
                                  ),
                                ),
                              ),
                            CbrbCommnets(viewModel: viewModel, state: state),
                            const Gap(
                              size: GapSize.large,
                            ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                CustomSelectableText(
                                  text: "groupInformation."
                                          "facilitiesWithOtherBanks.title"
                                      .tr(),
                                  semanticsLabel: "groupInformation."
                                          "facilitiesWithOtherBanks.title"
                                      .tr(),
                                  style: AppStyle.tableHeaderStyle,
                                ),
                                const Gap(),
                                CustomSelectableText(
                                  text: "groupInformation."
                                          "facilitiesWithOtherBanks.aed"
                                      .tr(),
                                  semanticsLabel: "groupInformation."
                                          "facilitiesWithOtherBanks.aed"
                                      .tr(),
                                  style: AppStyle.tableSuffixHeaderStyle,
                                ),
                              ],
                            ),
                            const Gap(),
                            FacilitiesWithOtherBanksTable(
                              viewModel,
                              state: state,
                            ),
                            if ((viewModel.facilitiesOtherBanks ?? []).isEmpty)
                              const Center(child: Text("No data ")),
                            const Gap(),
                            if (viewModel.canEdit)
                              AddItemButton(
                                onTap: () =>
                                    viewModel.addOtherBank(context, null),
                                isLeftSided: true,
                                child: Text(
                                  "groupInformation."
                                          "facilitiesWithOtherBanks"
                                          ".addOtherBank"
                                      .tr(),
                                  style: const TextStyle(
                                    fontSize: AppStyle.fontSizeSmall,
                                  ),
                                ),
                              ),
                            const Gap(),
                            FacilitiesWithCbdCommnets(
                              viewModel: viewModel,
                              state: state,
                            ),
                            const Gap(),
                            if (viewModel.canEdit ||
                                viewModel.isCancellationApp)
                              Align(
                                alignment: AlignmentDirectional.centerEnd,
                                child: CustomButton(
                                  label: "groupInformation."
                                          "facilitiesWithCBD.saveContinue"
                                      .tr(),
                                  semanticLabel: "groupInformation."
                                          "facilitiesWithCBD.saveContinue"
                                      .tr(),
                                  onPressed: () async {
                                    await viewModel.onSaveComment();
                                  },
                                ),
                              ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        );
    }
  }
}
