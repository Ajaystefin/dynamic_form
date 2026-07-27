import "package:easy_localization/easy_localization.dart";
import "package:flutter/material.dart";
import "package:wcas_frontend/core/components/label.dart";
import "package:wcas_frontend/core/components/textarea.dart";
import "package:wcas_frontend/core/constants/constants.dart";
import "package:wcas_frontend/features/request/customer_information/customer_info/model.dart";

/// Reason for deferral waiver field for the customer information screen.
class ReasonForDeferralWaiver extends StatelessWidget {
  /// Creates a reason for deferral waiver field.
  const ReasonForDeferralWaiver({required this.viewModel, super.key});

  /// Customer information view model.
  final CustomerInfoViewModel viewModel;

  @override
  Widget build(BuildContext context) {
    return LabelWidget(
      label: "customerInformation.customerInformation.reasonForDeferralWaiver"
          .tr(),
      child: CustomTextArea(
        key: const ValueKey("reasonForDeferralWaiver"),
        semanticLabel:
            "customerInformation.customerInformation.reasonForDeferralWaiver"
                .tr(),
        hintText: "customerInformation.customerInformation."
                "provideReasonForDeferralWaiver"
            .tr(),
        hintStyle: const TextStyle(color: AppColors.textFieldBorder),
        maxLength: 1000,
        readOnly: !viewModel.canEdit,
        filled: !viewModel.canEdit,
        initialValue: viewModel.customerInformation?.reasonForWaiver,
        //validator: CustomValidator.requiredField,
        onSaved: (String? value) {
          viewModel.customerInformation?.reasonForWaiver = value;
        },
      ),
    );
  }
}
