import 'package:easy_localization/easy_localization.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:wcas_frontend/core/components/button.dart';
import 'package:wcas_frontend/core/components/gap.dart';
import 'package:wcas_frontend/core/utils/utils.dart';
import 'package:wcas_frontend/features/layout/view.dart';
import 'package:wcas_frontend/core/components/box_layout.dart';
import 'package:wcas_frontend/core/components/section_header.dart';
import 'package:wcas_frontend/core/components/tab_menu.dart';
import 'package:wcas_frontend/core/components/top_section/top_section_details.dart';
import 'package:wcas_frontend/core/constants/constants.dart';
import 'package:wcas_frontend/core/globals.dart';
import 'package:flutter/material.dart';
import 'package:wcas_frontend/features/request/profitability_account_conduct/strategies_and_comments/fields/strategy_text_field.dart';
import 'model.dart';
import 'state.dart';

class ViewMobile extends StatelessWidget {
  const ViewMobile({super.key});
  @override
  Widget build(BuildContext context) {
    final StrategiesAndCommentsViewModel viewModel =
        context.read<StrategiesAndCommentsViewModel>();

    return BlocBuilder<StrategiesAndCommentsViewModel,
        StrategiesAndCommentsState>(
      builder: (context, state) {
        return Layout(
          child: SingleChildScrollView(
            scrollDirection: Axis.vertical,
            child: BoxLayout(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  CustomSectionHeader(
                    title:
                        "profitabilityAccountConduct.relationshipProfitabilitySummary.sectionTitle"
                            .tr(),
                  ),
                  const Gap(),
                  Column(
                    children: [
                      BoxLayout(
                        child: TopSectionDetails(request: Globals.request!),
                      ),
                      BoxLayout(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const TabMenu(
                              activeKey:
                                  RevenueCrossSellTabs.strategiesAndComments,
                              routes: TabConstants.revenueCrossSellRoutes,
                              labels: TabConstants.revenueCrossSellTitles,
                            ),
                            BoxLayout(
                              extraPadding: true,
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

  /// Builds the main body of the view based on the current loading state.
  ///
  /// Displays a loading spinner, an empty/error message, or the form with the
  /// updated strategies and comments.
  Widget _body(BuildContext context, StrategiesAndCommentsState state,
      StrategiesAndCommentsViewModel viewModel) {
    switch (state.loaderStatus) {
      case LoadingStatus.loading:
        return const Center(child: CircularProgressIndicator());
      case LoadingStatus.empty:
        return Center(
          child: Text('common.emptyState'.tr()),
        );
      case LoadingStatus.error:
        return Center(
          child: Text('common.errorState'.tr()),
        );
      default:
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Gap(),
            StrategyTextField(
              label:
                  "profitabilityAccountConduct.strategiesComments.relationshipStrategy"
                      .tr(),
              initialValue: viewModel.strategiesComments!.relationshipStrategy,
              onChanged: (value) => viewModel.strategiesComments = viewModel
                  .strategiesComments
                  ?.copyWith(relationshipStrategy: value),
            ),
            StrategyTextField(
              label:
                  "profitabilityAccountConduct.strategiesComments.depositsStrategy"
                      .tr(),
              initialValue: viewModel.strategiesComments!.depositStrategy,
              onChanged: (value) => viewModel.strategiesComments = viewModel
                  .strategiesComments
                  ?.copyWith(depositStrategy: value),
            ),
            StrategyTextField(
              label:
                  "profitabilityAccountConduct.strategiesComments.transactionBankingComments"
                      .tr(),
              initialValue:
                  viewModel.strategiesComments!.transactionBankingComments,
              onChanged: (value) => viewModel.strategiesComments = viewModel
                  .strategiesComments
                  ?.copyWith(transactionBankingComments: value),
            ),
            StrategyTextField(
              label:
                  "profitabilityAccountConduct.strategiesComments.tradeFinanceComments"
                      .tr(),
              initialValue: viewModel.strategiesComments!.tradeFinanceComments,
              onChanged: (value) => viewModel.strategiesComments = viewModel
                  .strategiesComments
                  ?.copyWith(tradeFinanceComments: value),
            ),
            StrategyTextField(
              label:
                  "profitabilityAccountConduct.strategiesComments.treasuryComments"
                      .tr(),
              initialValue: viewModel.strategiesComments!.treasuryComments,
              onChanged: (value) => viewModel.strategiesComments = viewModel
                  .strategiesComments
                  ?.copyWith(treasuryComments: value),
            ),
            StrategyTextField(
              label:
                  "profitabilityAccountConduct.strategiesComments.ermComments"
                      .tr(),
              initialValue: viewModel.strategiesComments!.treasuryComments,
              onChanged: (value) => viewModel.strategiesComments = viewModel
                  .strategiesComments
                  ?.copyWith(treasuryComments: value),
            ),
            StrategyTextField(
              label:
                  "profitabilityAccountConduct.strategiesComments.esgComments"
                      .tr(),
              initialValue: viewModel.strategiesComments!.treasuryComments,
              onChanged: (value) => viewModel.strategiesComments = viewModel
                  .strategiesComments
                  ?.copyWith(treasuryComments: value),
            ),
            const Gap(size: GapSize.medium),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                CustomButton(
                  label: "profitabilityAccountConduct.strategiesComments.save"
                      .tr(),
                  semanticLabel:
                      "profitabilityAccountConduct.strategiesComments.save"
                          .tr(),
                  onPressed: () async {
                    await viewModel.updateStrategiesComments();
                  },
                ),
                const Gap(direction: Axis.horizontal),
                CustomButton(
                  label:
                      "profitabilityAccountConduct.strategiesComments.saveAndContinue"
                          .tr(),
                  semanticLabel:
                      "profitabilityAccountConduct.strategiesComments.saveAndContinue"
                          .tr(),
                  onPressed: () async {
                    await viewModel.updateStrategiesComments();
                  },
                ),
              ],
            ),
            const Gap(size: GapSize.medium),
          ],
        );
    }
  }
}
