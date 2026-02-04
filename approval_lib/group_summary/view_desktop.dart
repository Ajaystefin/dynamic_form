import 'package:easy_localization/easy_localization.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:wcas_frontend/core/components/box_layout.dart';
import 'package:wcas_frontend/core/components/button.dart';
import 'package:wcas_frontend/core/components/gap.dart';
import 'package:wcas_frontend/core/components/label.dart';
import 'package:wcas_frontend/core/components/section_header.dart';
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

class ViewDesktop extends StatelessWidget {
  const ViewDesktop({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<GroupSummaryViewModel, GroupSummaryState>(
        builder: (context, state) {
      final viewModel = context.read<GroupSummaryViewModel>();
      return Layout(
          child: BoxLayout(
        child: SingleChildScrollView(
          controller: viewModel.scrollController,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              CustomSectionHeader(title: 'layout.sidemenu.groupSummary'.tr()),
              const Gap(),
              BoxLayout(
                child: TopSectionDetails(request: Globals.request!),
              ),
              BoxLayout(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    TabMenu(
                      activeKey: state.activeTab,
                      routes: TabConstants.groupSumaryRoutes,
                      labels: TabConstants.groupSummaryTitles,
                      onTabChange: viewModel.changeTab,
                    ),
                    const Gap(),
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

  Widget _body(BuildContext context, GroupSummaryState state,
      GroupSummaryViewModel viewModel) {
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
        return _buildView(viewModel, state.activeTab, context);
    }
  }

  Widget _buildView(GroupSummaryViewModel viewModel, GroupSummaryTabs tab,
      BuildContext context) {
    return Form(
      key: viewModel.formKey,
      child: Column(
        children: [
          if (viewModel.checkVisibility(RequestStatus.approved))
            LabelWidget(
              label: viewModel.getTabLabel(tab),
              isRequired: true,
              labelStyle: AppStyle.tableHeaderStyle,
              child: UnifiedTextEditor(
                disable: viewModel.isReadOnly,
                semanticLabel: viewModel.getTabLabel(tab),
                controller: viewModel.controller,
                scrollController: viewModel.scrollController,
                characterLimit: 5000,
                initialText: viewModel.initialText,
              ),
            ),
          const Gap(),
          // CommentsTableWidget(
          //   comments: viewModel.comments ?? [],
          //   isStrategyComment: true,
          // ),
          if (viewModel.checkVisibility(RequestStatus.approved) &&
              !viewModel.isReadOnly) ...[
            const Gap(size: GapSize.medium),
            Row(mainAxisAlignment: MainAxisAlignment.end, children: [
              CustomButton(
                semanticLabel: "approval.groupSummary.save".tr(),
                label: "approval.groupSummary.save".tr(),
                onPressed: () {
                  viewModel.onSavePress(false, context: context);
                },
              ),
              const Gap(direction: Axis.horizontal),
              CustomButton(
                semanticLabel: "approval.groupSummary.saveAndContinue".tr(),
                label: "approval.groupSummary.saveAndContinue".tr(),
                onPressed: () {
                  viewModel.onSavePress(true, context: context);
                },
              ),
            ]),
          ],
          const Gap(size: GapSize.medium),
        ],
      ),
    );
  }
}
