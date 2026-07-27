import "package:easy_localization/easy_localization.dart";
import "package:flutter/material.dart";
import "package:flutter_bloc/flutter_bloc.dart";

import "package:wcas_frontend/core/components/box_layout.dart";
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
import "package:wcas_frontend/core/utils/validators.dart";
import "package:wcas_frontend/features/layout/view.dart";
import "package:wcas_frontend/features/request/approval/request_for_fol/model.dart";
import "package:wcas_frontend/features/request/approval/request_for_fol/state.dart";
import "package:wcas_frontend/features/request/approval/request_for_fol/widgets/bottom_controls.dart";

/// Displays the desktop view for the request for FOL approval screen.
class ViewDesktop extends StatelessWidget {
  /// Creates the desktop request for FOL approval view.
  const ViewDesktop({super.key});

  @override
  Widget build(BuildContext context) {
    final RequestForFolViewModel viewModel =
        context.read<RequestForFolViewModel>();
    return BlocBuilder<RequestForFolViewModel, RequestForFolState>(
      builder: (context, state) {
        return Layout(
          child: SingleChildScrollView(
            child: BoxLayout(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  CustomSectionHeader(
                    title: "approval.requestForFOL.sectionTitle".tr(),
                  ),
                  const Gap(),
                  BoxLayout(
                    child: TopSectionDetails(request: Globals.request!),
                  ),
                  BoxLayout(
                    child: _body(context, state, viewModel),
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
    RequestForFolState state,
    RequestForFolViewModel viewModel,
  ) {
    switch (state.loaderStatus) {
      case LoadingStatus.loading:
        return const Center(
          child: CircularProgressIndicator(),
        );
      case LoadingStatus.empty:
        return Center(
          child: Text("Empty State".tr()),
        );
      case LoadingStatus.error:
        return Center(
          child: Text("Error State".tr()),
        );
      default:
        return _buildView(context, state, viewModel);
    }
  }

  Widget _buildView(
    BuildContext context,
    RequestForFolState state,
    RequestForFolViewModel viewModel,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Gap(),
        LabelWidget(
          isRequired: true,
          labelStyle: const TextStyle(fontWeight: FontWeight.bold),
          label: "approval.requestForFOL.remarkJustification".tr(),
          child: UnifiedTextEditor(
            disable: viewModel.isReadOnly,
            semanticLabel: "approval.requestForFOL.remarkJustification".tr(),
            characterLimit: 5000,
            controller: viewModel.controller,
            initialText: viewModel.initialText,
            editorId: "request-for-fol",
            scrollController: viewModel.scrollController,
          ),
        ),
        const Gap(),
        if (viewModel.showAdditionalComment) ...[
          LabelWidget(
            isRequired: true,
            labelStyle: const TextStyle(fontWeight: FontWeight.bold),
            label: "approval.requestForFOL.comments".tr(),
            child: CustomTextArea(
              readOnly: viewModel.isReadOnly,
              semanticLabel: "approval.requestForFOL.comments".tr(),
              maxLength: 2000,
              initialValue: viewModel.additionalComment,
              validator: CustomValidator.requiredField,
              onChanged: (String value) {
                viewModel.additionalComment = value;
              },
            ),
          ),
          const Gap(),
        ],
        if (viewModel.comments.isNotEmpty && viewModel.isCommentVisible) ...[
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              CustomSelectableText(
                text: "approval.requestForFOL.commentHistory".tr(),
                semanticsLabel: "approval.requestForFOL.commentHistory".tr(),
                textAlign: TextAlign.left,
                style: AppStyle.tableHeaderStyle,
              ),
            ],
          ),
          CommentsTableWidget(
            comments: viewModel.comments,
            ishtmlComment: true,
          ),
        ],
        const Gap(),
        BottomControls(
          viewModel: viewModel,
          context: context,
        ),
        const Gap(),
      ],
    );
  }
}
