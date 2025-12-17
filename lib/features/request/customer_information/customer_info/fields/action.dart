import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:wcas_frontend/core/components/button.dart';
import 'package:wcas_frontend/core/components/gap.dart';
import 'package:wcas_frontend/features/request/customer_information/customer_info/model.dart';

class ActionButton extends StatelessWidget {
  final CustomerInfoViewModel viewModel;
  const ActionButton({super.key, required this.viewModel});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        CustomButton(
            label: "customerInformation.customerInformation.save".tr(),
            semanticLabel: "customerInformation.customerInformation.save".tr(),
            onPressed: () async {
              await viewModel.onSave();
            }),
        const Gap(direction: Axis.horizontal),
        CustomButton(
            semanticLabel:
                "customerInformation.customerInformation.saveAndContinue",
            label: "customerInformation.customerInformation.saveAndContinue"
                .tr(), // "Save & Continue",
            onPressed: () async {
              await viewModel.onSave(ifNavigate: true);
            }),
      ],
    );
  }
}
