import "package:easy_localization/easy_localization.dart";
import "package:flutter/material.dart";
import "package:wcas_frontend/core/components/button.dart";
import "package:wcas_frontend/core/components/gap.dart";
import "package:wcas_frontend/core/components/selectable_text.dart";
import "package:wcas_frontend/core/components/textfield.dart";
import "package:wcas_frontend/core/constants/constants.dart";
import "package:wcas_frontend/features/request/remarks/financial_ratio_analysis/model.dart";
import "package:wcas_frontend/features/request/remarks/financial_ratio_analysis/state.dart";

/// Provides entity search functionality for Financial Ratio Analysis.
class EntitySearchSection extends StatelessWidget {
  /// Creates an entity search section.
  const EntitySearchSection({
    required this.viewModel,
    required this.state,
    super.key,
  });

  /// Financial Ratio Analysis view model.
  final FinancialRatioAnalysisViewModel viewModel;

  /// Current Financial Ratio Analysis state.
  final FinancialRatioAnalysisState state;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        CustomSelectableText(
          text: "remarks.financialRatiosAnalysis.searchEntityId".tr(),
          semanticsLabel: "remarks.financialRatiosAnalysis.searchEntityId".tr(),
          style: AppStyle.tableHeaderStyle,
        ),
        const Gap(size: GapSize.small),
        Row(
          children: [
            CustomTextField(
              readOnly: viewModel.isFI || viewModel.isReadOnlyMode,
              filled: viewModel.isFI || viewModel.isReadOnlyMode,
              width: AppStyle.groupBorrowersTextField,
              semanticLabel: state.currentEntityId.toString(),
              controller: viewModel.entityController,
              onChanged: viewModel.updateEntityId,
            ),
            const Gap(direction: Axis.horizontal),
            CustomButton(
              label: "remarks.financialRatiosAnalysis.search".tr(),
              semanticLabel: "remarks.financialRatiosAnalysis.search".tr(),
              onPressed: viewModel.isReadOnlyMode
                  ? null
                  : viewModel.isFI
                      ? null
                      : () async {
                          await viewModel.searchEntity();
                        },
            ),
          ],
        ),
      ],
    );
  }
}
