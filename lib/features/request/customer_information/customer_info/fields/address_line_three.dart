import "package:easy_localization/easy_localization.dart";
import "package:flutter/material.dart";
import "package:wcas_frontend/core/components/label.dart";
import "package:wcas_frontend/core/components/textfield.dart";
import "package:wcas_frontend/core/utils/validators.dart";
import "package:wcas_frontend/features/request/customer_information/customer_info/model.dart";

class AddressLineThree extends StatelessWidget {
  const AddressLineThree({required this.viewModel, super.key});
  final CustomerInfoViewModel viewModel;
  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: LabelWidget(
            isRequired: (viewModel.isFI) ? false : true,
            showLabel: true,
            label: "customerInformation.customerInformation.addressLine3".tr(),
            child: CustomTextField(
              key: const ValueKey("addressLine3"), filled: true,

// controller: viewModel.controller(
//           CustomerInfoFields.addressLine3,
//         ),
              readOnly: true,
              hintText: "DUBAI".tr(),
              maxLength: 150,
              // initialValue:
              //     viewModel.customerInformation?.locationAddress ?? "",
              inputFormatters: [viewModel.freeTextFormatter],
              semanticLabel:
                  "customerInformation.customerInformation.addressLine3".tr(),
              validator:
                  (viewModel.isFI) ? null : CustomValidator.requiredField,
              onSaved: (value) {
                viewModel.customerInformation?.addressLine3 =
                    value ?? "DUBAI".tr();
              },
            ),
          ),
        ),
      ],
    );
  }
}
