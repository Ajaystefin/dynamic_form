import "package:easy_localization/easy_localization.dart";
import "package:flutter/material.dart";
import "package:flutter_bloc/flutter_bloc.dart";

import "package:wcas_frontend/core/components/box_layout.dart";
import "package:wcas_frontend/core/components/button.dart";
import "package:wcas_frontend/core/components/gap.dart";
import "package:wcas_frontend/core/components/section_header.dart";
import "package:wcas_frontend/core/components/tab_menu.dart";
import "package:wcas_frontend/core/components/top_section/top_section_details.dart";
import "package:wcas_frontend/core/constants/constants.dart";
import "package:wcas_frontend/core/globals.dart";
import "package:wcas_frontend/core/utils/utils.dart";
import "package:wcas_frontend/features/layout/view.dart";
import "package:wcas_frontend/features/request/profitability_account_conduct/strategies_and_comments/fields/strategy_text_field.dart";
import "package:wcas_frontend/features/request/profitability_account_conduct/strategies_and_comments/model.dart";
import "package:wcas_frontend/features/request/profitability_account_conduct/strategies_and_comments/state.dart";

class ViewDesktop extends StatelessWidget {
  const ViewDesktop({super.key});

  @override
  Widget build(BuildContext context) {
    final StrategiesAndCommentsViewModel viewModel =
        context.read<StrategiesAndCommentsViewModel>();

    return BlocBuilder<StrategiesAndCommentsViewModel,
        StrategiesAndCommentsState>(
      builder: (context, state) {
        return Layout(
          child: SingleChildScrollView(
            controller: viewModel.scrollController,
            scrollDirection: Axis.vertical,
            child: BoxLayout(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  CustomSectionHeader(
                    title: "profitabilityAccountConduct."
                            "relationshipProfitabilitySummary.sectionTitle"
                        .tr(),
                  ),
                  const Gap(),
                  Column(
                    children: [
                      BoxLayout(
                        child: TopSectionDetails(request: Globals.request!),
                      ),
                      BoxLayout(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const TabMenu(
                              activeKey:
                                  RevenueCrossSellTabs.strategiesAndComments,
                              routes: TabConstants.revenueCrossSellRoutes,
                              labels: TabConstants.revenueCrossSellTitles,
                            ),
                            BoxLayout(
                              extraPadding: true,
                              disabled: !viewModel.canEdit,
                              child: _body(context, state, viewModel),
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
      },
    );
  }
}

Widget _body(
  BuildContext context,
  StrategiesAndCommentsState state,
  StrategiesAndCommentsViewModel viewModel,
) {
  switch (state.loaderStatus) {
    case LoadingStatus.loading:
      return const Center(child: CircularProgressIndicator());
    case LoadingStatus.empty:
      return Center(child: Text("common.emptyState".tr()));
    case LoadingStatus.error:
      return Center(child: Text("common.errorState".tr()));
    default:
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Gap(),
          // In view_desktop.dart
          ...viewModel.commentCategories.map((ref) {
            final int refId = ref["id"] as int;
            final String label = (ref["name"] as String?) ?? "";

            // Provide initial text only once; after that it returns ''
            final String initialValue = viewModel.initialTextOnceFor(refId);

            final controller = viewModel.getControllerFor(
              refId,
              // If you prefer seeding here instead of
              // ViewModel.seedInitialFromServer:
              // initialContent: initialValue, contentIsHtml: false
            );

            return StrategyTextField(
              key: ValueKey("strategy-$refId"),
              label: label,
              initialValue: initialValue, // will be '' after first build
              onChanged: (val) =>
                  viewModel.updateComment(refId, val), // optional
              controller: controller,
              scrollController: viewModel.scrollController,
              viewModel: viewModel,
            );
          }),
          const Gap(size: GapSize.medium),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              CustomButton(
                label:
                    "profitabilityAccountConduct.strategiesComments.save".tr(),
                onPressed: (viewModel.canEdit)
                    ? () async {
                        await viewModel.saveComments();
                      }
                    : null,
              ),
              const Gap(direction: Axis.horizontal),
              CustomButton(
                label: "profitabilityAccountConduct."
                        "strategiesComments.saveAndContinue"
                    .tr(),
                onPressed: (viewModel.canEdit)
                    ? () async {
                        await viewModel.saveComments(isContinue: true);
                      }
                    : null,
              ),
            ],
          ),
          const Gap(size: GapSize.medium),
        ],
      );
  }
}
