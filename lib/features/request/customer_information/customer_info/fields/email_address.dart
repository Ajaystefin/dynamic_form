import "package:easy_localization/easy_localization.dart";
import "package:flutter/material.dart";
import "package:wcas_frontend/core/components/label.dart";
import "package:wcas_frontend/core/components/textfield.dart";
import "package:wcas_frontend/core/utils/validators.dart";
import "package:wcas_frontend/features/request/customer_information/customer_info/model.dart";

class EmailAddress extends StatelessWidget {
  const EmailAddress({required this.viewModel, super.key});
  final CustomerInfoViewModel viewModel;
  @override
  Widget build(BuildContext context) {
    final String initialValue =
        viewModel.customerInformation?.emailAddress ?? "";
    final bool isValid = !viewModel.canEdit && initialValue.trim().isNotEmpty;

    return Row(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: LabelWidget(
            isRequired: (viewModel.isFI) ? false : true,
            showLabel: true,
            label: "customerInformation.customerInformation.emailAddress".tr(),
            child: CustomTextField(
              key: const ValueKey("emailAddress"),
              maxLength: 100,
              semanticLabel:
                  "customerInformation.customerInformation.emailAddress".tr(),
              initialValue: initialValue,
              filled: isValid,
              readOnly: isValid,
              validator: (viewModel.isFI) ? null : CustomValidator.email,
              onSaved: (value) {
                viewModel.customerInformation?.emailAddress = value;
              },
            ),
          ),
        ),
      ],
    );
  }
}
