import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:wcas_frontend/core/components/button.dart';
import 'package:wcas_frontend/core/components/gap.dart';
import 'package:wcas_frontend/features/request/customer_information/sic_code_review/model.dart';

class ActionButton extends StatelessWidget {
  final SicCodeReviewViewModel viewModel;
  const ActionButton({super.key, required this.viewModel});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        CustomButton(
            label: "customerInformation.sicCodeReview.save".tr(),
            onPressed: () async {
              await viewModel.onSaveSic();
            }),
        const Gap(direction: Axis.horizontal),
        CustomButton(
            label: "customerInformation.sicCodeReview.saveAndContinue"
                .tr(), // "Save & Continue",
            onPressed: () async {
              await viewModel.onSaveSic(ifNavigate: true);
            }),
      ],
    );
  }
}
