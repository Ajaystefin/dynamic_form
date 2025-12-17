import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:wcas_frontend/core/components/label.dart';
import 'package:wcas_frontend/core/components/textfield.dart';
import 'package:wcas_frontend/core/utils/validators.dart';
import 'package:wcas_frontend/features/request/customer_information/customer_info/model.dart';

class PoBox extends StatelessWidget {
  const PoBox({super.key, required this.viewModel});
  final CustomerInfoViewModel viewModel;
  @override
  Widget build(BuildContext context) {
    final String initialValue = viewModel.customerInformation?.poBox ?? "";
    final bool isValid = !viewModel.canEdit && initialValue.trim().isNotEmpty;

    return Row(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: LabelWidget(
            isRequired: (viewModel.showCurrentFiCreditRisk) ? false : true,
            showLabel: true,
            label: "customerInformation.customerInformation.pOBoxNo".tr(),
            child: CustomTextField(
              semanticLabel:
                  "customerInformation.customerInformation.pOBoxNo".tr(),
              initialValue: viewModel.customerInformation?.poBox ?? "",
              filled: isValid,
              maxLength: 50,
              readOnly: isValid,
              validator: CustomValidator.requiredField,
              onSaved: (value) {
                viewModel.customerInformation?.poBox = value;
              },
            ),
          ),
        ),
      ],
    );
  }
}
