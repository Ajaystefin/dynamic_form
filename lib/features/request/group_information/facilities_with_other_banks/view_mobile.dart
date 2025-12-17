import 'package:easy_localization/easy_localization.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:wcas_frontend/core/globals.dart';
import 'package:wcas_frontend/core/utils/utils.dart';
import 'package:wcas_frontend/features/layout/view.dart';
import 'package:flutter/material.dart';
import 'package:wcas_frontend/core/components/box_layout.dart';
import 'package:wcas_frontend/core/components/button.dart';
import 'package:wcas_frontend/core/components/gap.dart';
import 'package:wcas_frontend/core/components/section_header.dart';
import 'package:wcas_frontend/core/components/selectable_text.dart';
import 'package:wcas_frontend/core/components/top_section/top_section_details.dart';
import 'package:wcas_frontend/core/constants/constants.dart';
import 'package:wcas_frontend/features/request/group_information/facilities_with_other_banks/fields/cbrb_commnets.dart';
import 'package:wcas_frontend/features/request/group_information/facilities_with_other_banks/fields/central_bank_risk_table.dart';
import 'package:wcas_frontend/features/request/group_information/facilities_with_other_banks/fields/facilities_with_cbd_commnets.dart';
import 'package:wcas_frontend/features/request/group_information/facilities_with_other_banks/fields/facilities_with_other_banks_table.dart';

import 'model.dart';
import 'state.dart';

class ViewMobile extends StatelessWidget {
  const ViewMobile({super.key});

  @override
  Widget build(BuildContext context) {
    FacilitiesWithOtherBanksViewModel viewModel =
        context.read<FacilitiesWithOtherBanksViewModel>();
    return BlocBuilder<FacilitiesWithOtherBanksViewModel,
        FacilitiesWithOtherBanksState>(builder: (context, state) {
      return Layout(
        child: _body(context, state, viewModel),
      );
    });
  }

  Widget _body(BuildContext context, FacilitiesWithOtherBanksState state,
      FacilitiesWithOtherBanksViewModel viewModel) {
    switch (state.loaderStatus) {
      case LoadingStatus.loading:
        return const Center(
          child: CircularProgressIndicator(),
        );
      case LoadingStatus.error:
        return Center(
          child: Text('common.errorState'.tr()),
        );
      default:
        return BoxLayout(
          child: SingleChildScrollView(
            child: Form(
              key: viewModel.formKey,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  CustomSectionHeader(
                      title: "groupInformation.facilitiesWithOtherBanks.title"
                          .tr()),
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
                            CustomSelectableText(
                              text:
                                  "groupInformation.facilitiesWithOtherBanks.title_central"
                                      .tr(),
                              style: AppStyle.tableHeaderStyle,
                            ),
                            Align(
                              alignment: AlignmentDirectional.centerEnd,
                              child: CustomSelectableText(
                                text:
                                    "groupInformation.facilitiesWithOtherBanks.aed"
                                        .tr(),
                                style: AppStyle.tableSuffixHeaderStyle,
                              ),
                            ),
                            CentralBankRiskTable(viewModel, state: state),
                            IconButton(
                                onPressed: () {
                                  viewModel.addViewDialogClickCBRB(context);
                                },
                                icon: const Icon(Icons.add)),
                            CbrbCommnets(viewModel: viewModel, state: state),
                            const Gap(
                              size: GapSize.large,
                            ),
                            CustomSelectableText(
                              text:
                                  "groupInformation.facilitiesWithOtherBanks.title"
                                      .tr(),
                              style: AppStyle.tableHeaderStyle,
                            ),
                            Align(
                              alignment: AlignmentDirectional.centerEnd,
                              child: CustomSelectableText(
                                text:
                                    "groupInformation.facilitiesWithOtherBanks.aed"
                                        .tr(),
                                style: AppStyle.boldLabel,
                              ),
                            ),
                            FacilitiesWithOtherBanksTable(viewModel,
                                state: state),
                            IconButton(
                                onPressed: () {
                                  viewModel.addViewDialogClick(context);
                                },
                                icon: const Icon(Icons.add)),
                            FacilitiesWithCbdCommnets(
                                viewModel: viewModel, state: state),
                            const Gap(),
                            Align(
                                alignment: AlignmentDirectional.centerEnd,
                                child: CustomButton(
                                    label:
                                        'groupInformation.facilitiesWithCBD.saveContinue'
                                            .tr(),
                                    onPressed: () async {
                                      await viewModel.onSaveButtonPressed();
                                    }))
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
