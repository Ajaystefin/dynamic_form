import 'package:flutter/material.dart';
import 'package:wcas_frontend/core/components/label.dart';
import 'package:wcas_frontend/core/components/textfield.dart';
import 'package:wcas_frontend/features/request/facilities_securities/create_security/model.dart';

class CurrentTimeDepositAccountNumber extends StatelessWidget {
  final CreateSecurityViewModel viewModel;
  const CurrentTimeDepositAccountNumber({
    super.key,
    required this.viewModel,
  });
  @override
  Widget build(BuildContext context) {
    return LabelWidget(
      label: 'Current/Time deposit account number ',
      isRequired: false,
      showLabel: true,
      child: CustomTextField(
        initialValue: viewModel.security.currentDepositAccountNumber,
        onSaved: (String? value) {
          if (viewModel.security.currentDepositAccountNumber != null) {
            viewModel.security.currentDepositAccountNumber = value;
          }
        },
      ),
    );
  }
}
