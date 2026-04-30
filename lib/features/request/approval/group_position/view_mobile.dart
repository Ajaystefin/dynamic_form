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
import "package:wcas_frontend/features/request/approval/group_position/model.dart";
import "package:wcas_frontend/features/request/approval/group_position/state.dart";
import "package:wcas_frontend/features/request/approval/group_position/widgets/customer_table.dart";
import "package:wcas_frontend/features/request/approval/group_position/widgets/heading_table.dart";
import "package:wcas_frontend/models/request/approval/group_position.dart";

class ViewMobile extends StatelessWidget {
  const ViewMobile({super.key});
  @override
  Widget build(BuildContext context) {
    final GroupPositionViewModel viewModel =
        context.read<GroupPositionViewModel>();
    return BlocBuilder<GroupPositionViewModel, GroupPositionState>(
      builder: (context, state) {
        return Layout(
          child: BoxLayout(
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  CustomSectionHeader(title: "approval.sectionTitle".tr()),
                  const Gap(),
                  BoxLayout(
                    child: TopSectionDetails(request: Globals.request!),
                  ),
                  BoxLayout(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        TabMenu(
                          activeKey: RecommendationTabs.groupPosition,
                          routes: TabConstants.recommendationRoutes,
                          labels: TabConstants.recommendationTitles,
                          conditionalRoutes:
                              TabConstants.getRecommendationRoutes(),
                        ),
                        BoxLayout(
                          child: SingleChildScrollView(
                            child: _body(context, state, viewModel),
                          ),
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
    GroupPositionState state,
    GroupPositionViewModel viewModel,
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
        return _buildView(viewModel, context);
    }
  }

  Widget _buildView(GroupPositionViewModel viewModel, BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Gap(size: GapSize.medium),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              CustomSelectableText(
                semanticsLabel: "approval.groupPosition.aed".tr(),
                text: "approval.groupPosition.aed".tr(),
                textAlign: TextAlign.right,
                style: AppStyle.tableSuffixHeaderStyle,
              ),
            ],
          ),
          const Gap(size: GapSize.medium),
          HeadingTable(
            viewModel: viewModel,
          ),
          if (viewModel.groups.isEmpty)
            Center(
              child: Text(
                "common.noData".tr(),
              ),
            ),
          const Gap(size: GapSize.medium),
          for (final CustomerPosition customerPosition in viewModel.groups)
            Column(
              children: [
                CustomAccordion(
                  title: customerPosition.customerName,
                  initiallyExpanded: true,
                  children: [
                    CustomerTable(
                      viewModel: viewModel,
                      customerPosition: customerPosition,
                      order: customerPosition.order ?? 0,
                    ),
                  ],
                ),
              ],
            ),
          const Gap(size: GapSize.medium),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              CustomButton(
                semanticLabel: "approval.groupPosition.save".tr(),
                label: "approval.groupPosition.save".tr(),
                onPressed: () async {
                  await viewModel.onSavePress(context);
                },
              ),
              const Gap(direction: Axis.horizontal),
              CustomButton(
                semanticLabel: "approval.groupPosition.saveAndContinue".tr(),
                label: "approval.groupPosition.saveAndContinue".tr(),
                onPressed: () {
                  viewModel.onSavePress(context, isContinue: true);
                },
              ),
            ],
          ),
          const Gap(size: GapSize.medium),
        ],
      ),
    );
  }
}
