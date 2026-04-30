import "package:easy_localization/easy_localization.dart";
import "package:flutter/material.dart";
import "package:flutter_bloc/flutter_bloc.dart";
import "package:wcas_frontend/core/components/box_layout.dart";
import "package:wcas_frontend/core/components/button.dart";
import "package:wcas_frontend/core/components/comment_history/comments_table.dart";
import "package:wcas_frontend/core/components/gap.dart";
import "package:wcas_frontend/core/components/rich_text_editor/unified_text_editor.dart";
import "package:wcas_frontend/core/components/section_header.dart";
import "package:wcas_frontend/core/components/selectable_text.dart";
import "package:wcas_frontend/core/components/top_section/top_section_details.dart";
import "package:wcas_frontend/core/constants/constants.dart";
import "package:wcas_frontend/core/globals.dart";
import "package:wcas_frontend/core/utils/utils.dart";
import "package:wcas_frontend/features/layout/view.dart";
import "package:wcas_frontend/features/request/ccsys/approval/model.dart";
import "package:wcas_frontend/features/request/ccsys/approval/state.dart";
import "package:wcas_frontend/features/request/ccsys/approval/widgets/ccsys_dropdown_button.dart";
import "package:wcas_frontend/features/request/ccsys/approval/widgets/ccsys_return_dropdown_button.dart";
import "package:wcas_frontend/features/request/ccsys/approval/widgets/save_button.dart";
import "package:wcas_frontend/models/request/request.dart";

class ViewMobile extends StatelessWidget {
  const ViewMobile({super.key});

  @override
  Widget build(BuildContext context) {
    final CcsysApprovalViewModel viewModel =
        context.read<CcsysApprovalViewModel>();
    return BlocBuilder<CcsysApprovalViewModel, CcsysApprovalState>(
      builder: (context, state) {
        return Layout(
          child: SingleChildScrollView(
            child: BoxLayout(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  CustomSectionHeader(
                    title: "ccsys.recommendationApproval.sectionTitle".tr(),
                  ),
                  const Gap(),
                  BoxLayout(
                    child: TopSectionDetails(
                      request: Globals.request ?? Request(),
                    ),
                  ),
                  BoxLayout(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _body(context, state, viewModel),
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
    CcsysApprovalState state,
    CcsysApprovalViewModel viewModel,
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
    CcsysApprovalViewModel viewModel,
    BuildContext context,
    CcsysApprovalState state,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        CustomSelectableText(
          text: "${viewModel.roleCode} ${"approval.comments.tabTitle".tr()}",
          textAlign: TextAlign.left,
          style: AppStyle.tableHeaderStyle,
        ),
        UnifiedTextEditor(
          scrollController: viewModel.scrollController,
          // disable: !isValid,
          //characterLimit: 1000,
          editorId: "commentHistory",
          // initialText: viewModel.commentsInitialValue(),
          semanticLabel: "approval.comments.tabTitle".tr(),
          controller: viewModel.controller,
        ),
        const Gap(),
        CommentsTableWidget(
          comments: viewModel.comments,
          ishtmlComment: true,
        ),
        const Gap(),
        SaveButton(viewModel: viewModel),
        const Gap(
          size: GapSize.medium,
          direction: Axis.horizontal,
        ),
        CustomButton(
          semanticLabel: "approval.comments.cancel".tr(),
          label: "approval.comments.cancel".tr(),
          onPressed: () => viewModel.onSavePress(context, "cancel"),
        ),
        const Gap(
          size: GapSize.medium,
          direction: Axis.horizontal,
        ),
        if (viewModel.showRecommendButton && viewModel.canEdit)
          CcsysDropdownButton(
            viewModel: viewModel,
            label: "approval.comments.recommend".tr(),
          ),
        const Gap(
          size: GapSize.medium,
          direction: Axis.horizontal,
        ),
        if (viewModel.showApproveButton && viewModel.canEdit)
          CustomButton(
            semanticLabel: "approval.comments.approve".tr(),
            label: "approval.comments.approve".tr(),
            onPressed: (!viewModel.canEdit)
                ? null
                : () => viewModel.onSavePress(context, "approve"),
          ),
        if (viewModel.showReturnButton && viewModel.canEdit)
          CcsysReturnDropdownButton(
            viewModel: viewModel,
            label: "approval.comments.return".tr(),
          ),
        const Gap(
          size: GapSize.medium,
          direction: Axis.horizontal,
        ),
        const SizedBox(
          width: 30,
          height: 5,
        ),
        const Gap(size: GapSize.medium),
      ],
    );
  }
}
