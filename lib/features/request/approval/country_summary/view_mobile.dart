import "package:easy_localization/easy_localization.dart";
import "package:flutter/material.dart";
import "package:flutter_bloc/flutter_bloc.dart";

import "package:wcas_frontend/core/components/box_layout.dart";
import "package:wcas_frontend/core/components/button.dart";
import "package:wcas_frontend/core/components/gap.dart";
import "package:wcas_frontend/core/components/label.dart";
import "package:wcas_frontend/core/components/rich_text_editor/unified_text_editor.dart";
import "package:wcas_frontend/core/components/section_header.dart";
import "package:wcas_frontend/core/components/tab_menu.dart";
import "package:wcas_frontend/core/components/top_section/top_section_details.dart";
import "package:wcas_frontend/core/constants/constants.dart";
import "package:wcas_frontend/core/globals.dart";
import "package:wcas_frontend/core/utils/utils.dart";
import "package:wcas_frontend/features/layout/view.dart";
import "package:wcas_frontend/features/request/approval/country_summary/model.dart";
import "package:wcas_frontend/features/request/approval/country_summary/state.dart";

class ViewMobile extends StatelessWidget {
  const ViewMobile({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<CountrySummaryViewModel, CountrySummaryState>(
      builder: (context, state) {
        final viewModel = context.read<CountrySummaryViewModel>();
        return Layout(
          child: BoxLayout(
            child: SingleChildScrollView(
              controller: viewModel.scrollController,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  CustomSectionHeader(
                    title: "approval.countrySummary.title".tr(),
                  ),
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
                          routes: TabConstants.countrySumaryRoutes,
                          labels: TabConstants.countrySummaryTitles,
                          onTabChange: viewModel.changeTab,
                        ),
                        BoxLayout(
                          child: _body(context, state, viewModel),
                        ),
                      ],
                    ),
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
    CountrySummaryState state,
    CountrySummaryViewModel viewModel,
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
        return _buildView(viewModel, state.activeTab, context);
    }
  }

  Widget _buildView(
    CountrySummaryViewModel viewModel,
    CountrySummaryTabs tab,
    BuildContext context,
  ) {
    return Form(
      key: viewModel.formKey,
      child: Column(
        children: [
          if (!viewModel.isEditable)
            Text("approval.countrySummary.nonEditableMessage".tr()),
          LabelWidget(
            label: viewModel.getTabLabel(tab),
            isRequired: viewModel.isEditable,
            labelStyle: AppStyle.tableHeaderStyle,
            child: UnifiedTextEditor(
              disable: viewModel.isReadOnly,
              semanticLabel: viewModel.getTabLabel(tab),
              controller: viewModel.controller,
              scrollController: viewModel.scrollController,
              characterLimit: 5000,
              initialText: viewModel.initialText,
              editorId: "approval.countrySummary",
            ),
          ),
          const Gap(),
          if (!viewModel.isReadOnly) ...[
            const Gap(size: GapSize.medium),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                CustomButton(
                  semanticLabel: "approval.countrySummary.save".tr(),
                  label: "approval.countrySummary.save".tr(),
                  onPressed: () {
                    viewModel.onSavePress(false, context: context);
                  },
                ),
                const Gap(direction: Axis.horizontal),
                CustomButton(
                  label: "approval.countrySummary.saveAndContinue".tr(),
                  semanticLabel: "approval.countrySummary.saveAndContinue".tr(),
                  onPressed: () {
                    viewModel.onSavePress(true, context: context);
                  },
                ),
              ],
            ),
          ],
          const Gap(size: GapSize.medium),
        ],
      ),
    );
  }
}
