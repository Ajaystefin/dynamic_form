import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:wcas_frontend/core/components/label.dart';
import 'package:wcas_frontend/core/components/textfield.dart';

import 'package:wcas_frontend/features/request/facilities_securities/create_security/model.dart';

class SecurityProviderTlNumber extends StatelessWidget {
  final CreateSecurityViewModel viewModel;
  const SecurityProviderTlNumber({super.key, required this.viewModel});

  @override
  Widget build(BuildContext context) {
    return LabelWidget(
      label: 'security.createSecurity.securityProviderTlNumber'.tr(),
      child: CustomTextField(
        filled: !viewModel.isEntityProvider,
        readOnly: !viewModel.isEntityProvider,
        inputFormatters: [
          LengthLimitingTextInputFormatter(15),
        ],
        onSaved: (String? securityProvidedTl) {
          viewModel.security.securityProviderTlNo = securityProvidedTl;
        },
      ),
    );
  }
}
