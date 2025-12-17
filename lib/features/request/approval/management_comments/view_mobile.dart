import 'package:easy_localization/easy_localization.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:wcas_frontend/core/components/box_layout.dart';
import 'package:wcas_frontend/core/components/button.dart';
import 'package:wcas_frontend/core/components/gap.dart';
import 'package:wcas_frontend/core/components/section_header.dart';
import 'package:wcas_frontend/core/components/top_section/top_section_details.dart';
import 'package:wcas_frontend/core/globals.dart';
import 'package:wcas_frontend/core/utils/utils.dart';
import 'package:wcas_frontend/features/layout/view.dart';
import 'package:flutter/material.dart';
import 'package:wcas_frontend/features/request/approval/management_comments/widgets/comments_text_field.dart';

import 'model.dart';
import 'state.dart';

class ViewMobile extends StatelessWidget {
  const ViewMobile({super.key});

  @override
  Widget build(BuildContext context) {
    ManagementCommentsViewModel viewModel =
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
                  title: "approval.managementComments.title".tr()),
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
      ));
    });
  }

  Widget _body(BuildContext context, ManagementCommentsState state,
      ManagementCommentsViewModel viewModel) {
    switch (state.loaderStatus) {
      case LoadingStatus.loading:
        return const Center(
          child: CircularProgressIndicator(),
        );
      case LoadingStatus.empty:
        return Center(
          child: Text('common.emptyState'.tr()),
        );
      case LoadingStatus.error:
        return Center(
          child: Text('common.errorState'.tr()),
        );
      default:
        return Form(
          key: viewModel.formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Gap(),
              CommentsTextField(
                label:
                    "approval.managementComments.creditCommitteeRecommendations"
                        .tr(),
                initialValue: viewModel.creditCommitteeRecommendations,
                onSaved: (value) {
                  viewModel.creditCommitteeRecommendations = value ?? '';
                },
              ),
              const Gap(size: GapSize.medium),
              CommentsTextField(
                label: "approval.managementComments.ccoComments".tr(),
                initialValue: viewModel.ccoComments,
                onSaved: (value) {
                  viewModel.ccoComments = value ?? '';
                },
              ),
              const Gap(size: GapSize.medium),
              CommentsTextField(
                label: "approval.managementComments.ceoComments".tr(),
                initialValue: viewModel.ceoComments,
                onSaved: (value) {
                  viewModel.ceoComments = value ?? '';
                },
              ),
              const Gap(size: GapSize.medium),
              CommentsTextField(
                label: "approval.managementComments.bcicComments".tr(),
                initialValue: viewModel.bcicComments,
                onSaved: (value) {
                  viewModel.bcicComments = value ?? '';
                },
              ),
              const Gap(size: GapSize.medium),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  CustomButton(
                    label: "approval.managementComments.save".tr(),
                    semanticLabel: "approval.managementComments.save".tr(),
                    onPressed: () {
                      viewModel.onSave();
                    },
                  )
                ],
              ),
              const Gap(size: GapSize.medium),
            ],
          ),
        );
    }
  }
}
