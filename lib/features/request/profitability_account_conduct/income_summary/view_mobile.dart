import "package:easy_localization/easy_localization.dart";
import "package:flutter/material.dart";
import "package:flutter_bloc/flutter_bloc.dart";

import "package:wcas_frontend/core/components/box_layout.dart";
import "package:wcas_frontend/core/components/button.dart";
import "package:wcas_frontend/core/components/custom_table/table.dart";
import "package:wcas_frontend/core/components/gap.dart";
import "package:wcas_frontend/core/components/label.dart";
import "package:wcas_frontend/core/components/section_header.dart";
import "package:wcas_frontend/core/components/selectable_text.dart";
import "package:wcas_frontend/core/components/tab_menu.dart";
import "package:wcas_frontend/core/components/textarea.dart";
import "package:wcas_frontend/core/components/top_section/top_section_details.dart";
import "package:wcas_frontend/core/constants/constants.dart";
import "package:wcas_frontend/core/globals.dart";
// import 'package:wcas_frontend/core/utils/text_utils.dart';
import "package:wcas_frontend/core/utils/utils.dart";
import "package:wcas_frontend/features/layout/view.dart";
import "package:wcas_frontend/features/request/profitability_account_conduct/income_summary/model.dart";
import "package:wcas_frontend/features/request/profitability_account_conduct/income_summary/state.dart";

class ViewMobile extends StatelessWidget {
  const ViewMobile({super.key});

  @override
  Widget build(BuildContext context) {
    final IncomeSummaryViewModel viewModel =
        context.read<IncomeSummaryViewModel>();
    return BlocBuilder<IncomeSummaryViewModel, IncomeSummaryState>(
      builder: (context, state) {
        return Layout(
          child: SingleChildScrollView(
            scrollDirection: Axis.vertical,
            child: BoxLayout(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  CustomSectionHeader(
                    title: "profitabilityAccountConduct."
                            "relationshipProfitabilitySummary.sectionTitle"
                        .tr(),
                  ),
                  const Gap(),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      BoxLayout(
                        child: TopSectionDetails(request: Globals.request!),
                      ),
                      BoxLayout(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const TabMenu(
                              activeKey: RevenueCrossSellTabs.incomeSummary,
                              routes: TabConstants.revenueCrossSellRoutes,
                              labels: TabConstants.revenueCrossSellTitles,
                            ),
                            BoxLayout(
                              disabled: !viewModel.canEdit,
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
    IncomeSummaryState state,
    IncomeSummaryViewModel viewModel,
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
        return buildView(context, state, viewModel);
    }
  }

  Widget buildView(
    BuildContext context,
    IncomeSummaryState state,
    IncomeSummaryViewModel viewModel,
  ) {
    return SingleChildScrollView(
      child: Form(
        key: viewModel.formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Gap(),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                CustomSelectableText(
                  semanticsLabel:
                      "profitabilityAccountConduct.shareOfWallet.aed".tr(),
                  text: "profitabilityAccountConduct.shareOfWallet.aed".tr(),
                  textAlign: TextAlign.right,
                  style: AppStyle.tableSuffixHeaderStyle,
                ),
              ],
            ),
            const Gap(),
            CustomRawTable(
              rowHeight: 46,
              showPagination: true,
              columns: [
                TableColumn(
                  label: Text(
                    "profitabilityAccountConduct.incomeSummary.customerRim"
                        .tr(),
                  ),
                ),
                TableColumn(
                  label: Text(
                    "profitabilityAccountConduct.incomeSummary.customerName"
                        .tr(),
                  ),
                ),
                TableColumn(
                  label: Text(
                    "profitabilityAccountConduct.incomeSummary.lastMonths".tr(),
                  ),
                ),
                TableColumn(
                  label: Text(
                    "profitabilityAccountConduct.incomeSummary.nextMonths".tr(),
                  ),
                ),
                TableColumn(
                  label: Text(
                    "profitabilityAccountConduct.incomeSummary.next24Months"
                        .tr(),
                  ),
                ),
              ],
              rows: viewModel.incomeSummaryList!
                  .map(
                    (income) => [
                      Center(
                        child: Text(
                          "${income.rimNo}",
                          style: const TextStyle(color: AppColors.primary),
                        ),
                      ),
                      Center(
                        child: Text(
                          income.custName ?? "",
                          style: const TextStyle(color: AppColors.primary),
                        ),
                      ),
                      Center(
                        child: Text(
                          income.lastYearAmount!,
                          style: const TextStyle(color: AppColors.primary),
                        ),
                      ),
                      Center(
                        child: Text(
                          income.nextYearAmount!,
                          style: const TextStyle(color: AppColors.primary),
                        ),
                      ),
                      Center(
                        child: Text(
                          income.nextYear2Amount!,
                          style: const TextStyle(color: AppColors.primary),
                        ),
                      ),
                    ],
                  )
                  .toList(),
              sortable: true,
            ),
            const Gap(size: GapSize.large),
            LabelWidget(
              label:
                  "profitabilityAccountConduct.incomeSummary.rmComments".tr(),
              labelStyle: const TextStyle(fontWeight: FontWeight.bold),
              child: CustomTextArea(
                semanticLabel:
                    "profitabilityAccountConduct.incomeSummary.rmComments".tr(),
                width: double.infinity,
                autoFocus: false,
                maxLength: 5000,
                initialValue: viewModel.rmComments,
                onSaved: (String? value) {
                  viewModel.rmComments = value?.trim() ?? "";
                },
              ),
            ),
            const Gap(size: GapSize.medium),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                CustomButton(
                  semanticLabel:
                      "profitabilityAccountConduct.incomeSummary.save".tr(),
                  label: "profitabilityAccountConduct.incomeSummary.save".tr(),
                  onPressed: (viewModel.canEdit)
                      ? () async {
                          await viewModel.saveIncomeSummaryData(context, false);
                        }
                      : null,
                ),
                const Gap(direction: Axis.horizontal),
                CustomButton(
                  semanticLabel: "profitabilityAccountConduct."
                          "incomeSummary.saveAndContinue"
                      .tr(),
                  label: "profitabilityAccountConduct."
                          "incomeSummary.saveAndContinue"
                      .tr(),
                  onPressed: (viewModel.canEdit)
                      ? () async {
                          await viewModel.saveIncomeSummaryData(context, true);
                        }
                      : null,
                ),
              ],
            ),
            const Gap(size: GapSize.medium),
          ],
        ),
      ),
    );
  }
}
