import "package:easy_localization/easy_localization.dart";
import "package:flutter/cupertino.dart";
import "package:flutter/material.dart";
import "package:flutter_bloc/flutter_bloc.dart";
import "package:wcas_frontend/core/components/accordion.dart";
import "package:wcas_frontend/core/components/box_layout.dart";
import "package:wcas_frontend/core/components/button.dart";
import "package:wcas_frontend/core/components/gap.dart";
import "package:wcas_frontend/core/components/section_header.dart";
import "package:wcas_frontend/core/components/top_section/top_section_details.dart";
import "package:wcas_frontend/core/constants/_server_constants.dart";
import "package:wcas_frontend/core/globals.dart";
import "package:wcas_frontend/core/utils/scale.dart";
import "package:wcas_frontend/core/utils/utils.dart";
import "package:wcas_frontend/features/layout/model.dart";
import "package:wcas_frontend/features/layout/view.dart";
import "package:wcas_frontend/features/request/facilities_securities/facilities_summary/model.dart";
import "package:wcas_frontend/features/request/facilities_securities/facilities_summary/state.dart";
import "package:wcas_frontend/features/request/facilities_securities/facilities_summary/widgets/create_facility_button.dart";
import "package:wcas_frontend/features/request/facilities_securities/facilities_summary/widgets/facility_limits_table.dart";
import "package:wcas_frontend/features/request/facilities_securities/facilities_summary/widgets/fi_trade.dart";
import "package:wcas_frontend/features/request/facilities_securities/facilities_summary/widgets/overall_total_table.dart";
import "package:wcas_frontend/features/request/facilities_securities/facilities_summary/widgets/project_specific_limit_table.dart";
import "package:wcas_frontend/features/request/facilities_securities/facilities_summary/widgets/project_standby_limits_table.dart";
import "package:wcas_frontend/models/admin/reference.dart";
import "package:wcas_frontend/models/request/facility_security/facility_summary_list.dart";
import "package:wcas_frontend/models/request/request.dart";

class ViewDesktop extends StatelessWidget {
  const ViewDesktop({super.key});

  @override
  Widget build(BuildContext context) {
    final FacilitiesSummaryViewModel viewModel =
        context.read<FacilitiesSummaryViewModel>();
    return BlocBuilder<FacilitiesSummaryViewModel, FacilitiesSummaryState>(
      builder: (context, state) {
        return Layout(
          child: _body(context, state, viewModel),
        );
      },
    );
  }

  Widget _body(
    BuildContext context,
    FacilitiesSummaryState state,
    FacilitiesSummaryViewModel viewModel,
  ) {
    switch (state.loaderStatus) {
      case LoadingStatus.loading:
        return const Center(
          child: CircularProgressIndicator(),
        );

      default:
        return buildView(viewModel, state, context);
    }
  }

  Widget buildView(
    FacilitiesSummaryViewModel viewModel,
    FacilitiesSummaryState state,
    BuildContext context,
  ) {
    final List<FacilitySummaryList> customers =
        viewModel.customerFacilities ?? const <FacilitySummaryList>[];

    return SingleChildScrollView(
      child: BoxLayout(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            CustomSectionHeader(title: "facilities.facilitySummary.title".tr()),
            const Gap(),
            BoxLayout(
              child: TopSectionDetails(request: Globals.request ?? Request()),
            ),
            BoxLayout(
              child: Form(
                key: viewModel.formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if ((viewModel.customerFacilities?.isNotEmpty ?? false) &&
                        !viewModel.isFIFlow) ...[
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          CustomButton(
                            label: "facilities.facilitySummary.limitCaps".tr(),
                            onPressed: () async {
                              await viewModel.handleLimitCapsPressed(context);
                            },
                          ),
                        ],
                      ),
                      const Gap(),
                    ],
                    ListView.separated(
                      separatorBuilder: (context, index) => const Gap(),
                      physics: const NeverScrollableScrollPhysics(),
                      shrinkWrap: true,
                      itemCount: customers.length,
                      itemBuilder: (context, i) {
                        final FacilitySummaryList customer = customers[i];
                        final RimSummary? rim =
                            (customer.rims?.isNotEmpty ?? false)
                                ? customer.rims!.first
                                : null;

                        return CustomAccordion(
                          initiallyExpanded:
                              i == 0, // expand only the first item
                          title: "${rim?.rimName}",
                          children: (state.tableLoaderStatus ==
                                  LoadingStatus.loading)
                              ? [
                                  const BoxLayout(
                                    child: Center(
                                      child: CupertinoActivityIndicator(
                                        radius: 30,
                                      ),
                                    ),
                                  ),
                                ]
                              : [
                                  ..._buildGroupTables(
                                    viewModel: viewModel,
                                    customer: customer,
                                    rim: rim,
                                  ),
                                  OverallTotalTable(
                                    viewModel: viewModel,
                                    customer: customer,
                                    groupIndex: 5,
                                  ),
                                  const Gap(),
                                  if (viewModel.canEdit)
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.end,
                                      children: [
                                        const Gap(direction: Axis.horizontal),
                                        const Gap(
                                          direction: Axis.horizontal,
                                        ),
                                        CustomButton(
                                          label: "common.save".tr(),
                                          onPressed: () {
                                            if (!(viewModel.formKey.currentState
                                                    ?.validate() ??
                                                true)) {
                                              return;
                                            }
                                            viewModel.saveFacilitySummaryList(
                                              customer,
                                              limitGroup: ServerConstants
                                                  .generalLimitGroupId,
                                            );
                                          },
                                        ),
                                      ],
                                    ),
                                ],
                        );
                      },
                    ),
                  ],
                ),
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
                  },
                ),
                const Gap(direction: Axis.horizontal),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

