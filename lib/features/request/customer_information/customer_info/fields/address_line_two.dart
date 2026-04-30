import "package:easy_localization/easy_localization.dart";
import "package:flutter/material.dart";
import "package:wcas_frontend/core/components/label.dart";
import "package:wcas_frontend/core/components/textfield.dart";
import "package:wcas_frontend/core/utils/validators.dart";
import "package:wcas_frontend/features/request/customer_information/customer_info/model.dart";

class AddressLineTwo extends StatelessWidget {
  const AddressLineTwo({required this.viewModel, super.key});
  final CustomerInfoViewModel viewModel;
  @override
  Widget build(BuildContext context) {
    final String initialValue =
        viewModel.customerInformation?.addressLine2 ?? "";
    final bool isValid =
        !viewModel.canEdit; // && initialValue.trim().isNotEmpty;
    return Row(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: LabelWidget(
            isRequired: (viewModel.isFI) ? false : true,
            showLabel: true,
            label: "customerInformation.customerInformation.addressLine2".tr(),
            child: CustomTextField(
// controller: viewModel.controller(
//           CustomerInfoFields.addressLine2,
//         ),
              key: const ValueKey("addressLine2"),
              semanticLabel:
                  "customerInformation.customerInformation.addressLine2".tr(),
              filled: isValid,
              readOnly: isValid,
              initialValue: initialValue,
              inputFormatters: [viewModel.freeTextFormatter],
              maxLength: 300,
              validator:
                  (viewModel.isFI) ? null : CustomValidator.requiredField,
              onSaved: (value) {
                viewModel.customerInformation?.addressLine2 = value;
              },
            ),
          ),
        ),
      ],
    );
  }
}
