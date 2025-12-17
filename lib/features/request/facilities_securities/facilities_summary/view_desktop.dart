import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:wcas_frontend/core/components/accordion.dart';
import 'package:wcas_frontend/core/components/box_layout.dart';
import 'package:wcas_frontend/core/components/button.dart';
import 'package:wcas_frontend/core/components/gap.dart';
import 'package:wcas_frontend/core/components/section_header.dart';
import 'package:wcas_frontend/core/components/top_section/top_section_details.dart';
import 'package:wcas_frontend/core/globals.dart';
import 'package:wcas_frontend/core/utils/utils.dart';
import 'package:wcas_frontend/features/layout/model.dart';
import 'package:wcas_frontend/features/layout/view.dart';
import 'package:flutter/material.dart';
import 'package:wcas_frontend/features/request/facilities_securities/facilities_summary/widgets/general_working_capital_limit_table.dart';
import 'package:wcas_frontend/features/request/facilities_securities/facilities_summary/widgets/loans_table.dart';
import 'package:wcas_frontend/features/request/facilities_securities/facilities_summary/widgets/overall_total_table.dart';
import 'package:wcas_frontend/features/request/facilities_securities/facilities_summary/widgets/pfe_limits_table.dart';
import 'package:wcas_frontend/features/request/facilities_securities/facilities_summary/widgets/project_specific_limit_table.dart';
import 'package:wcas_frontend/features/request/facilities_securities/facilities_summary/widgets/project_standby_limits_table.dart';
// import 'package:wcas_frontend/models/request/facility_security/facility_summary.dart';
import 'package:wcas_frontend/models/request/facility_security/facility_summary_list.dart';
import 'package:wcas_frontend/models/request/request.dart';
import 'model.dart';
import 'state.dart';

class ViewDesktop extends StatelessWidget {
  const ViewDesktop({super.key});

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
          children: [
            CustomSectionHeader(title: "facilities.facilitySummary.title".tr()),
            const Gap(),
            BoxLayout(
                child:
                    TopSectionDetails(request: Globals.request ?? Request())),
            BoxLayout(
              child: ListView.separated(
                separatorBuilder: (context, index) => const Gap(),
                physics: const NeverScrollableScrollPhysics(),
                shrinkWrap: true,
                itemCount: (viewModel.customerFacilities)!.length,
                itemBuilder: (context, i) {
                  FacilitySummaryList? customer =
                      viewModel.customerFacilities?[i];
                  if (customer == null) return const SizedBox.shrink();

                  RimSummary? rim = (customer.rims?.isNotEmpty ?? false)
                      ? customer.rims!.first
                      : null;

                  return CustomAccordion(
                    initiallyExpanded: true,
                    title: "${rim?.rimName}",
                    children: (state.tableLoaderStatus == LoadingStatus.loading)
                        ? [
                            const BoxLayout(
                                child: Center(
                              child: CupertinoActivityIndicator(
                                radius: 30,
                              ),
                            )),
                          ]
                        : [
                            GeneralWorkingCapitalLimitTable(
                                viewModel: viewModel,
                                // generalWorkingCapitalLimits: FacilityGroup(),
                                customer: customer,
                                groupIndex: 0),
                            LoansTable(
                                viewModel: viewModel,
                                customer: customer,
                                groupIndex: 1),
                            PfeLimitsTable(
                                viewModel: viewModel,
                                customer: customer,
                                groupIndex: 2),
                            ProjectStandbyLimitsTable(
                                viewModel: viewModel,
                                customer: customer,
                                groupIndex: 3),
                            ProjectSpecificLimitTable(
                                viewModel: viewModel,
                                customer: customer,
                                groupIndex: 4),
                            OverallTotalTable(
                                viewModel: viewModel,
                                customer: customer,
                                groupIndex: 5),
                            const Gap(),
                            Align(
                              alignment: Alignment.bottomRight,
                              child: CustomButton(
                                label: "common.save".tr(),
                                onPressed: () {
                                  viewModel.saveFacilitySummaryList(customer);
                                },
                              ),
                            )
                          ],
                  );
                },
              ),
            ),
            const Gap(),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                const Gap(direction: Axis.horizontal),
                CustomButton(
                    label: "common.continue".tr(),
                    onPressed: () {
                      LayoutViewModel().goToNextRoute();
                      // router.go(
                      //   Routes.securitySummaryView,
                      // );
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
