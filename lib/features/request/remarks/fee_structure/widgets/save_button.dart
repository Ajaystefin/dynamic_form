import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:wcas_frontend/core/components/button.dart';
import 'package:wcas_frontend/core/components/gap.dart';
import 'package:wcas_frontend/features/request/remarks/fee_structure/model.dart';

class SaveButton extends StatelessWidget {
  final FeeStructureViewModel viewModel;
  const SaveButton({super.key, required this.viewModel});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        CustomButton(
          label: 'remarks.feeStructure.save'.tr(),
          semanticLabel: 'remarks.feeStructure.save'.tr(),
          onPressed: () async {
            final form = viewModel.formKey.currentState!;
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
            final form = viewModel.formKey.currentState!;
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
