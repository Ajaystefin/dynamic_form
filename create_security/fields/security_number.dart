import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:wcas_frontend/core/components/label.dart';
import 'package:wcas_frontend/core/components/textfield.dart';
import 'package:wcas_frontend/features/request/facilities_securities/create_security/model.dart';

class SecurityNumber extends StatelessWidget {
  final CreateSecurityViewModel viewModel;
  const SecurityNumber({super.key, required this.viewModel});

  @override
  Widget build(BuildContext context) {
    return LabelWidget(
      label: 'security.createSecurity.securityNumber'.tr(),
      isRequired: false,
      showLabel: true,
      child: CustomTextField(
        initialValue: viewModel.security.securityNumber,
        readOnly: true,
        filled: true,
        onSaved: (String? value) {
          if (viewModel.security.securityNumber != null) {
            viewModel.security.securityNumber = value;
          }
        },
      ),
    );
  }
}
