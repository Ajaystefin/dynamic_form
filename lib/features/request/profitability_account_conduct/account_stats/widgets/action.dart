import "package:easy_localization/easy_localization.dart";
import "package:flutter/widgets.dart";
import "package:wcas_frontend/core/components/button.dart";
import "package:wcas_frontend/core/components/gap.dart";
import "package:wcas_frontend/core/utils/utils.dart";
import "package:wcas_frontend/features/request/profitability_account_conduct/account_stats/model.dart";
import "package:wcas_frontend/features/request/profitability_account_conduct/account_stats/state.dart";

/// Action widget for account stats save actions.
class ActionWidget extends StatelessWidget {
  /// Creates an action widget.
  const ActionWidget({
    required this.viewModel,
    required this.state,
    super.key,
  });

  /// Account stats state.
  final AccountStatsState state;

  /// Account stats view model.
  final AccountStatsViewModel viewModel;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        CustomButton(
          semanticLabel: "profitabilityAccountConduct.accountStats.save".tr(),
          label: "profitabilityAccountConduct.accountStats.save".tr(),
          onPressed: (viewModel.canEdit) ? viewModel.saveComments : null,
          isLoading: state.saveButtonLoading == LoadingStatus.loading,
        ),
        const Gap(
          direction: Axis.horizontal,
        ),
        CustomButton(
          isLoading: state.continueButtonLoading == LoadingStatus.loading,
          semanticLabel:
              "profitabilityAccountConduct.accountStats.saveAndContinue".tr(),
          label:
              "profitabilityAccountConduct.accountStats.saveAndContinue".tr(),
          onPressed: (viewModel.canEdit)
              ? () {
                  viewModel.saveComments(isContinue: true);
                }
              : null,
        ),
      ],
    );
  }
}
