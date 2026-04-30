import "package:easy_localization/easy_localization.dart";
import "package:flutter/material.dart";
import "package:flutter_bloc/flutter_bloc.dart";

import "package:wcas_frontend/core/components/box_layout.dart";
import "package:wcas_frontend/core/components/comment_history/comments_table.dart";
import "package:wcas_frontend/core/components/gap.dart";
import "package:wcas_frontend/core/components/label.dart";
import "package:wcas_frontend/core/components/section_header.dart";
import "package:wcas_frontend/core/components/selectable_text.dart";
import "package:wcas_frontend/core/components/textarea.dart";
import "package:wcas_frontend/core/components/top_section/top_section_details.dart";
import "package:wcas_frontend/core/constants/constants.dart";
import "package:wcas_frontend/core/globals.dart";
import "package:wcas_frontend/core/utils/utils.dart";
import "package:wcas_frontend/core/utils/validators.dart";
import "package:wcas_frontend/features/layout/view.dart";
import "package:wcas_frontend/features/request/approval/request_for_closure/model.dart";
import "package:wcas_frontend/features/request/approval/request_for_closure/state.dart";
import "package:wcas_frontend/features/request/approval/request_for_closure/widgets/bottom_controls.dart";

class ViewDesktop extends StatelessWidget {
  const ViewDesktop({super.key});

  @override
  Widget build(BuildContext context) {
    final RequestForClosureViewModel viewModel =
        context.read<RequestForClosureViewModel>();
    return BlocBuilder<RequestForClosureViewModel, RequestForClosureState>(
      builder: (context, state) {
        return Layout(
          child: SingleChildScrollView(
            child: BoxLayout(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  CustomSectionHeader(
                    title: "approval.requestForClosure.sectionTitle".tr(),
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
    RequestForClosureState state,
    RequestForClosureViewModel viewModel,
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
        return _buildView(context, state, viewModel);
    }
  }

  Widget _buildView(
    BuildContext context,
    RequestForClosureState state,
    RequestForClosureViewModel viewModel,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Gap(),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            CustomSelectableText(
              text: "approval.requestForClosure.commentHistory".tr(),
              semanticsLabel: "approval.requestForClosure.commentHistory".tr(),
              textAlign: TextAlign.left,
              style: AppStyle.tableHeaderStyle,
            ),
          ],
        ),
        CommentsTableWidget(
          comments: viewModel.comments ?? [],
          ishtmlComment: true,
        ),
        const Gap(),
        LabelWidget(
          isRequired: true,
          labelStyle: const TextStyle(fontWeight: FontWeight.bold),
          label: "approval.requestForClosure.remarkJustification".tr(),
          child: CustomTextArea(
            readOnly: viewModel.isReadOnly,
            semanticLabel:
                "approval.requestForClosure.remarkJustification".tr(),
            maxLength: 5000,
            initialValue: viewModel.strategyComment,
            validator: CustomValidator.requiredField,
            onChanged: (String? value) {
              viewModel.strategyComment = value;
              context
                  .read<RequestForClosureViewModel>()
                  .onTextChange(value ?? "");
            },
          ),
        ),
        const Gap(),
        if (!viewModel.isReadOnly) ...[
          BottomControls(
            viewModel: viewModel,
            context: context,
            canSubmit: viewModel.canSubmit,
          ),
          const Gap(),
        ],
      ],
    );
  }
}
