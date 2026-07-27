import "package:easy_localization/easy_localization.dart";
import "package:flutter/material.dart";
import "package:wcas_frontend/core/components/button.dart";
import "package:wcas_frontend/core/components/gap.dart";
import "package:wcas_frontend/features/request/remarks/fee_structure/model.dart";

/// Displays save and save-and-continue actions for the Fee Structure screen.
class SaveButton extends StatelessWidget {
  /// Creates a save button widget.
  const SaveButton({
    required this.viewModel,
    super.key,
  });

  /// Fee Structure view model.
  final FeeStructureViewModel viewModel;

  @override
  Widget build(BuildContext context) {
    if (viewModel.isReadOnlyMode) {
      return Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          CustomButton(
            label: "common.continue".tr(),
            semanticLabel: "common.continue".tr(),
            onPressed: () async => viewModel.navigateAfterFeeStructure(context),
          ),
        ],
      );
    }
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        CustomButton(
          label: "remarks.feeStructure.save".tr(),
          semanticLabel: "remarks.feeStructure.save".tr(),
          onPressed: () async {
            final FormState form = viewModel.formKey.currentState!;
            if (form.validate()) {
              form.save();
              await viewModel.onSavePress(isContinue: false, context);
            }
          },
        ),
        const Gap(direction: Axis.horizontal),
        CustomButton(
          label: "remarks.financialRatiosAnalysis.saveAndContinue".tr(),
          semanticLabel: "remarks.financialRatiosAnalysis.saveAndContinue".tr(),
          onPressed: () {
            final FormState form = viewModel.formKey.currentState!;
            if (form.validate()) {
              form.save();
              viewModel.onSavePress(isContinue: true, context);
            }
          },
        ),
      ],
    );
  }
}
