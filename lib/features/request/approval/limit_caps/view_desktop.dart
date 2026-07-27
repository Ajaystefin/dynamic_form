import "package:easy_localization/easy_localization.dart";
import "package:flutter/material.dart";
import "package:flutter_bloc/flutter_bloc.dart";

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
import "package:wcas_frontend/features/request/approval/limit_caps/model.dart";
import "package:wcas_frontend/features/request/approval/limit_caps/state.dart";
import "package:wcas_frontend/features/request/approval/limit_caps/widgets/limit_caps_table.dart";

/// Displays the desktop view for the limit caps approval screen.
class ViewDesktop extends StatelessWidget {
  /// Creates the desktop limit caps approval view.
  const ViewDesktop({super.key});

  @override
  Widget build(BuildContext context) {
    final LimitCapsViewModel viewModel = context.read<LimitCapsViewModel>();
    return BlocBuilder<LimitCapsViewModel, LimitCapsState>(
      builder: (context, state) {
        return Layout(
          child: SingleChildScrollView(
            child: BoxLayout(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  CustomSectionHeader(
                    title: "approval.limitCaps.sectionTitle".tr(),
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
                          activeKey: RecommendationTabs.limitCaps,
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
    LimitCapsState state,
    LimitCapsViewModel viewModel,
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

  Widget _buildView(LimitCapsViewModel viewModel) {
    return Column(
      children: [
        const Gap(),
        Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            CustomSelectableText(
              semanticsLabel: "approval.limitCaps.aed".tr(),
              text: "approval.limitCaps.aed".tr(),
              textAlign: TextAlign.right,
              style: AppStyle.tableSuffixHeaderStyle,
            ),
          ],
        ),
        const Gap(),
        LimitCapsTable(viewModel: viewModel),
        const Gap(),
        if (viewModel.filteredlimitDetail.isEmpty)
          Text("common.emptyState".tr()),
        const Gap(),
        Row(
          // spacing: 10,
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            CustomButton(
              semanticLabel: "common.continue".tr(),
              label: "common.continue".tr(),
              onPressed: () {
                viewModel.onSavePress(isContinue: true);
              },
            ),
          ],
        ),
      ],
    );
  }
}
