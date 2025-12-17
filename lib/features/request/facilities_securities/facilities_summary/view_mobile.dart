import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/cupertino.dart' show CupertinoActivityIndicator;
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:wcas_frontend/core/components/accordion.dart';
import 'package:wcas_frontend/core/components/box_layout.dart';
import 'package:wcas_frontend/core/components/button.dart';
import 'package:wcas_frontend/core/components/section_header.dart';
import 'package:wcas_frontend/core/components/top_section/top_section_details.dart';
import 'package:wcas_frontend/core/globals.dart';
import 'package:wcas_frontend/core/utils/utils.dart';
import 'package:wcas_frontend/features/layout/view.dart';
import 'package:flutter/material.dart';
// import 'package:wcas_frontend/features/request/facilities_securities/facilities_summary/widgets/general_working_capital_limit_table.dart';
// import 'package:wcas_frontend/features/request/facilities_securities/facilities_summary/widgets/loans_table.dart';
// import 'package:wcas_frontend/features/request/facilities_securities/facilities_summary/widgets/overall_total_table.dart';
// import 'package:wcas_frontend/features/request/facilities_securities/facilities_summary/widgets/pfe_limits_table.dart';
// import 'package:wcas_frontend/features/request/facilities_securities/facilities_summary/widgets/project_specific_limit_table.dart';
// import 'package:wcas_frontend/features/request/facilities_securities/facilities_summary/widgets/project_standby_limits_table.dart';
// import 'package:wcas_frontend/models/request/facility_security/facility_summary.dart';
import 'package:wcas_frontend/models/request/facility_security/facility_summary_list.dart';
import 'package:wcas_frontend/models/request/request.dart';

import 'model.dart';
import 'state.dart';

class ViewMobile extends StatelessWidget {
  const ViewMobile({super.key});

  @override
  Widget build(BuildContext context) {
    FacilitiesSummaryViewModel viewModel =
        context.read<FacilitiesSummaryViewModel>();
    return BlocBuilder<FacilitiesSummaryViewModel, FacilitiesSummaryState>(
        builder: (context, state) {
      return Layout(
        child: _body(context, state, viewModel),
      );
    });
  }

  Widget _body(BuildContext context, FacilitiesSummaryState state,
      FacilitiesSummaryViewModel viewModel) {
    switch (state.loaderStatus) {
      case LoadingStatus.loading:
        return const Center(
          child: CircularProgressIndicator(),
        );
      case LoadingStatus.empty:
        return Center(
          child: Text('Empty State'.tr()),
        );
      default:
        return buildView(viewModel, state);
    }
  }

  Widget buildView(
    FacilitiesSummaryViewModel viewModel,
    FacilitiesSummaryState state,
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
            BoxLayout(
              child: ListView.builder(
                physics: const NeverScrollableScrollPhysics(),
                shrinkWrap: true,
                itemBuilder: (context, i) {
                  FacilitySummaryList? customer = viewModel.customerFacilities?[i];
                  if (customer == null) return const SizedBox.shrink();
                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 6),
                    child: CustomAccordion(
                  title:
                        "${viewModel.customerFacilities?[i].rims?[i].rimName} (RIM NO ${viewModel.customerFacilities?[i].rims?[i].rimNo})",     
                        //  "${viewModel.customerFacilities?[i].custName} (${viewModel.customerFacilities?[i].rimNo})",
                      children: (state.tableLoaderStatus ==
                              LoadingStatus.loading)
                          ? [
                              const BoxLayout(
                                  child: Center(
                                child: CupertinoActivityIndicator(
                                  radius: 30,
                                ),
                              )),
                            ]
                          : [
                              // GeneralWorkingCapitalLimitTable(
                              //   viewModel: viewModel,
                              //   generalWorkingCapitalLimits:
                              //       customer.generalWorkingCapitalLimits,
                              //   customer: customer,
                              // ),
                              // LoansTable(
                              //   viewModel: viewModel,
                              //   loans: viewModel.customerFacilities?[i].loans,
                              //   customer: customer,
                              // ),
                              // PfeLimitsTable(
                              //   viewModel: viewModel,
                              //   customer: customer,
                              //   ppeLimits:
                              //       viewModel.customerFacilities?[i].ppeLimits,
                              // ),
                              // ProjectStandbyLimitsTable(
                              //   viewModel: viewModel,
                              //   projectStandbyLimits: viewModel
                              //       .customerFacilities?[i]
                              //       .projectStandbyLimits,
                              //   customer: customer,
                              // ),
                              // ProjectSpecificLimitTable(
                              //   viewModel: viewModel,
                              //   projectSpecificLimit: viewModel
                              //       .customerFacilities?[i]
                              //       .projectSpecificLimit,
                              //   customer: customer,
                              // ),
                              // OverallTotalTable(
                              //     viewModel: viewModel,
                              //     overallTotal: viewModel
                              //         .customerFacilities?[i].overallTotal),
                              Padding(
                                padding: const EdgeInsets.only(top: 8.0),
                                child: Align(
                                    alignment: Alignment.bottomRight,
                                    child: CustomButton(
                                        label: "common.save".tr(),
                                        onPressed: () {
                                          // viewModel
                                          //     .saveFacilityDetails(customer);
                                        })),
                              )
                            ],
                    ),
                  );
                },
                itemCount: viewModel.customerFacilities?.length,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
