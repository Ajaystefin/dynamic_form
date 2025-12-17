import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:wcas_frontend/core/components/button.dart';
import 'package:wcas_frontend/core/components/gap.dart';
import 'package:wcas_frontend/features/request/remarks/guarantor_financials/model.dart';

class SaveButton extends StatelessWidget {
  final GuarantorFinancialViewModel viewModel;
  const SaveButton({super.key, required this.viewModel});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        CustomButton(
          label: "remarks.guarantorFinancials.save".tr(),
          semanticLabel: "remarks.guarantorFinancials.save".tr(),
          onPressed: () {
            viewModel.onSavePress(false, context);
          },
        ),
        const Gap(direction: Axis.horizontal),
        CustomButton(
          label: "remarks.guarantorFinancials.saveAndContinue".tr(),
          semanticLabel: "remarks.guarantorFinancials.saveAndContinue".tr(),
          onPressed: () {
            viewModel.onSavePress(true, context);
          },
        ),
      ],
    );
  }
}
