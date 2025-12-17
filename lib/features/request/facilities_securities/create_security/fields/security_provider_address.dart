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
    final tooltipMsg =
        (viewModel.security.securityProviderAddress?.trim().isNotEmpty == true)
            ? viewModel.security.securityProviderAddress!
            : 'security.createSecurity.securityProviderAddress'.tr();

    return CustomTooltip(
      message: tooltipMsg,
      child: LabelWidget(
        label: 'security.createSecurity.securityProviderAddress'.tr(),
        child: CustomTextArea(
            maxLength: 1000,
            readOnly: viewModel.isCmoUpdate(),
            onChanged: (String value) =>
                viewModel.updateSecurityProviderAddress(value),
            onSaved: (String? value) =>
                viewModel.updateSecurityProviderAddress(value ?? '')),
      ),
    );
  }
}
