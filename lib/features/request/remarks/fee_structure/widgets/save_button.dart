import "package:easy_localization/easy_localization.dart";
import "package:flutter/material.dart";
import "package:go_router/go_router.dart";
import "package:wcas_frontend/core/components/button.dart";
import "package:wcas_frontend/core/components/gap.dart";
import "package:wcas_frontend/core/constants/constants.dart";
import "package:wcas_frontend/features/request/remarks/fee_structure/model.dart";

class SaveButton extends StatelessWidget {
  const SaveButton({required this.viewModel, super.key});
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
            onPressed: () => context.go(Routes.rmCertification),
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
              await viewModel.onSavePress(false, context);
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
              viewModel.onSavePress(true, context);
            }
          },
        ),
      ],
    );
  }
}
