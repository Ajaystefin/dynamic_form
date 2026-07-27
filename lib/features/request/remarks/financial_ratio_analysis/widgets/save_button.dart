import "package:easy_localization/easy_localization.dart";
import "package:flutter/material.dart";
import "package:wcas_frontend/core/components/button.dart";
import "package:wcas_frontend/core/components/gap.dart";
import "package:wcas_frontend/features/request/remarks/financial_ratio_analysis/model.dart";

/// Displays save actions for the Financial Ratio Analysis section.
class SaveButton extends StatelessWidget {
  /// Creates a save button widget.
  const SaveButton({
    required this.viewModel,
    super.key,
  });

  /// Financial Ratio Analysis view model.
  final FinancialRatioAnalysisViewModel viewModel;

  @override
  Widget build(BuildContext context) {
    if (viewModel.isReadOnlyMode) {
      return Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          CustomButton(
            label: "common.continue".tr(),
            semanticLabel: "common.continue".tr(),
            onPressed: viewModel.navigate,
          ),
        ],
      );
    }
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        CustomButton(
          label: "remarks.financialRatiosAnalysis.save".tr(),
          semanticLabel: "remarks.financialRatiosAnalysis.save".tr(),
          onPressed: () async {
            await viewModel.onSavePress(isContinue: false, context);
          },
        ),
        const Gap(direction: Axis.horizontal),
        CustomButton(
          label: "remarks.financialRatiosAnalysis.saveAndContinue".tr(),
          semanticLabel: "remarks.financialRatiosAnalysis.saveAndContinue".tr(),
          onPressed: () async {
            await viewModel.onSavePress(isContinue: true, context);
          },
        ),
      ],
    );
  }
}
