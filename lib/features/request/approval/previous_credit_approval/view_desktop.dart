import "package:easy_localization/easy_localization.dart";
import "package:flutter/material.dart";
import "package:flutter_bloc/flutter_bloc.dart";

import "package:wcas_frontend/core/components/box_layout.dart";
import "package:wcas_frontend/core/components/button.dart";
import "package:wcas_frontend/core/components/gap.dart";
import "package:wcas_frontend/core/components/label.dart";
import "package:wcas_frontend/core/components/section_header.dart";
import "package:wcas_frontend/core/components/tab_menu.dart";
import "package:wcas_frontend/core/components/textarea.dart";
import "package:wcas_frontend/core/components/top_section/top_section_details.dart";
import "package:wcas_frontend/core/constants/constants.dart";
import "package:wcas_frontend/core/globals.dart";
import "package:wcas_frontend/core/services/route_service.dart";
import "package:wcas_frontend/core/utils/utils.dart";
import "package:wcas_frontend/features/layout/view.dart";
import "package:wcas_frontend/features/request/approval/previous_credit_approval/model.dart";
import "package:wcas_frontend/features/request/approval/previous_credit_approval/state.dart";

/// Displays the desktop view for the previous credit approval screen.
class ViewDesktop extends StatelessWidget {
  /// Creates the desktop previous credit approval view.
  const ViewDesktop({super.key});

  @override
  Widget build(BuildContext context) {
    final PreviousCreditApprovalViewModel viewModel =
        context.read<PreviousCreditApprovalViewModel>();
    return BlocBuilder<PreviousCreditApprovalViewModel,
        PreviousCreditApprovalState>(
      builder: (context, state) {
        return Layout(
          child: SingleChildScrollView(
            controller: viewModel.scrollController,
            child: BoxLayout(
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
                          activeKey: RecommendationTabs.previousCreditApproval,
                          routes: TabConstants.recommendationRoutes,
                          labels: TabConstants.recommendationTitles,
                          conditionalRoutes:
                              TabConstants.getRecommendationRoutes(),
                        ),
                        const Gap(),
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
    PreviousCreditApprovalState state,
    PreviousCreditApprovalViewModel viewModel,
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
        return _buildView(context, viewModel);
    }
  }

  Widget _buildView(
    BuildContext context,
    PreviousCreditApprovalViewModel viewModel,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        LabelWidget(
          label: "approval.comments.comments".tr(),
          labelStyle: AppStyle.tableHeaderStyle,
          isRequired: true,
          isEnabled: !viewModel.isReadOnly,
          child: CustomTextArea(
            readOnly: viewModel.isReadOnly,
            initialValue: viewModel.initialText,
            onChanged: (value) {
              viewModel.initialText = value;
            },
            maxLength: 1000,
            controller: viewModel.commentController,
          ),
        ),
        const Gap(),
        if (!viewModel.isReadOnly)
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              CustomButton(
                label: "common.save".tr(),
                semanticLabel: "common.save".tr(),
                onPressed: () {
                  viewModel.onSavePress(context: context);
                },
              ),
              const Gap(direction: Axis.horizontal),
              CustomButton(
                label: "common.saveAndContinue".tr(),
                semanticLabel: "common.saveAndContinue".tr(),
                onPressed: () {
                  viewModel.onSavePress(context: context, isContinue: true);
                },
              ),
            ],
          ),
        if (viewModel.isReadOnly)
          Align(
            alignment: Alignment.centerRight,
            child: CustomButton(
              semanticLabel: "common.continue".tr(),
              label: "common.continue".tr(),
              onPressed: () {
                router.go(Routes.recommendationCurrentApproval);
              },
            ),
          ),
      ],
    );
  }
}
