import 'package:easy_localization/easy_localization.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:wcas_frontend/core/components/box_layout.dart';
import 'package:wcas_frontend/core/components/button.dart';
import 'package:wcas_frontend/core/components/comment_history/comments_table.dart';
import 'package:wcas_frontend/core/components/gap.dart';
import 'package:wcas_frontend/core/components/section_header.dart';
import 'package:wcas_frontend/core/components/selectable_text.dart';
import 'package:wcas_frontend/core/components/top_section/fields/request_type.dart'
    as top_section;

import 'package:wcas_frontend/core/components/text_editor.dart';
import 'package:wcas_frontend/core/components/top_section/fields/application_no.dart';
import 'package:wcas_frontend/core/components/top_section/fields/customer_name.dart';
import 'package:wcas_frontend/core/constants/constants.dart';
import 'package:wcas_frontend/core/globals.dart';
import 'package:wcas_frontend/core/utils/utils.dart';
import 'package:wcas_frontend/features/layout/view.dart';
import 'package:flutter/material.dart';
import 'package:wcas_frontend/features/request/ccsys/approval/widgets/save_button.dart';
import 'package:wcas_frontend/models/request/request.dart';

import 'model.dart';
import 'state.dart';

class ViewMobile extends StatelessWidget {
  const ViewMobile({super.key});

  @override
  Widget build(BuildContext context) {
    CcsysApprovalViewModel viewModel = context.read<CcsysApprovalViewModel>();
    return BlocBuilder<CcsysApprovalViewModel, CcsysApprovalState>(
        builder: (context, state) {
      return Layout(
          child: SingleChildScrollView(
        child: BoxLayout(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              CustomSectionHeader(
                  title: "ccsys.recommendationApproval.sectionTitle".tr()),
              const Gap(),
              BoxLayout(
                  child: Column(
                children: [
                  ApplicationNo(request: Globals.request!),
                  CustomerName(
                    request: Globals.request ?? Request(),
                  ),
                  top_section.RequestType(
                      request: Request(
                    applicationType: viewModel.applicationTypes.first,
                  ))
                ],
              )),
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
      ));
    });
  }

  Widget _body(BuildContext context, CcsysApprovalState state,
      CcsysApprovalViewModel viewModel) {
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
        return _buildView(viewModel, context, state);
    }
  }

  Widget _buildView(CcsysApprovalViewModel viewModel, BuildContext context,
      CcsysApprovalState state) {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      CustomSelectableText(
        text: "${viewModel.roleCode} ${"approval.comments.tabTitle".tr()}",
        textAlign: TextAlign.left,
        style: AppStyle.tableHeaderStyle,
      ),
      CustomTextEditorWidget(
        controller: viewModel.controller,
      ),
      const Gap(),
      CommentsTableWidget(comments: viewModel.comments),
      const Gap(),
      Row(mainAxisAlignment: MainAxisAlignment.end, children: [
        SaveButton(viewModel: viewModel),
        const Gap(
          size: GapSize.medium,
          direction: Axis.horizontal,
        ),
        if (viewModel.showApproveButton)
          CustomButton(
            semanticLabel: "approval.comments.approve".tr(),
            label: "approval.comments.approve".tr(),
            onPressed: () => viewModel.onSavePress(),
          ),
        if (viewModel.showRecommendButton)
          CustomButton(
            semanticLabel: "Recommend".tr(),
            label: "Recommend".tr(),
            onPressed: () => viewModel.onSavePress(),
          ),
      ]),
      const Gap(size: GapSize.medium),
    ]);
  }
}
