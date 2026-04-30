import "package:easy_localization/easy_localization.dart";
import "package:flutter/material.dart";
import "package:wcas_frontend/core/components/button.dart";
import "package:wcas_frontend/core/components/gap.dart";
import "package:wcas_frontend/core/components/selectable_text.dart";
import "package:wcas_frontend/core/components/textfield.dart";
import "package:wcas_frontend/core/constants/constants.dart";
import "package:wcas_frontend/features/request/remarks/financial_ratio_analysis/model.dart";
import "package:wcas_frontend/features/request/remarks/financial_ratio_analysis/state.dart";

class EntitySearchSection extends StatelessWidget {
  const EntitySearchSection({
    required this.viewModel,
    required this.state,
    super.key,
  });
  final FinancialRatioAnalysisViewModel viewModel;
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
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            CustomTextField(
              readOnly: viewModel.isFI ? true : viewModel.isReadOnlyMode,
              filled: viewModel.isFI ? true : viewModel.isReadOnlyMode,
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
