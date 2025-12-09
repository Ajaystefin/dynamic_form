import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:wcas_frontend/core/components/label.dart';
import 'package:wcas_frontend/core/components/textfield.dart';
import 'package:wcas_frontend/core/utils/validators.dart';
import 'package:wcas_frontend/features/request/facilities_securities/create_security/model.dart';

class SecurityCode extends StatelessWidget {
  final CreateSecurityViewModel viewModel;
  const SecurityCode({super.key, required this.viewModel});

  @override
  Widget build(BuildContext context) {
    return LabelWidget(
      label: 'security.createSecurity.securityCode'.tr(),
      isRequired: true,
      showLabel: true,
      child: CustomTextField(
        initialValue: viewModel.security.securityType?.reference3,
        validator: CustomValidator.requiredField,
        filled: true,
        readOnly: true,
      ),
    );
  }
}
