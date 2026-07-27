import "package:easy_localization/easy_localization.dart";
import "package:flutter/material.dart";
import "package:flutter_bloc/flutter_bloc.dart";

import "package:wcas_frontend/core/components/add_item_button.dart";
import "package:wcas_frontend/core/components/box_layout.dart";
import "package:wcas_frontend/core/components/button.dart";
import "package:wcas_frontend/core/components/comment_history/comments_table.dart";
import "package:wcas_frontend/core/components/gap.dart";
import "package:wcas_frontend/core/components/label.dart";
import "package:wcas_frontend/core/components/rich_text_editor/unified_text_editor.dart";
import "package:wcas_frontend/core/components/section_header.dart";
import "package:wcas_frontend/core/components/selectable_text.dart";
import "package:wcas_frontend/core/components/textarea.dart";
import "package:wcas_frontend/core/components/top_section/top_section_details.dart";
import "package:wcas_frontend/core/constants/constants.dart";
import "package:wcas_frontend/core/globals.dart";
import "package:wcas_frontend/core/utils/utils.dart";
import "package:wcas_frontend/features/layout/model.dart";
import "package:wcas_frontend/features/layout/view.dart";
import "package:wcas_frontend/features/request/covenants_conditions/conditions_summary/model.dart";
import "package:wcas_frontend/features/request/covenants_conditions/conditions_summary/state.dart";
import "package:wcas_frontend/features/request/covenants_conditions/conditions_summary/widgets/conditions_table.dart";

/// Desktop view for the conditions summary screen.
class ViewDesktop extends StatelessWidget {
  /// Creates the desktop view.
  const ViewDesktop({super.key});

  @override
  Widget build(BuildContext context) {
    final ConditionsSummaryViewModel viewModel =
        context.read<ConditionsSummaryViewModel>();
    return BlocBuilder<ConditionsSummaryViewModel, ConditionsSummaryState>(
      builder: (context, state) {
        return Layout(
          child: SingleChildScrollView(
            child: BoxLayout(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  CustomSectionHeader(
                    title: "covenantsConditions.conditionsSummary.title".tr(),
                  ),
                  const Gap(),
                  BoxLayout(
                    child: TopSectionDetails(request: Globals.request!),
                  ),
                  BoxLayout(
                    disabled: !(viewModel.canEdit || viewModel.canEditComments),
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
    ConditionsSummaryState state,
    ConditionsSummaryViewModel viewModel,
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

      default:
        return _buildView(state, viewModel, context);
    }
  }

  Widget _buildView(
    ConditionsSummaryState state,
    ConditionsSummaryViewModel viewModel,
    BuildContext context,
  ) {
    final bool canEditAny = viewModel.canEdit || viewModel.canEditComments;
    return Form(
      key: viewModel.formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ConditionsTableWidget(viewModel: viewModel),
          const Gap(),
          if (viewModel.canEdit)
            AddItemButton(
              onTap: () async => viewModel.showConditionCreate(context),
              isLeftSided: true,
              child: Text(
                "covenantsConditions.covenantsSummary.addConditions".tr(),
              ),
            ),
          const Gap(),
          if (viewModel.isFIFlow)
            LabelWidget(
              label: "covenantsConditions.covenantsSummary.remarkJustification"
                  .tr(),
              labelStyle: AppStyle.tableHeaderStyle,
              child: UnifiedTextEditor(
                disable: !canEditAny,
                key: const ValueKey("editor-condition-comments"),
                semanticLabel:
                    "covenantsConditions.covenantsSummary.remarkJustification"
                        .tr(),
                characterLimit: 5000,
                // initialText: (viewModel.comments.isNotEmpty)
                //     ? (viewModel.comments.first.comment ?? "")
                //     : "",
                initialText: viewModel.initialText,
                controller: viewModel.unifiedEditorController,
                scrollController: viewModel.scrollController,
                editorId: "condition-comments",
              ),
            ),
          if (!viewModel.isFIFlow)
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                CustomSelectableText(
                  text:
                      "covenantsConditions.covenantsSummary.remarkJustification"
                          .tr(),
                  semanticsLabel:
                      "covenantsConditions.covenantsSummary.remarkJustification"
                          .tr(),
                  textAlign: TextAlign.left,
                  style: AppStyle.tableHeaderStyle,
                ),
              ],
            ),
          if (!viewModel.isFIFlow)
            CustomTextArea(
              readOnly: !canEditAny,
              initialValue: (viewModel.comments.isNotEmpty)
                  ? (viewModel.comments.first.comment ?? "")
                  : "",
              onChanged: (value) {
                viewModel.comment.comment = value;
              },
              controller: viewModel.controller,
              maxLength: 5000,
            ),
          const Gap(),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              CustomSelectableText(
                semanticsLabel: "common.commentHistory".tr(),
                text: "common.commentHistory".tr(),
                textAlign: TextAlign.left,
                style: AppStyle.tableHeaderStyle,
              ),
            ],
          ),
          CommentsTableWidget(
            comments: viewModel.comments,
            ishtmlComment: viewModel.isFIFlow,
          ),
          const Gap(),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              if (canEditAny) ...[
                CustomButton(
                  semanticLabel: "common.saveAndContinue".tr(),
                  label: "common.saveAndContinue".tr(),
                  onPressed: () async {
                    await viewModel.saveComment();
                  },
                ),
              ],
              if (!canEditAny)
                CustomButton(
                  label: "Continue".tr(),
                  semanticLabel: "Continue".tr(),
                  onPressed: () async {
                    LayoutViewModel().goToNextRoute();
                  },
                ),
            ],
          ),
        ],
      ),
    );
  }
}
