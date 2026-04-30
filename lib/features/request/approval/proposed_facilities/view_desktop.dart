import "package:easy_localization/easy_localization.dart";
import "package:flutter/material.dart";
import "package:flutter_bloc/flutter_bloc.dart";

import "package:wcas_frontend/core/components/accordion.dart";
import "package:wcas_frontend/core/components/box_layout.dart";
import "package:wcas_frontend/core/components/button.dart";
import "package:wcas_frontend/core/components/gap.dart";
import "package:wcas_frontend/core/components/section_header.dart";
import "package:wcas_frontend/core/components/selectable_text.dart";
import "package:wcas_frontend/core/components/tab_menu.dart";
import "package:wcas_frontend/core/components/top_section/top_section_details.dart";
import "package:wcas_frontend/core/constants/constants.dart";
import "package:wcas_frontend/core/globals.dart";
import "package:wcas_frontend/core/utils/utils.dart";
import "package:wcas_frontend/features/layout/view.dart";
import "package:wcas_frontend/features/request/approval/proposed_facilities/model.dart";
import "package:wcas_frontend/features/request/approval/proposed_facilities/state.dart";
import "package:wcas_frontend/features/request/approval/proposed_facilities/widgets/pipeline_table.dart";
import "package:wcas_frontend/features/request/approval/proposed_facilities/widgets/positions_table.dart";

class ViewDesktop extends StatelessWidget {
  const ViewDesktop({super.key});

  @override
  Widget build(BuildContext context) {
    final ProposedFacilitiesViewModel viewModel =
        context.read<ProposedFacilitiesViewModel>();
    return BlocBuilder<ProposedFacilitiesViewModel, ProposedFacilitiesState>(
      builder: (context, state) {
        return Layout(
          child: SingleChildScrollView(
            scrollDirection: Axis.vertical,
            child: BoxLayout(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  CustomSectionHeader(
                    title: "approval.proposedFacilities.sectionTitle".tr(),
                  ),
                  const Gap(),
                  BoxLayout(
                    child: TopSectionDetails(request: Globals.request!),
                  ),
                  BoxLayout(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        TabMenu(
                          activeKey: RecommendationTabs.proposedFacilities,
                          routes: TabConstants.recommendationRoutes,
                          labels: TabConstants.recommendationTitles,
                          conditionalRoutes:
                              TabConstants.getRecommendationRoutes(),
                        ),
                        BoxLayout(
                          child: _body(context, state, viewModel),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _body(
    BuildContext context,
    ProposedFacilitiesState state,
    ProposedFacilitiesViewModel viewModel,
  ) {
    switch (state.loaderStatus) {
      case LoadingStatus.loading:
        return const Center(
          child: CircularProgressIndicator(),
        );
      case LoadingStatus.empty:
        return Center(
          child: Text("common.emptyState".tr()),
        );
      case LoadingStatus.error:
        return Center(
          child: Text("common.errorState".tr()),
        );
      default:
        return _buildView(viewModel);
    }
  }

  Widget _buildView(ProposedFacilitiesViewModel viewModel) {
    return Column(
      children: [
        const Gap(),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            CustomSelectableText(
              text: "approval.proposedFacilities.proposedPosition".tr(),
              semanticsLabel:
                  "approval.proposedFacilities.proposedPosition".tr(),
              textAlign: TextAlign.left,
              style: AppStyle.tableHeaderStyle,
            ),
            CustomSelectableText(
              text: "approval.proposedFacilities.aed".tr(),
              semanticsLabel: "approval.proposedFacilities.aed".tr(),
              textAlign: TextAlign.right,
              style: AppStyle.tableSuffixHeaderStyle,
            ),
          ],
        ),
        const Gap(),
        PositionsTable(
          viewModel: viewModel,
          positions: viewModel.groupPositionList?.proposedPosition,
          isProposed: true,
        ),
        if (viewModel.groupPositionList?.proposedPosition?.isEmpty ?? true)
          Text("common.noData".tr()),
        const Gap(size: GapSize.large),
        if (!Utils.isGroupApplication()) ...[
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              CustomSelectableText(
                text: "approval.proposedFacilities.presentPosition".tr(),
                semanticsLabel:
                    "approval.proposedFacilities.presentPosition".tr(),
                textAlign: TextAlign.left,
                style:
                    const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
              ),
              CustomSelectableText(
                semanticsLabel: "approval.proposedFacilities.aed".tr(),
                text: "approval.proposedFacilities.aed".tr(),
                textAlign: TextAlign.right,
                style: AppStyle.tableSuffixHeaderStyle,
              ),
            ],
          ),
          const Gap(),
          PositionsTable(
            viewModel: viewModel,
            positions: viewModel.groupPositionList?.presentPosition,
            isProposed: false,
          ),
          if (viewModel.groupPositionList?.presentPosition?.isEmpty ?? true)
            Text("common.noData".tr()),
        ],
        const Gap(),
        CustomAccordion(
          title: "approval.proposedFacilities.requestInPipeline".tr(),
          children: [
            PipelineTable(
              viewModel: viewModel,
              pipelineRequests: viewModel.pipelineRequests,
            ),
          ],
        ),
        const Gap(),
        Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            CustomButton(
              semanticLabel: "common.save".tr(),
              label: "common.save".tr(),
              onPressed: () {
                viewModel.onSavePress();
              },
            ),
            const Gap(direction: Axis.horizontal),
            CustomButton(
              semanticLabel: "common.saveAndContinue".tr(),
              label: "common.saveAndContinue".tr(),
              onPressed: () {
                viewModel.onSavePress(isContinue: true);
              },
            ),
          ],
        ),
        const Gap(),
      ],
    );
  }
}
