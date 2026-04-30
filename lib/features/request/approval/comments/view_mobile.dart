import "package:easy_localization/easy_localization.dart";
import "package:flutter/material.dart";
import "package:flutter_bloc/flutter_bloc.dart";

import "package:wcas_frontend/core/components/box_layout.dart";
import "package:wcas_frontend/core/components/button.dart";
import "package:wcas_frontend/core/components/comment_history/comments_table.dart";
import "package:wcas_frontend/core/components/gap.dart";
import "package:wcas_frontend/core/components/label.dart";
import "package:wcas_frontend/core/components/rich_text_editor/unified_text_editor.dart";
import "package:wcas_frontend/core/components/section_header.dart";
import "package:wcas_frontend/core/components/selectable_text.dart";
import "package:wcas_frontend/core/components/tab_menu.dart";
import "package:wcas_frontend/core/components/top_section/top_section_details.dart";
import "package:wcas_frontend/core/constants/constants.dart";
import "package:wcas_frontend/core/globals.dart";
import "package:wcas_frontend/core/utils/utils.dart";
import "package:wcas_frontend/features/layout/view.dart";
import "package:wcas_frontend/features/request/approval/comments/model.dart";
import "package:wcas_frontend/features/request/approval/comments/state.dart";
import "package:wcas_frontend/features/request/approval/comments/widgets/bottom_controls.dart";

class ViewMobile extends StatelessWidget {
  const ViewMobile({super.key});

  @override
  Widget build(BuildContext context) {
    final CommentsViewModel viewModel = context.read<CommentsViewModel>();
    return BlocBuilder<CommentsViewModel, CommentsState>(
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
                          activeKey: RecommendationTabs.comments,
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
    CommentsState state,
    CommentsViewModel viewModel,
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
        return _buildView(viewModel, context, state);
    }
  }

  Widget _buildView(
    CommentsViewModel viewModel,
    BuildContext context,
    CommentsState state,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        LabelWidget(
          label: "${state.getRole} ${"approval.comments.tabTitle".tr()}",
          labelStyle: AppStyle.tableHeaderStyle,
          isRequired: true,
          child: UnifiedTextEditor(
            disable: viewModel.isReadOnly,
            semanticLabel:
                "${state.getRole} ${"approval.comments.tabTitle".tr()}",
            characterLimit: 5000,
            controller: viewModel.controller,
            scrollController: viewModel.scrollController,
            initialText: viewModel.initialText,
            editorId: "approval.comments",
          ),
        ),
        const Gap(),
        if (viewModel.comments.isNotEmpty && viewModel.isCommentVisible) ...[
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              CustomSelectableText(
                text: "approval.comments.commentHistory".tr(),
                semanticsLabel: "approval.comments.commentHistory".tr(),
                textAlign: TextAlign.left,
                style: AppStyle.tableHeaderStyle,
              ),
            ],
          ),
          const Gap(),
          CommentsTableWidget(
            comments: viewModel.comments,
            ishtmlComment: true,
          ),
        ],
        const Gap(),
        if (!viewModel.isReadOnly) ...[
          BottomControls(
            viewModel: viewModel,
            context: context,
          ),
          const Gap(),
        ],
        if (Globals.checkCurrentStatus([RequestStatus.approved]) &&
            viewModel.buttonVisibilityStatus[ApprovalFields.closeApplication]!
                .call() &&
            viewModel.isInitByUser) ...[
          CustomButton(
            semanticLabel: "approval.comments.closeApplication".tr(),
            label: "approval.comments.closeApplication".tr(),
            onPressed: () async {
              await viewModel
                  .submitApplication(UserAction.acceptCloseApplication);
            },
          ),
        ],
      ],
    );
  }
}
