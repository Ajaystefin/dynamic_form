import "package:easy_localization/easy_localization.dart";
import "package:flutter/material.dart";
import "package:wcas_frontend/core/components/label.dart";
import "package:wcas_frontend/core/components/textfield.dart";
import "package:wcas_frontend/core/constants/constants.dart";
import "package:wcas_frontend/features/request/projects/link_contract/model.dart";

/// Converted contract amount field.
///
/// This field is displayed only when the selected currency is not AED.
class ConvertedContractAmount extends StatelessWidget {
  /// Creates a converted contract amount field.
  const ConvertedContractAmount({required this.viewModel, super.key});

  /// Link contract view model.
  final LinkContractViewModel viewModel;

  @override
  Widget build(BuildContext context) {
    // Only show if selected currency is not AED
    if (viewModel.selectedCurrencyLabel == "AED") {
      return const SizedBox.shrink(); // hides the widget
    }

    return LabelWidget(
      label: "project.linkContract.convertedAmount".tr(),
      child: CustomTextField(
        semanticLabel: "project.linkContract.convertedAmount".tr(),
        readOnly: true,
        filled: true,
        fillColor: AppColors.tableActivatedColor,
        controller: viewModel.convertedAmountController,
      ),
    );
  }
}
