import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:wcas_frontend/core/components/label.dart';
import 'package:wcas_frontend/core/components/textfield.dart';
import 'package:wcas_frontend/core/utils/validators.dart';
import 'package:wcas_frontend/features/request/customer_information/customer_info/model.dart';

class AddressLineTwo extends StatelessWidget {
  const AddressLineTwo({super.key, required this.viewModel});
  final CustomerInfoViewModel viewModel;
  @override
  Widget build(BuildContext context) {
    final String initialValue =
        viewModel.customerInformation?.addressLine2 ?? "";
    final bool isValid = !viewModel.canEdit && initialValue.trim().isNotEmpty;
    return Row(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: LabelWidget(
            isRequired: (viewModel.showCurrentFiCreditRisk) ? false : true,
            showLabel: true,
            label: "customerInformation.customerInformation.addressLine2".tr(),
            child: CustomTextField(
              semanticLabel: "customerInformation.customerInformation.addressLine2".tr(),
              filled: isValid,
              readOnly: isValid,
              initialValue: initialValue,
              maxLength: 300,
              validator: CustomValidator.requiredField,
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
