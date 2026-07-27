import "package:flutter/material.dart";
import "package:wcas_frontend/core/components/label.dart";
import "package:wcas_frontend/core/components/radiobutton.dart";
import "package:wcas_frontend/core/utils/validators.dart";
import "package:wcas_frontend/features/request/facilities_securities/others_limit_dialog/model.dart";

/// Widget for displaying and selecting the nature of fund.
class NatureOfFund extends StatelessWidget {
  /// Creates a nature of fund widget.
  const NatureOfFund({
    required this.viewModel,
    super.key,
  });

  /// View model containing others limit dialog data and actions.
  final OthersLimitDialogViewModel viewModel;

  @override
  Widget build(BuildContext context) {
    return LabelWidget(
      // Use your localization key if you have one. Fallback keeps UX clear.
      label: "Nature Of Fund", // "Nature of fund"
      isRequired: true,
      child: Align(
        alignment: Alignment.centerLeft,
        child: CustomRadioButton<Naturefund>(
          options: Naturefund.values,
          // Default to Funded if nothing selected yet
          selectedValue: viewModel.selectedNatureFund ?? Naturefund.funded,
          onChanged: (selected) {
            viewModel.changeNatureOfFund(selected);
          },
          // Render "Funded" / "Non-Funded"
          itemBuilder: (context, item, {bool? isSelected, bool? isEnabled}) =>
              Text(viewModel.natureOfFundLabel(item)),
          // Mandatory validation (uses the selected value held by the VM)
          validator: (_) => CustomValidator.requiredField(
            (viewModel.selectedNatureFund != null)
                ? viewModel.natureOfFundLabel(viewModel.selectedNatureFund!)
                : "",
          ),
          isRequired: true,
          scrollDirection: Axis.horizontal,
          textStyle: const TextStyle(fontSize: 12),
        ),
      ),
    );
  }
}