List<Widget> _buildGroupTables({
  required FacilitiesSummaryViewModel viewModel,
  required FacilitySummaryList customer,
  required RimSummary? rim,
}) {
  final List<Widget> widgets = [];

  final int? selectedRim = viewModel.resolveRimNo(rim);
  for (final Reference ref in viewModel.limitGroup) {
    final int? groupIndex = viewModel.findGroupIndexByName(rim, ref.name ?? "");
    final int? groupId =
        ref.id is num ? (ref.id! as num).toInt() : int.tryParse("${ref.id}");

    if (groupId != null &&
        selectedRim != null &&
        (groupId == ServerConstants.projectSpecificLimitsID ||
            groupId == ServerConstants.projectStandByLimitID)) {
      viewModel.scheduleProjectListFetchIfNeeded(groupId, selectedRim);
    }

    // Use existing specialized tables for the known groups
    switch (groupId) {
      case ServerConstants.generalLimitGroupId:
        widgets.add(
          FacilityLimitsTable(
            viewModel: viewModel,
            customer: customer,
            groupId: ServerConstants.generalLimitGroupId,
            groupIndex: groupIndex ?? 0,
            proposedColumnWidth: 155.w,
            tenorColumnWidth: 150.w,
          ),
        );

      case ServerConstants.termLoanGroupId:
        widgets.add(
          FacilityLimitsTable(
            viewModel: viewModel,
            customer: customer,
            groupId: ServerConstants.termLoanGroupId,
            groupIndex: groupIndex ?? 1,
          ),
        );

      case ServerConstants.pfeLimitGroupId:
        widgets.add(
          FacilityLimitsTable(
            viewModel: viewModel,
            customer: customer,
            groupId: ServerConstants.pfeLimitGroupId,
            groupIndex: groupIndex ?? 2,
          ),
        );

      case ServerConstants.projectStandByLimitID: // Project Standby Limits
        widgets.add(
          ProjectStandbyLimitsTable(
            viewModel: viewModel,
            customer: customer,
            groupIndex: groupIndex ?? 3,
          ),
        );
      case ServerConstants.projectSpecificLimitsID: // Project Specific Limits
        widgets.add(
          ProjectSpecificLimitTable(
            viewModel: viewModel,
            customer: customer,
            groupIndex: groupIndex ?? 4,
          ),
        );
      // Trade :  using trade table for all since having same structure, but can
      // be changed later if needed
      case 14504:
        widgets.add(
          FiTradeTable(
            viewModel: viewModel,
            customer: customer,
            groupIndex: groupIndex ?? 0,
            limitGroup: groupId,
          ),
        );
      case 14505 when rim?.type == CustomerType.country: //Sovereign Government
        widgets.add(
          FiTradeTable(
            viewModel: viewModel,
            customer: customer,
            groupIndex: groupIndex ?? 0,
            limitGroup: groupId,
          ),
        );
      case 14506: //DCM
        widgets.add(
          FiTradeTable(
            viewModel: viewModel,
            customer: customer,
            groupIndex: groupIndex ?? 0,
            limitGroup: groupId,
          ),
        );
      case 14507: //Bilateral Loan
        widgets.add(
          FiTradeTable(
            viewModel: viewModel,
            customer: customer,
            groupIndex: groupIndex ?? 0,
            limitGroup: groupId,
          ),
        );
      case 14508: //Treasury
        widgets.add(
          FiTradeTable(
            viewModel: viewModel,
            customer: customer,
            groupIndex: groupIndex ?? 0,
            limitGroup: groupId,
          ),
        );
      case 14509: //Fixed Income
        widgets.add(
          FiTradeTable(
            viewModel: viewModel,
            customer: customer,
            groupIndex: groupIndex ?? 0,
            limitGroup: groupId,
          ),
        );
      case 14510
          when rim?.type == CustomerType.country: //Corporate cross - border
        widgets.add(
          FiTradeTable(
            viewModel: viewModel,
            customer: customer,
            groupIndex: groupIndex ?? 0,
            limitGroup: groupId,
          ),
        );

      // Any new/unknown groups: show a small accordion with a "Create facility" box
      default:
        if (ref.id == 14505 && rim?.type == CustomerType.country ||
            ref.id == 14510 && rim?.type == CustomerType.country) {
          widgets.add(
            CustomAccordion(
              isSubSection: true,
              title: (ref.name ?? "").trim(),
              children: [
                AddFacilitySubLimitBox(
                  label: "facilities.facilitySummary.createFacility".tr(),
                  limitGroup: groupId,
                  selectedRim: selectedRim,
                  isMainLimit: true,
                ),
              ],
            ),
          );
        }
        // NOTE ----> no need for this condiiton for display other groups.newly
        // added groups in Admin shoul remove
        else if (ref.id != 14505 && ref.id != 14510) {
          widgets.add(
            CustomAccordion(
              isSubSection: true,
              title: (ref.name ?? "").trim(),
              children: [
                AddFacilitySubLimitBox(
                  label: "facilities.facilitySummary.createFacility".tr(),
                  limitGroup: groupId,
                  selectedRim: selectedRim,
                  isMainLimit: true,
                ),
              ],
            ),
          );
        }
    }
  }

  return widgets;
}
