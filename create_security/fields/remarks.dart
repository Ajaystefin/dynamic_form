import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:wcas_frontend/core/components/label.dart';
import 'package:wcas_frontend/core/components/textarea.dart';
import 'package:wcas_frontend/features/request/facilities_securities/create_security/model.dart';

class Remarks extends StatelessWidget {
  final CreateSecurityViewModel viewModel;
  const Remarks({super.key, required this.viewModel});

  @override
  Widget build(BuildContext context) {
    return LabelWidget(
      label: 'security.createSecurity.remarks'.tr(),
      isRequired: false,
      showLabel: true,
      child: CustomTextArea(
        initialValue: viewModel.security.remarks,
        maxLength: 1000,
        onSaved: (String? value) {
          viewModel.security.remarks = value;
        },
      ),
    );
  }
}
