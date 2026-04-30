import "package:easy_localization/easy_localization.dart";
import "package:flutter/material.dart";
import "package:flutter_bloc/flutter_bloc.dart";

import "package:wcas_frontend/core/components/box_layout.dart";
import "package:wcas_frontend/core/components/button.dart";
import "package:wcas_frontend/core/components/gap.dart";
import "package:wcas_frontend/core/components/section_header.dart";
import "package:wcas_frontend/core/components/top_section/top_section_details.dart";
import "package:wcas_frontend/core/globals.dart";
import "package:wcas_frontend/core/utils/utils.dart";
import "package:wcas_frontend/features/layout/view.dart";
import "package:wcas_frontend/features/request/approval/management_comments/model.dart";
import "package:wcas_frontend/features/request/approval/management_comments/state.dart";
import "package:wcas_frontend/features/request/approval/management_comments/widgets/comments_text_field.dart";

class ViewDesktop extends StatelessWidget {
  const ViewDesktop({super.key});

  @override
  Widget build(BuildContext context) {
    final ManagementCommentsViewModel viewModel =
        context.read<ManagementCommentsViewModel>();
    return BlocBuilder<ManagementCommentsViewModel, ManagementCommentsState>(
      builder: (context, state) {
        return Layout(
          child: BoxLayout(
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  CustomSectionHeader(
                    title: "approval.managementComments.title".tr(),
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
    ManagementCommentsState state,
    ManagementCommentsViewModel viewModel,
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
        return Form(
          key: viewModel.formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Gap(),
              CommentsTextField(
                isReadOnly: viewModel.isReadOnly,
                label:
                    "approval.managementComments.creditCommitteeRecommendations"
                        .tr(),
                initialValue: viewModel.creditCommitteeRecommendations,
                onSaved: (value) {
                  viewModel.creditCommitteeRecommendations = value ?? "";
                },
                onChange: (content) => context
                    .read<ManagementCommentsViewModel>()
                    .onTextChange(content, 1),
              ),
              const Gap(size: GapSize.medium),
              CommentsTextField(
                isReadOnly: viewModel.isReadOnly,
                label: "approval.managementComments.ccoComments".tr(),
                initialValue: viewModel.ccoComments,
                onSaved: (value) {
                  viewModel.ccoComments = value ?? "";
                },
                onChange: (content) => context
                    .read<ManagementCommentsViewModel>()
                    .onTextChange(content, 2),
              ),
              const Gap(size: GapSize.medium),
              CommentsTextField(
                isReadOnly: viewModel.isReadOnly,
                label: "approval.managementComments.ceoComments".tr(),
                initialValue: viewModel.ceoComments,
                onSaved: (value) {
                  viewModel.ceoComments = value ?? "";
                },
                onChange: (content) => context
                    .read<ManagementCommentsViewModel>()
                    .onTextChange(content, 3),
              ),
              const Gap(size: GapSize.medium),
              CommentsTextField(
                isReadOnly: viewModel.isReadOnly,
                label: "approval.managementComments.bcicComments".tr(),
                initialValue: viewModel.bcicComments,
                onSaved: (value) {
                  viewModel.bcicComments = value ?? "";
                },
                onChange: (content) => context
                    .read<ManagementCommentsViewModel>()
                    .onTextChange(content, 4),
              ),
              const Gap(size: GapSize.medium),
              if (!viewModel.isReadOnly)
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    CustomButton(
                      label: "approval.managementComments.save".tr(),
                      semanticLabel: "approval.managementComments.save".tr(),
                      onPressed: viewModel.canSubmit
                          ? () {
                              viewModel.onSavePress(context: context);
                            }
                          : null,
                    ),
                  ],
                ),
              const Gap(size: GapSize.medium),
            ],
          ),
        );
    }
  }
}
