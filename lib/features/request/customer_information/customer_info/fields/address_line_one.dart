import "package:easy_localization/easy_localization.dart";
import "package:flutter/material.dart";
import "package:wcas_frontend/core/components/label.dart";
import "package:wcas_frontend/core/components/textfield.dart";
import "package:wcas_frontend/core/utils/validators.dart";
import "package:wcas_frontend/features/request/customer_information/customer_info/model.dart";

class AddressLineOne extends StatelessWidget {
  const AddressLineOne({required this.viewModel, super.key});
  final CustomerInfoViewModel viewModel;
  @override
  Widget build(BuildContext context) {
    final String initialValue =
        viewModel.customerInformation?.addressLine1 ?? "";
    final bool isValid = !viewModel.canEdit;
    return Row(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: LabelWidget(
            isRequired: (viewModel.isFI) ? false : true,
            showLabel: true,
            label: "customerInformation.customerInformation.addressLine1".tr(),
            child: CustomTextField(
              key: const ValueKey("addressLine1"),

// controller: viewModel.controller(
//           CustomerInfoFields.addressLine1,
//         ),
              semanticLabel:
                  "customerInformation.customerInformation.addressLine1".tr(),
              filled: isValid,
              readOnly: isValid,
              maxLength: 500,
              inputFormatters: [viewModel.freeTextFormatter],
              initialValue: initialValue,
              validator:
                  (viewModel.isFI) ? null : CustomValidator.requiredField,
              onSaved: (value) {
                viewModel.customerInformation?.addressLine1 = value;
              },
            ),
          ),
        ),
      ],
    );
  }
}
