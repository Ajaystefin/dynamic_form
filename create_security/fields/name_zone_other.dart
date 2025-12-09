import 'package:flutter/material.dart';
import 'package:wcas_frontend/core/components/label.dart';
import 'package:wcas_frontend/core/components/textfield.dart';
import 'package:wcas_frontend/features/request/facilities_securities/create_security/model.dart';

class NameOfZoneOther extends StatelessWidget {
  final CreateSecurityViewModel viewModel;
  const NameOfZoneOther({super.key, required this.viewModel});

  @override
  Widget build(BuildContext context) {
    return LabelWidget(
      label: 'Please specify',
      isRequired: false,
      showLabel: true,
      child: CustomTextField(
        // initialValue: viewModel.security.securityNumber,

        onSaved: (String? value) {
          if (viewModel.security.securityNumber != null) {
            viewModel.security.securityNumber = value;
          }
        },
      ),
    );
  }
}
