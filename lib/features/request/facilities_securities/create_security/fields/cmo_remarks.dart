import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:wcas_frontend/core/components/label.dart';
import 'package:wcas_frontend/core/components/textarea.dart';
import 'package:wcas_frontend/features/request/facilities_securities/create_security/model.dart';

class CmoRemarks extends StatelessWidget {
  final CreateSecurityViewModel viewModel;
  const CmoRemarks({super.key, required this.viewModel});

  @override
  Widget build(BuildContext context) {
    //final bool hasData = viewModel.CmoRemarks?.toString().isNotEmpty ?? false;
    return LabelWidget(
      label: 'security.createSecurity.cmoRemarks'.tr(),
      exponent: "#",
      isRequired: false,
      showLabel: true,
      child: CustomTextArea(
        initialValue: viewModel.security.cmoRemarks,
        filled: viewModel.isApproved,
        maxLength: 1000,
        readOnly: viewModel.isApproved && viewModel.iscmoRemarkReadOnly(),
        onSaved: (String? value) {
          viewModel.security.cmoRemarks = value;
        },
      ),
    );
  }
}
