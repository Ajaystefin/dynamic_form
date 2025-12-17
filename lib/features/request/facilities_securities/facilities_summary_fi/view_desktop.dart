import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/cupertino.dart';
import 'package:wcas_frontend/core/constants/constants.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:wcas_frontend/core/components/accordion.dart';
import 'package:wcas_frontend/core/components/box_layout.dart';
import 'package:wcas_frontend/core/components/button.dart';
import 'package:wcas_frontend/core/components/gap.dart';
import 'package:wcas_frontend/core/components/section_header.dart';
import 'package:wcas_frontend/core/components/top_section/top_section_details.dart';
import 'package:wcas_frontend/core/globals.dart';
import 'package:wcas_frontend/core/services/route_service.dart';
import 'package:wcas_frontend/core/utils/utils.dart';
import 'package:wcas_frontend/features/layout/model.dart';
import 'package:wcas_frontend/features/layout/view.dart';
import 'package:flutter/material.dart';
// import 'package:wcas_frontend/features/request/facilities_securities/facilities_summary_fi/widgets/fi_table.dart';
// import 'package:wcas_frontend/features/request/facilities_securities/facilities_summary_fi/widgets/overall_total_table.dart';
// import 'package:wcas_frontend/models/request/facility_security/facility_summary.dart';
import 'package:wcas_frontend/models/request/facility_security/facility_summary_list.dart';
import 'package:wcas_frontend/models/request/request.dart';
import 'model.dart';
import 'state.dart';

class ViewDesktop extends StatelessWidget {
  const ViewDesktop({super.key});

  @override
  Widget build(BuildContext context) {
    FacilitiesSummaryFiViewModel viewModel =
        context.read<FacilitiesSummaryFiViewModel>();
    return BlocBuilder<FacilitiesSummaryFiViewModel, FacilitiesSummaryFiState>(
        builder: (context, state) {
      return Layout(
        child: _body(context, state, viewModel),
      );
    });
  }

  Widget _body(BuildContext context, FacilitiesSummaryFiState state,
      FacilitiesSummaryFiViewModel viewModel) {
    switch (state.loaderStatus) {
      case LoadingStatus.loading:
        return const Center(
          child: CircularProgressIndicator(),
        );

      default:
        return buildView(viewModel, state);
    }
  }

  Widget buildView(
    FacilitiesSummaryFiViewModel viewModel,
    FacilitiesSummaryFiState state,
  ) {
    return SingleChildScrollView(
      child: BoxLayout(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          spacing: 10,
          children: [
            CustomSectionHeader(title: "facilities.facilitySummary.title".tr()),
            BoxLayout(
                child:
                    TopSectionDetails(request: Globals.request ?? Request())),
            ListView.builder(
              physics: const NeverScrollableScrollPhysics(),
              shrinkWrap: true,
              itemBuilder: (context, i) {
                FacilitySummaryList? customer =
                    viewModel.customerFacilities?[i];
                if (customer == null) return const SizedBox.shrink();
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 6),
                  child: CustomAccordion(
                    title: //${viewModel.customerFacilities?[i].custName}
                        "India (${viewModel.customerFacilities?[i].rims?[i].rimNo})",
                    children: (() {
                      switch (state.tableLoaderStatus) {
                        case LoadingStatus.loading:
                          return [
                            const BoxLayout(
                              child: Center(
                                child: CupertinoActivityIndicator(radius: 30),
                              ),
                            ),
                          ];

                        default:
                          return [
                            // FinancialInstitutionTable(
                            //   viewModel: viewModel,
                            //   facilityGroup:
                            //       customer.generalWorkingCapitalLimits,
                            //   customer: customer,
                            //   tableTitle:
                            //       "facilities.facilitySummary.trade".tr(),
                            // ),
                            // FinancialInstitutionTable(
                            //   viewModel: viewModel,
                            //   facilityGroup:
                            //       customer.generalWorkingCapitalLimits,
                            //   customer: customer,
                            //   tableTitle: "facilities.facilitySummary.dcm".tr(),
                            // ),
                            // FinancialInstitutionTable(
                            //   viewModel: viewModel,
                            //   tableTitle:
                            //       "facilities.facilitySummary.bilateral".tr(),
                            //   facilityGroup:
                            //       customer.generalWorkingCapitalLimits,
                            //   customer: customer,
                            // ),
                            // FinancialInstitutionTable(
                            //   viewModel: viewModel,
                            //   tableTitle:
                            //       "facilities.facilitySummary.treasury".tr(),
                            //   facilityGroup:
                            //       customer.generalWorkingCapitalLimits,
                            //   customer: customer,
                            // ),
                            // FinancialInstitutionTable(
                            //   viewModel: viewModel,
                            //   tableTitle:
                            //       "facilities.facilitySummary.crossBoarder"
                            //           .tr(),
                            //   facilityGroup:
                            //       customer.generalWorkingCapitalLimits,
                            //   customer: customer,
                            // ),
                            // FinancialInstitutionTable(
                            //   viewModel: viewModel,
                            //   tableTitle:
                            //       "facilities.facilitySummary.sovereign".tr(),
                            //   facilityGroup:
                            //       customer.generalWorkingCapitalLimits,
                            //   customer: customer,
                            // ),
                            // OverallTotalFiTable(
                            //   viewModel: viewModel,
                            //   overallTotal:
                            //       viewModel.customerFacilities?[i].overallTotal,
                            // ),
                            const Gap(),
                            Align(
                              alignment: Alignment.bottomRight,
                              child: CustomButton(
                                label: "common.save".tr(),
                                onPressed: () {
                                  // viewModel.saveFacilityDetails(customer);
                                },
                              ),
                            )
                          ];
                      }
                    })(),
                  ),
                );
              },
              itemCount: viewModel.customerFacilities?.length,
            ),
            const Gap(),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                CustomButton(
                    label: "facilities.createFacility.title".tr(),
                    onPressed: () {
                      router.go(Routes.createFacility);
                    }),
                const Gap(direction: Axis.horizontal),
                CustomButton(
                    label: "common.continue".tr(),
                    onPressed: () {
                      LayoutViewModel().goToNextRoute();
                    }),
                const Gap(direction: Axis.horizontal)
              ],
            )
          ],
        ),
      ),
    );
  }
}
