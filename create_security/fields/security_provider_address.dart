import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:wcas_frontend/core/components/label.dart';
import 'package:wcas_frontend/core/components/textarea.dart';
import 'package:wcas_frontend/core/components/tooltip.dart';
import 'package:wcas_frontend/core/constants/_server_constants.dart';
import 'package:wcas_frontend/core/utils/validators.dart';

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
    bool isRequired = !viewModel.isFIFlow &&
        viewModel.security.selectedIsSecurityProviderCbdCustomerValue?.id ==
            ServerConstants.optionNOid;
    return CustomTooltip(
      message: tooltipMsg,
      child: LabelWidget(
        label: 'security.createSecurity.securityProviderAddress'.tr(),
        isRequired: isRequired,
        child: CustomTextArea(
            validator: isRequired ? CustomValidator.requiredField : null,
            initialValue: viewModel.security.securityProviderAddress,
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
