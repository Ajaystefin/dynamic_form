import 'package:easy_localization/easy_localization.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:wcas_frontend/core/components/box_layout.dart';
import 'package:wcas_frontend/core/components/comment_history/comments_table.dart';
import 'package:wcas_frontend/core/components/gap.dart';
import 'package:wcas_frontend/core/components/section_header.dart';
import 'package:wcas_frontend/core/components/selectable_text.dart';
import 'package:wcas_frontend/core/components/tab_menu.dart';
import 'package:wcas_frontend/core/components/text_editor.dart';
import 'package:wcas_frontend/core/components/top_section/top_section_details.dart';
import 'package:wcas_frontend/core/constants/constants.dart';
import 'package:wcas_frontend/core/globals.dart';
import 'package:wcas_frontend/core/utils/utils.dart';
import 'package:wcas_frontend/features/layout/view.dart';
import 'package:flutter/material.dart';
import 'package:wcas_frontend/features/request/approval/comments/widgets/bottom_controls.dart';

import 'model.dart';
import 'state.dart';

class ViewDesktop extends StatelessWidget {
  const ViewDesktop({super.key});

  @override
  Widget build(BuildContext context) {
    CommentsViewModel viewModel = context.read<CommentsViewModel>();
    return BlocBuilder<CommentsViewModel, CommentsState>(
        builder: (context, state) {
      return Layout(
          child: SingleChildScrollView(
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
                    const TabMenu(
                        activeKey: RecommendationTabs.comments,
                        routes: TabConstants.recommendationRoutes,
                        labels: TabConstants.recommendationTitles),
                    BoxLayout(
                      child: _body(context, state, viewModel),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ));
    });
  }

  Widget _body(
      BuildContext context, CommentsState state, CommentsViewModel viewModel) {
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

  Widget _buildView(
    CommentsViewModel viewModel,
    BuildContext context,
    CommentsState state,
  ) {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      CustomSelectableText(
        text: "${state.getRole} ${"approval.comments.tabTitle".tr()}",
        semanticsLabel: "${state.getRole} ${"approval.comments.tabTitle".tr()}",
        textAlign: TextAlign.left,
        style: AppStyle.tableHeaderStyle,
      ),
      CustomTextEditorWidget(
        controller: viewModel.controller,
      ),
      const Gap(),
      Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
        CustomSelectableText(
          semanticsLabel: "approval.comments.commentHistory".tr(),
          text: "approval.comments.commentHistory".tr(),
          textAlign: TextAlign.left,
          style: AppStyle.tableHeaderStyle,
        )
      ]),
      const Gap(),
      CommentsTableWidget(comments: viewModel.comments),
      const Gap(),
      BottomControls(
        viewModel: viewModel,
        context: context,
      ),
      const Gap(),
    ]);
  }
}
