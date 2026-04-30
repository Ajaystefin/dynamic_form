import "package:easy_localization/easy_localization.dart";
import "package:flutter/material.dart";
import "package:wcas_frontend/core/components/button.dart";
import "package:wcas_frontend/core/components/gap.dart";
import "package:wcas_frontend/features/request/remarks/guarantor_financials/model.dart";

class SaveButton extends StatelessWidget {
  const SaveButton({required this.viewModel, super.key});
  final GuarantorFinancialViewModel viewModel;

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
          label: "remarks.guarantorFinancials.save".tr(),
          semanticLabel: "remarks.guarantorFinancials.save".tr(),
          onPressed: () async {
            await viewModel.onSavePress(false, context);
          },
        ),
        const Gap(direction: Axis.horizontal),
        CustomButton(
          label: "remarks.guarantorFinancials.saveAndContinue".tr(),
          semanticLabel: "remarks.guarantorFinancials.saveAndContinue".tr(),
          onPressed: () async {
            await viewModel.onSavePress(true, context);
          },
        ),
      ],
    );
  }
}
