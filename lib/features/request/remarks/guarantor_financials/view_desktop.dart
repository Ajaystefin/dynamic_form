import "package:easy_localization/easy_localization.dart";
import "package:flutter/material.dart";
import "package:flutter_bloc/flutter_bloc.dart";

import "package:wcas_frontend/core/components/box_layout.dart";
import "package:wcas_frontend/core/components/customer_dropdown.dart";
import "package:wcas_frontend/core/components/gap.dart";
import "package:wcas_frontend/core/components/section_header.dart";
import "package:wcas_frontend/core/components/selectable_text.dart";
import "package:wcas_frontend/core/components/tab_menu.dart";
import "package:wcas_frontend/core/components/top_section/top_section_details.dart";
import "package:wcas_frontend/core/constants/constants.dart";
import "package:wcas_frontend/core/globals.dart";
import "package:wcas_frontend/core/utils/utils.dart";
import "package:wcas_frontend/features/layout/view.dart";
import "package:wcas_frontend/features/request/remarks/guarantor_financials/model.dart";
import "package:wcas_frontend/features/request/remarks/guarantor_financials/state.dart";
import "package:wcas_frontend/features/request/remarks/guarantor_financials/widgets/add_guarantor_section.dart";
import "package:wcas_frontend/features/request/remarks/guarantor_financials/widgets/entity_search_section.dart";
import "package:wcas_frontend/features/request/remarks/guarantor_financials/widgets/guarantor_text_area.dart";
import "package:wcas_frontend/features/request/remarks/guarantor_financials/widgets/income_statement_analysis.dart";
import "package:wcas_frontend/features/request/remarks/guarantor_financials/widgets/save_button.dart";

class ViewDesktop extends StatelessWidget {
  ViewDesktop({super.key});

  final FocusNode entityFocus = FocusNode();
  final FocusNode extraEntityFocus = FocusNode();

  @override
  Widget build(BuildContext context) {
    final GuarantorFinancialViewModel viewModel =
        context.read<GuarantorFinancialViewModel>();
    return BlocBuilder<GuarantorFinancialViewModel, GuarantorFinancialState>(
      builder: (context, state) {
        return Layout(
          child: buildView(context, state, viewModel),
        );
      },
    );
  }

  Widget buildView(
    BuildContext context,
    GuarantorFinancialState state,
    GuarantorFinancialViewModel viewModel,
  ) {
    return SingleChildScrollView(
      controller: viewModel.scrollController,
      child: BoxLayout(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 1) Section header
            CustomSectionHeader(title: "remarks.feeStructure.title".tr()),
            const Gap(),
            BoxLayout(
              child: TopSectionDetails(request: Globals.request!),
            ),
            BoxLayout(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  CustomCustomerDropdown(
                    onCustomerChange: viewModel.onChangeCustomer,
                    selectedCustomer: viewModel.selectedCustomer,
                    customerList: viewModel.customerList,
                    onRefresh: () {
                      if (viewModel.selectedCustomer != null) {
                        viewModel.onChangeCustomer(viewModel.selectedCustomer!);
                      }
                    },
                  ),
                  const Gap(),
                  CustomSelectableText(
                    text: "${"remarks.selectCustomerLabel".tr()}: "
                        "${viewModel.selectedCustomer?.displayName}",
                    semanticsLabel: "${"remarks.selectCustomerLabel".tr()}: "
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
                  _body(context, state, viewModel),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _body(
    BuildContext context,
    GuarantorFinancialState state,
    GuarantorFinancialViewModel viewModel,
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
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            for (int i = 0; i < state.guarantors.length; i++)
              BoxLayout(
                child: _tabView(
                  context,
                  viewModel,
                  state.guarantors[i].canDelete,
                  entityId: (i == 0
                      ? (state.currentEntityId ?? 0)
                      : (state.guarantors[i].entityId ?? 0)),
                  isFirstSection: i == 0,
                  formKey: i == 0
                      ? viewModel.primaryFormKey
                      : GlobalKey<FormState>(),
                ),
              ),
            const Gap(size: GapSize.medium),
            AddGuarantorSection(viewModel: viewModel),
            const Gap(size: GapSize.medium),
            SaveButton(viewModel: viewModel),
            const Gap(size: GapSize.medium),
          ],
        );
    }
  }

  Widget _tabView(
    BuildContext context,
    GuarantorFinancialViewModel viewModel,
    bool showDeleteButton, {
    required int entityId,
    required bool isFirstSection,
    required GlobalKey<FormState> formKey,
  }) {
    final state = context.watch<GuarantorFinancialViewModel>().state;

    return Form(
      key: formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Gap(),
          EntitySearchSection(
            viewModel: viewModel,
            entityFocus: entityFocus,
            state: state,
            showDeleteButton: showDeleteButton,
            entityId: entityId,
            isFirstSection: isFirstSection,
          ),
          const Gap(size: GapSize.large),
          GuarantorTextArea(viewModel: viewModel, entityId: entityId),
          if (isFirstSection) ...[
            if (state.firstSectionTablesVisible) ...[
              const Gap(size: GapSize.medium),
              IncomeStatementAnalysis(
                viewModel: viewModel,
                entityId: entityId,
              ),
            ],
          ] else ...[
            const Gap(size: GapSize.medium),
            IncomeStatementAnalysis(viewModel: viewModel, entityId: entityId),
          ],
        ],
      ),
    );
  }
}
