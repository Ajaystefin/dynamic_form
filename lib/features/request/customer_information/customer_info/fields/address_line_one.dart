import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:wcas_frontend/core/components/label.dart';
import 'package:wcas_frontend/core/components/textfield.dart';
import 'package:wcas_frontend/core/utils/validators.dart';
import 'package:wcas_frontend/features/request/customer_information/customer_info/model.dart';

class AddressLineOne extends StatelessWidget {
  const AddressLineOne({super.key, required this.viewModel});
  final CustomerInfoViewModel viewModel;
  @override
  Widget build(BuildContext context) {
    final String initialValue =
        viewModel.customerInformation?.addressLine1 ?? "";
    // final bool valueIsEmpty = initialValue.trim().isEmpty;
    return Row(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: LabelWidget(
            isRequired: (viewModel.showCurrentFiCreditRisk) ? false : true,
            showLabel: true,
            label: "customerInformation.customerInformation.addressLine1".tr(),
            child: CustomTextField(
              semanticLabel:
                  "customerInformation.customerInformation.addressLine1".tr(),
              // filled: !valueIsEmpty,
              // readOnly: viewModel.canEdit && !valueIsEmpty,
              maxLength: 500,
              initialValue: initialValue,
              validator: CustomValidator.requiredField,
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
