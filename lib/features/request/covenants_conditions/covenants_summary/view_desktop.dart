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
import "package:wcas_frontend/features/request/covenants_conditions/covenants_summary/model.dart";
import "package:wcas_frontend/features/request/covenants_conditions/covenants_summary/state.dart";
import "package:wcas_frontend/features/request/covenants_conditions/covenants_summary/widgets/covenants_table.dart";

class ViewDesktop extends StatelessWidget {
  const ViewDesktop({super.key});

  @override
  Widget build(BuildContext context) {
    final CovenantsSummaryViewModel viewModel =
        context.read<CovenantsSummaryViewModel>();
    return BlocBuilder<CovenantsSummaryViewModel, CovenantsSummaryState>(
      builder: (context, state) {
        return Layout(
          child: SingleChildScrollView(
            scrollDirection: Axis.vertical,
            child: BoxLayout(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  CustomSectionHeader(
                    title: "covenantsConditions.covenantsSummary.title".tr(),
                  ),
                  const Gap(),
                  BoxLayout(
                    child: TopSectionDetails(request: Globals.request!),
                  ),
                  BoxLayout(
                    disabled: !viewModel.canEdit,
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
    CovenantsSummaryState state,
    CovenantsSummaryViewModel viewModel,
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
    CovenantsSummaryState state,
    CovenantsSummaryViewModel viewModel,
    BuildContext context,
  ) {
    return Form(
      key: viewModel.formKey,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CovenantTableWidget(viewModel: viewModel),
          const Gap(),
          if (viewModel.canEdit)
            AddItemButton(
              onTap: (viewModel.isReadOnly)
                  ? null
                  : () async => viewModel.showCovenantCreate(context),
              isLeftSided: true,
              child: Text(
                "covenantsConditions.covenantEditDialog.addCovenants".tr(),
              ),
            ),
          const Gap(),
          if (viewModel.isFIFlow)
            LabelWidget(
              label: "covenantsConditions.covenantsSummary.remarkJustification"
                  .tr(),
              labelStyle: AppStyle.tableHeaderStyle,
              child: UnifiedTextEditor(
                disable: !viewModel.canEdit,
                key: const ValueKey("editor-covenants-comments"),
                semanticLabel:
                    "covenantsConditions.covenantsSummary.remarkJustification"
                        .tr(),
                initialText: (viewModel.comments.isNotEmpty)
                    ? (viewModel.comments.last.comment ?? "")
                    : "",
                characterLimit: 5000,
                controller: viewModel.unifiedEditorController,
                scrollController: viewModel.scrollController,
                editorId: "covenants-comments",
              ),
            ),
          if (!viewModel.isFIFlow)
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                CustomSelectableText(
                  semanticsLabel:
                      "covenantsConditions.covenantsSummary.remarkJustification"
                          .tr(),
                  text:
                      "covenantsConditions.covenantsSummary.remarkJustification"
                          .tr(),
                  textAlign: TextAlign.left,
                  style: AppStyle.tableHeaderStyle,
                ),
              ],
            ),
          if (!viewModel.isFIFlow)
            CustomTextArea(
              readOnly: !viewModel.canEdit,
              initialValue: (viewModel.comments.isNotEmpty)
                  ? (viewModel.comments.last.comment ?? "")
                  : "",
              controller: viewModel.controller,
              maxLength: 5000,
              onChanged: (value) {
                viewModel.comment?.comment = value;
              },
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
            spacing: 4,
            children: [
              if (viewModel.canEdit)
                CustomButton(
                  label: "common.saveAndContinue".tr(),
                  semanticLabel: "common.saveAndContinue".tr(),
                  onPressed: () async {
                    await viewModel.saveComment(ifNavigate: true);
                  },
                ),
              if (!viewModel.canEdit)
                CustomButton(
                  ignoreProvider: true,
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
