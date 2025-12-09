import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:wcas_frontend/core/components/label.dart';
import 'package:wcas_frontend/core/components/textarea.dart';
import 'package:wcas_frontend/core/components/tooltip.dart';

import 'package:wcas_frontend/features/request/facilities_securities/create_security/model.dart';

class SecurityProviderAddress extends StatelessWidget {
  final CreateSecurityViewModel viewModel;
  const SecurityProviderAddress({super.key, required this.viewModel});

  @override
  Widget build(BuildContext context) {
    return CustomTooltip(message: 'security.createSecurity.securityProviderAddress'.tr(),
      child: LabelWidget(
        label: 'security.createSecurity.securityProviderAddress'.tr(),
        child: CustomTextArea(
          maxLength: 1000,
          onSaved: (String? value) {
            viewModel.security.securityProviderAddress = value;
          },
        ),
      ),
    );
  }
}
