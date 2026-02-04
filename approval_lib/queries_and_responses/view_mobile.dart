import 'package:easy_localization/easy_localization.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:wcas_frontend/core/components/box_layout.dart';
import 'package:wcas_frontend/core/components/button.dart';
import 'package:wcas_frontend/core/components/comment_history/comments_table.dart';
import 'package:wcas_frontend/core/components/gap.dart';
import 'package:wcas_frontend/core/components/section_header.dart';
import 'package:wcas_frontend/core/components/selectable_text.dart';

import 'package:wcas_frontend/core/components/tab_menu.dart';
import 'package:wcas_frontend/core/components/rich_text_editor/unified_text_editor.dart';
import 'package:wcas_frontend/core/components/top_section/top_section_details.dart';
import 'package:wcas_frontend/core/constants/constants.dart';
import 'package:wcas_frontend/core/globals.dart';
import 'package:wcas_frontend/core/utils/utils.dart';
import 'package:wcas_frontend/features/layout/view.dart';
import 'package:flutter/material.dart';
import 'model.dart';
import 'state.dart';

class ViewMobile extends StatelessWidget {
  const ViewMobile({super.key});

  @override
  Widget build(BuildContext context) {
    QueriesAndResponsesViewModel viewModel =
        context.read<QueriesAndResponsesViewModel>();
    return BlocBuilder<QueriesAndResponsesViewModel, QueriesAndResponsesState>(
        builder: (context, state) {
      return Layout(
        child: SingleChildScrollView(
          controller: viewModel.scrollController,
          scrollDirection: Axis.vertical,
          child: BoxLayout(
              child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              CustomSectionHeader(title: "approval.sectionTitle".tr()),
              const Gap(),
              BoxLayout(
                child: TopSectionDetails(request: Globals.request!),
              ),
              BoxLayout(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    TabMenu(
                      activeKey: RecommendationTabs.queriesAndResponses,
                      routes: TabConstants.recommendationRoutes,
                      labels: TabConstants.recommendationTitles,
                      conditionalRoutes: TabConstants.getRecommendationRoutes(),
                    ),
                    BoxLayout(
                      child: _body(context, state, viewModel),
                    ),
                  ],
                ),
              ),
            ],
          )),
        ),
      );
    });
  }

  Widget _body(BuildContext context, QueriesAndResponsesState state,
      QueriesAndResponsesViewModel viewModel) {
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
        return _buildView(context, viewModel);
    }
  }

  Widget _buildView(
      BuildContext context, QueriesAndResponsesViewModel viewModel) {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      const Gap(),
      Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
        CustomSelectableText(
          text: "approval.requestForFOL.commentHistory".tr(),
          semanticsLabel: "approval.requestForFOL.commentHistory".tr(),
          textAlign: TextAlign.left,
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
        )
      ]),
      CommentsTableWidget(
        comments: viewModel.comments,
        isStrategyComment: true,
      ),
      const Gap(),
      if (viewModel.isReadOnly) ...[
        Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
          CustomSelectableText(
            text: "approval.comments.comments".tr(),
            semanticsLabel: "approval.comments.comments".tr(),
            textAlign: TextAlign.left,
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
          )
        ]),
        UnifiedTextEditor(
          controller: viewModel.controller,
          scrollController: viewModel.scrollController,
          characterLimit: 5000,
          initialText: viewModel.initialText,
        ),
        const Gap(),
        if (!viewModel.isReadOnly) ...[
          Row(
            // spacing: 10,
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              CustomButton(
                label: "common.save".tr(),
                semanticLabel: "common.save".tr(),
                onPressed: () async {
                  String getStringFromHtmlEditController =
                      await viewModel.controller.getText();
                  viewModel.comment?.comment = getStringFromHtmlEditController;
                  if (context.mounted) {
                    viewModel.onSavePress(context: context);
                  }
                },
              ),
              CustomButton(
                label: "common.saveAndContinue".tr(),
                semanticLabel: "common.saveAndContinue".tr(),
                onPressed: () {
                  viewModel.onSavePress(context: context, isContinue: true);
                },
              ),
            ],
          )
        ]
      ]
    ]);
  }
}
