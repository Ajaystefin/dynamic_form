import "package:easy_localization/easy_localization.dart";
import "package:flutter/material.dart";
import "package:flutter_bloc/flutter_bloc.dart";

import "package:wcas_frontend/core/components/box_layout.dart";
import "package:wcas_frontend/core/components/customer_dropdown.dart";
import "package:wcas_frontend/core/components/gap.dart";
import "package:wcas_frontend/core/components/label.dart";
import "package:wcas_frontend/core/components/rich_text_editor/unified_text_editor.dart";
import "package:wcas_frontend/core/components/section_header.dart";
import "package:wcas_frontend/core/components/selectable_text.dart";
import "package:wcas_frontend/core/components/tab_menu.dart";
import "package:wcas_frontend/core/components/top_section/top_section_details.dart";
import "package:wcas_frontend/core/constants/constants.dart";
import "package:wcas_frontend/core/globals.dart";
import "package:wcas_frontend/core/utils/utils.dart";
import "package:wcas_frontend/features/layout/view.dart";
import "package:wcas_frontend/features/request/remarks/common_tabs/model.dart";
import "package:wcas_frontend/features/request/remarks/common_tabs/state.dart";
import "package:wcas_frontend/features/request/remarks/common_tabs/widgets/action.dart";

class ViewDesktop extends StatelessWidget {
  const ViewDesktop({super.key});

  @override
  Widget build(BuildContext context) {
    final CommonTabsViewModel viewModel = context.read<CommonTabsViewModel>();
    return BlocBuilder<CommonTabsViewModel, CommonTabsState>(
      builder: (context, state) {
        return Layout(
          child: SingleChildScrollView(
            controller: viewModel.scrollController,
            child: BoxLayout(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  CustomSectionHeader(title: "remarks.title".tr()),
                  const Gap(),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      BoxLayout(
                        child: TopSectionDetails(request: Globals.request!),
                      ),
                      BoxLayout(
                        extraPadding: true,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            CustomCustomerDropdown(
                              onCustomerChange: viewModel.onChangeCustomer,
                              selectedCustomer: viewModel.selectedCustomer,
                              customerList: viewModel.customerList,
                              onRefresh: () {
                                viewModel.onChangeCustomer(
                                  viewModel.selectedCustomer!,
                                );
                              },
                            ),
                            const Gap(),
                            CustomSelectableText(
                              text: "${"remarks.selectCustomerLabel".tr()}: "
                                  "${viewModel.selectedCustomer?.displayName}",
                              semanticsLabel:
                                  "${"remarks.selectCustomerLabel".tr()}: "
                                  "${viewModel.selectedCustomer?.displayName}",
                              style: AppStyle.boldLabel,
                            ),
                            const Gap(),
                            TabMenu<RemarksTabs>(
                              activeKey: state.activeTab,
                              routes: TabConstants.remarksRoutes,
                              labels: TabConstants.remarksTitles,
                              onTabChange: viewModel.changeTab,
                              showAsteriskTabs: viewModel.showAsteriskTabs,
                              conditionalRoutes: TabConstants.getRemarksRoutes(
                                viewModel.selectedCustomer!,
                              ),
                              customer: viewModel.selectedCustomer,
                              // add these two lines
                              showViewMore: viewModel.showViewMore,
                              collapsedKeys: TabConstants.fiCollapsedTabs,
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
    CommonTabsState state,
    CommonTabsViewModel viewModel,
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
        return _buildView(viewModel, state.activeTab, context, state);
    }
  }

  Widget _buildView(
    CommonTabsViewModel viewModel,
    RemarksTabs tab,
    BuildContext context,
    CommonTabsState state,
  ) {
    return Form(
      key: ValueKey("form-${tab.name}"),
      child: Column(
        children: [
          Column(
            children: [
              LabelWidget(
                label: TabConstants.remarksTitles[tab]!.tr(),
                infoContent: TabConstants.remarksTooltipContent[tab]?.tr(),
                isRequired: viewModel.shouldValidateField,
                isRichMessage: true,
                child: UnifiedTextEditor(
                  key: ValueKey("editor-${tab.name}"),
                  editorId: "rich-text-editor-${tab.name}",
                  scrollController: viewModel.scrollController,
                  showVideoUpload: false,
                  semanticLabel: TabConstants.remarksTitles[tab]!.tr(),
                  controller: viewModel.rteController,
                  initialText: viewModel.commentData?.strategyComment,
                  disable: viewModel.isReadOnlyMode,
                ),
              ),
            ],
          ),
          const Gap(),
          ActionWidget(state: state, viewModel: viewModel),
        ],
      ),
    );
  }
}
