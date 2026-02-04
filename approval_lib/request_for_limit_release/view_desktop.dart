import 'package:easy_localization/easy_localization.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:wcas_frontend/core/components/box_layout.dart';
import 'package:wcas_frontend/core/components/comment_history/comments_table.dart';
import 'package:wcas_frontend/core/components/gap.dart';
import 'package:wcas_frontend/core/components/label.dart';
import 'package:wcas_frontend/core/components/section_header.dart';
import 'package:wcas_frontend/core/components/selectable_text.dart';
import 'package:wcas_frontend/core/components/rich_text_editor/unified_text_editor.dart';
import 'package:wcas_frontend/core/components/top_section/top_section_details.dart';
import 'package:wcas_frontend/core/constants/constants.dart';
import 'package:wcas_frontend/core/globals.dart';
import 'package:wcas_frontend/core/utils/utils.dart';
import 'package:wcas_frontend/features/layout/view.dart';
import 'package:flutter/material.dart';
import 'package:wcas_frontend/features/request/approval/request_for_limit_release/widgets/bottom_controls.dart';
import 'model.dart';
import 'state.dart';

class ViewDesktop extends StatelessWidget {
  const ViewDesktop({super.key});

  @override
  Widget build(BuildContext context) {
    RequestForLimitReleaseViewModel viewModel =
        context.read<RequestForLimitReleaseViewModel>();
    return BlocBuilder<RequestForLimitReleaseViewModel,
        RequestForLimitReleaseState>(builder: (context, state) {
      return Layout(
        child: SingleChildScrollView(
          controller: viewModel.scrollController,
          scrollDirection: Axis.vertical,
          child: BoxLayout(
              child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              CustomSectionHeader(
                  title: "approval.requestForLimitRelease.sectionTitle".tr()),
              const Gap(),
              BoxLayout(
                child: TopSectionDetails(request: Globals.request!),
              ),
              BoxLayout(
                child: _body(context, state, viewModel),
              ),
            ],
          )),
        ),
      );
    });
  }

  Widget _body(BuildContext context, RequestForLimitReleaseState state,
      RequestForLimitReleaseViewModel viewModel) {
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
        return _buildView(context, state, viewModel);
    }
  }

  Widget _buildView(BuildContext context, RequestForLimitReleaseState state,
      RequestForLimitReleaseViewModel viewModel) {
    return Column(children: [
      const Gap(),
      LabelWidget(
        isRequired: true,
        label: "approval.requestForLimitRelease.remarkJustification".tr(),
        labelStyle: const TextStyle(fontWeight: FontWeight.bold),
        // child: CustomTextArea(
        //   semanticLabel:
        //       "approval.requestForLimitRelease.remarkJustification".tr(),
        //   maxLength: 5000,
        //   initialValue: viewModel.strategyComment,
        //   validator: CustomValidator.requiredField,
        //   onSaved: (String? value) {
        //     viewModel.strategyComment = value;
        //   },
        // ),
        child: UnifiedTextEditor(
          disable: viewModel.isReadOnly,
          semanticLabel:
              "approval.requestForLimitRelease.remarkJustification".tr(),
          characterLimit: 5000,
          controller: viewModel.controller,
          scrollController: viewModel.scrollController,
          initialText: viewModel.initialText,
        ),
      ),
      const Gap(),
      Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
        CustomSelectableText(
          semanticsLabel: "approval.requestForLimitRelease.commentHistory".tr(),
          text: "approval.requestForLimitRelease.commentHistory".tr(),
          textAlign: TextAlign.left,
          style: AppStyle.tableHeaderStyle,
        ),
      ]),
      const Gap(),
      CommentsTableWidget(comments: viewModel.comments),
      if (!viewModel.isReadOnly) ...[
        const Gap(),
        BottomControls(
          viewModel: viewModel,
          context: context,
        )
      ]
    ]);
  }
}
