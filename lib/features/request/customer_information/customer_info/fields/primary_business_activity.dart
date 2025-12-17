import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:wcas_frontend/core/components/label.dart';
import 'package:wcas_frontend/core/components/textfield.dart';
import 'package:wcas_frontend/core/utils/validators.dart';
import 'package:wcas_frontend/features/request/customer_information/customer_info/model.dart';

class PrimaryBusinessActivity extends StatelessWidget {
  const PrimaryBusinessActivity({super.key, required this.viewModel});
  final CustomerInfoViewModel viewModel;
  @override
  Widget build(BuildContext context) {
    final String initialValue =
        viewModel.customerInformation?.primaryBusinessActivity ?? "";
    final bool isValid = !viewModel.canEdit && initialValue.trim().isNotEmpty;
    return LabelWidget(
      isRequired: (viewModel.showCurrentFiCreditRisk) ? false : true,
      showLabel: true,
      label: "customerInformation.customerInformation.primaryBusinessActivity"
          .tr(),
      child: CustomTextField(
        semanticLabel:
            "customerInformation.customerInformation.primaryBusinessActivity"
                .tr(),
        initialValue: initialValue,
        maxLength: 50,
        filled: isValid,
        readOnly: isValid,
        onSaved: (value) {
          viewModel.customerInformation?.primaryBusinessActivity = value;
        },
        validator: (viewModel.showCurrentFiCreditRisk)
            ? null
            : CustomValidator.requiredField,
      ),
    );
  }
}
