import "package:easy_localization/easy_localization.dart";
import "package:flutter/material.dart";
import "package:flutter_bloc/flutter_bloc.dart";
import "package:wcas_frontend/core/components/box_layout.dart";
import "package:wcas_frontend/core/components/button.dart";
import "package:wcas_frontend/core/components/comment_history/comments_table.dart";
import "package:wcas_frontend/core/components/gap.dart";
import "package:wcas_frontend/core/components/rich_text_editor/unified_text_editor.dart";
import "package:wcas_frontend/core/components/section_background.dart";
import "package:wcas_frontend/core/components/section_header.dart";
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

/// Displays the desktop view for the CCSYS recommendation approval screen.
class ViewDesktop extends StatelessWidget {
  /// Creates the desktop CCSYS recommendation approval view.
  const ViewDesktop({super.key});

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
        SectionBackground(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "${viewModel.roleCode} ${"approval.comments.tabTitle".tr()}",
                style: AppStyle.tableHeaderStyle,
              ),
            ],
          ),
        ),
        UnifiedTextEditor(
          scrollController: viewModel.scrollController,
          disable: !viewModel.canEdit,
          //characterLimit: 1000,
          editorId: "commentHistory",
          // initialText: viewModel.commentsInitialValue(),
          semanticLabel: "approval.comments.tabTitle".tr(),
          controller: viewModel.controller,
        ),
        const Gap(),
        SectionBackground(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "approval.comments.commentHistory".tr(),
                style: AppStyle.tableHeaderStyle,
              ),
              const Gap(),
              CommentsTableWidget(
                comments: viewModel.comments,
                ishtmlComment: true,
              ),
              const Gap(),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SaveButton(viewModel: viewModel),
                  const Gap(
                    direction: Axis.horizontal,
                  ),
                  // CustomButton(
                  //   semanticLabel: "approval.comments.cancel".tr(),
                  //   label: "approval.comments.cancel".tr(),
                  //   onPressed: () => viewModel.onSavePress(context,
                  // 'cancel'),
                  // ),
                  const Gap(
                    direction: Axis.horizontal,
                  ),
                  if (viewModel.canEdit && viewModel.showRecommendButton)
                    CcsysDropdownButton(
                      viewModel: viewModel,
                      label: "approval.comments.recommend".tr(),
                    ),
                  const Gap(
                    direction: Axis.horizontal,
                  ),
                  if (viewModel.canEdit && viewModel.showApproveButton)
                    CustomButton(
                      semanticLabel: "approval.comments.approve".tr(),
                      label: "approval.comments.approve".tr(),
                      onPressed: (!viewModel.canEdit)
                          ? null
                          : () => viewModel.onSavePress(context, "approve"),
                    ),
                  if (viewModel.canEdit && viewModel.showReturnButton)
                    CcsysReturnDropdownButton(
                      viewModel: viewModel,
                      label: "approval.comments.return".tr(),
                    ),
                  const Gap(
                    direction: Axis.horizontal,
                  ),
                  const SizedBox(
                    width: 30,
                    height: 5,
                  ),
                ],
              ),
              const Gap(),
            ],
          ),
        ),
      ],
    );
  }
}
