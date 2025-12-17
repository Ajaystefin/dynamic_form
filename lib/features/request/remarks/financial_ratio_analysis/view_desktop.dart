import 'package:easy_localization/easy_localization.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:wcas_frontend/core/components/box_layout.dart';
import 'package:wcas_frontend/core/components/customer_dropdown.dart';
import 'package:wcas_frontend/core/components/gap.dart';
import 'package:wcas_frontend/core/components/label.dart';
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
import 'package:wcas_frontend/features/request/remarks/financial_ratio_analysis/widgets/balance_sheet_analysis.dart';
import 'package:wcas_frontend/features/request/remarks/financial_ratio_analysis/widgets/cashflow_statement_analysis.dart';
import 'package:wcas_frontend/features/request/remarks/financial_ratio_analysis/widgets/entity_search_section.dart';
import 'package:wcas_frontend/features/request/remarks/financial_ratio_analysis/widgets/income_statement_analysis.dart';
import 'package:wcas_frontend/features/request/remarks/financial_ratio_analysis/widgets/save_button.dart';

import 'model.dart';
import 'state.dart';

class ViewDesktop extends StatelessWidget {
  const ViewDesktop({super.key});

  @override
  Widget build(BuildContext context) {
    FinancialRatioAnalysisViewModel viewModel =
        context.read<FinancialRatioAnalysisViewModel>();
    return BlocBuilder<FinancialRatioAnalysisViewModel,
        FinancialRatioAnalysisState>(builder: (context, state) {
      return Layout(
        child: _body(context, state, viewModel),
      );
    });
  }

  Widget _body(BuildContext context, FinancialRatioAnalysisState state,
      FinancialRatioAnalysisViewModel viewModel) {
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
        return buildView(
          context,
          state,
          viewModel,
        );
    }
  }

  Widget buildView(BuildContext context, FinancialRatioAnalysisState state,
      FinancialRatioAnalysisViewModel viewModel) {
    return SingleChildScrollView(
      child: BoxLayout(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
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
                    onRefresh: () {
                      viewModel.onChangeCustomer(viewModel.selectedCustomer!);
                    },
                  ),
                  const Gap(),
                  CustomSelectableText(
                    text:
                        "${"remarks.selectCustomerLabel".tr()}: ${viewModel.selectedCustomer?.customerName}",
                    semanticsLabel:
                        "${"remarks.selectCustomerLabel".tr()}: ${viewModel.selectedCustomer?.customerName}",
                    style: AppStyle.boldLabel,
                  ),
                  const Gap(),
                  TabMenu(
                    activeKey: state.activeTab,
                    routes: TabConstants.remarksRoutes,
                    labels: TabConstants.remarksTitles,
                    showAsteriskTabs: viewModel.showAsteriskTabs,
                    conditionalRoutes: TabConstants.getRemarksRoutes(
                        viewModel.selectedCustomer!),
                    onTabChange: viewModel.changeTab,
                  ),
                  BoxLayout(
                    child: SingleChildScrollView(
                        child: _tabView(context, viewModel, state)),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _tabView(
      BuildContext context,
      FinancialRatioAnalysisViewModel viewModel,
      FinancialRatioAnalysisState state) {
    return Form(
      key: viewModel.formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Gap(),
          LabelWidget(
            label: 'remarks.financialRatiosAnalysis.descriptionAccounts'.tr(),
            isRequired: true,
            labelStyle: AppStyle.tableHeaderStyle,
            child: SizedBox(
              height: AppStyle.customTextEditorWidget,
              child: CustomTextEditorWidget(
                semanticLabel:
                    'remarks.financialRatiosAnalysis.descriptionAccounts'.tr(),
                controller: viewModel.descTextController,
                characterLimit: 5000,
              ),
            ),
          ),
          const Gap(size: GapSize.medium),
          EntitySearchSection(viewModel: viewModel, state: state),
          const Gap(size: GapSize.medium),
          if (viewModel.hasCreditLensData) ...[
            IncomeStatementAnalysis(viewModel: viewModel),
            const Gap(size: GapSize.medium),
            CashflowStatementAnalysis(viewModel: viewModel),
            const Gap(size: GapSize.medium),
            BalanceSheetAnalysis(viewModel: viewModel),
            const Gap(size: GapSize.medium),
          ],
          const Gap(size: GapSize.medium),
          SaveButton(viewModel: viewModel),
          const Gap(size: GapSize.medium),
        ],
      ),
    );
  }
}
