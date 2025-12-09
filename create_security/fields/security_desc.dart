import 'package:flutter/material.dart';
import 'package:wcas_frontend/core/components/label.dart';
import 'package:wcas_frontend/core/components/textfield.dart';
import 'package:wcas_frontend/features/request/facilities_securities/create_security/model.dart';

class SecurityDescription extends StatelessWidget {
  final CreateSecurityViewModel viewModel;
  const SecurityDescription({
    super.key,
    required this.viewModel,
  });
  @override
  Widget build(BuildContext context) {
    return LabelWidget(
      label: 'Security Description',
      isRequired: true,
      child: CustomTextField(
        initialValue: viewModel.security.securityType?.name,
        readOnly: true,
        filled: true,
        onSaved: (String? value) {
          viewModel.security.securityType?.name = value;
        },
      ),
    );
  }
}
