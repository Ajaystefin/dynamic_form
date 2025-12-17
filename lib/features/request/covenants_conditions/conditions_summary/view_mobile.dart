import 'package:easy_localization/easy_localization.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:wcas_frontend/core/components/add_item_button.dart';
import 'package:wcas_frontend/core/components/button.dart';
import 'package:wcas_frontend/core/components/gap.dart';
import 'package:wcas_frontend/core/components/selectable_text.dart';
import 'package:wcas_frontend/core/components/textarea.dart';
import 'package:wcas_frontend/core/components/top_section/top_section_details.dart';
import 'package:wcas_frontend/core/constants/constants.dart';
import 'package:wcas_frontend/core/globals.dart';
import 'package:wcas_frontend/core/utils/utils.dart';
import 'package:wcas_frontend/core/components/comment_history/comments_table.dart';
import 'package:wcas_frontend/features/layout/view.dart';
import 'package:flutter/material.dart';
import 'package:wcas_frontend/core/components/box_layout.dart';
import 'package:wcas_frontend/core/components/section_header.dart';
import 'package:wcas_frontend/features/request/covenants_conditions/conditions_summary/widgets/conditions_table.dart';
import 'model.dart';
import 'state.dart';

class ViewMobile extends StatelessWidget {
  const ViewMobile({super.key});

  @override
  Widget build(BuildContext context) {
    ConditionsSummaryViewModel viewModel =
        context.read<ConditionsSummaryViewModel>();
    return BlocBuilder<ConditionsSummaryViewModel, ConditionsSummaryState>(
        builder: (context, state) {
      return Layout(
        child: SingleChildScrollView(
          scrollDirection: Axis.vertical,
          child: BoxLayout(
              child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              CustomSectionHeader(
                  title: "covenantsConditions.conditionsSummary.title".tr()),
              const Gap(),
              BoxLayout(
                child: TopSectionDetails(request: Globals.request!),
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
          )),
        ),
      );
    });
  }

  Widget _body(BuildContext context, ConditionsSummaryState state,
      ConditionsSummaryViewModel viewModel) {
    switch (state.loaderStatus) {
      case LoadingStatus.loading:
        return const Center(
          child: CircularProgressIndicator(),
        );
      case LoadingStatus.empty:
        return Center(
          child: Text('common.emptyState'.tr()),
        );

      default:
        return _buildView(state, viewModel, context);
    }
  }

  Widget _buildView(ConditionsSummaryState state,
      ConditionsSummaryViewModel viewModel, BuildContext context) {
    return Form(
      key: viewModel.formKey,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ConditionsTableWidget(viewModel: viewModel),
          const Gap(),
          if (!viewModel.isViewOnlyMode & !viewModel.isReadOnlyMode)
            AddItemButton(
              onTap: () async => await viewModel.showConditionCreate(context),
              isLeftSided: true,
              child: Text(
                  "covenantsConditions.covenantsSummary.addConditions".tr()),
            ),
          const Gap(),
          Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
            CustomSelectableText(
              text: "covenantsConditions.covenantsSummary.remarkJustification"
                  .tr(),
              semanticsLabel:
                  "covenantsConditions.covenantsSummary.remarkJustification"
                      .tr(),
              textAlign: TextAlign.left,
              style: AppStyle.tableHeaderStyle,
            ),
          ]),
          CustomTextArea(
            initialValue: viewModel.comment.comment,
            onChanged: (value) {
              viewModel.comment.comment = value;
            },
            maxLength: 5000,
          ),
          const Gap(),
          Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
            CustomSelectableText(
              text: "common.commentHistory".tr(),
              semanticsLabel: "common.commentHistory".tr(),
              textAlign: TextAlign.left,
              style: AppStyle.tableHeaderStyle,
            ),
          ]),
          CommentsTableWidget(comments: viewModel.comments),
          const Gap(),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            spacing: 4,
            children: [
              CustomButton(
                  semanticLabel: "common.saveAndContinue".tr(),
                  label: "common.saveAndContinue".tr(),
                  onPressed: () async {
                    await viewModel.saveComment();
                  }),
            ],
          )
        ],
      ),
    );
  }
}
