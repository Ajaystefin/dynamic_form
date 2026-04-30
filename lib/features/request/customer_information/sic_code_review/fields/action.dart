import "package:easy_localization/easy_localization.dart";
import "package:flutter/material.dart";
import "package:wcas_frontend/core/components/button.dart";
import "package:wcas_frontend/core/components/gap.dart";
import "package:wcas_frontend/features/request/customer_information/sic_code_review/model.dart";

class ActionButton extends StatelessWidget {
  const ActionButton({required this.viewModel, super.key});
  final SicCodeReviewViewModel viewModel;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        CustomButton(
          label: "customerInformation.sicCodeReview.save".tr(),
          onPressed: (viewModel.canEdit)
              ? () async {
                  await viewModel.onSaveSic();
                }
              : null,
        ),
        const Gap(direction: Axis.horizontal),
        CustomButton(
          label: "customerInformation.sicCodeReview.saveAndContinue"
              .tr(), // "Save & Continue",
          onPressed: (viewModel.canEdit)
              ? () async {
                  await viewModel.onSaveSic(ifNavigate: true);
                }
              : null,
        ),
      ],
    );
  }
}
