import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:wcas_frontend/core/components/label.dart';
import 'package:wcas_frontend/core/components/textfield.dart';
import 'package:wcas_frontend/core/constants/_server_constants.dart';
import 'package:wcas_frontend/core/utils/validators.dart';

import 'package:wcas_frontend/features/request/facilities_securities/create_security/model.dart';

class SecurityProviderEmiratesId extends StatelessWidget {
  final CreateSecurityViewModel viewModel;
  const SecurityProviderEmiratesId({super.key, required this.viewModel});

  @override
  Widget build(BuildContext context) {
    return LabelWidget(
      label: 'security.createSecurity.securityProviderEmiratesId'.tr(),
      isRequired: !viewModel.isFIFlow &&
          (viewModel.security.selectedIsSecurityProviderCbdCustomerValue?.id ==
                  ServerConstants.optionYESid
              ? false
              : !viewModel.isEntityProvider),
      child: CustomTextField(
        initialValue: "${viewModel.security.securityProviderEmiratesId ?? ''}",
        filled: viewModel.isEntityProvider && viewModel.isCmoUpdate(),
        readOnly: viewModel.isEntityProvider || viewModel.isCmoUpdate(),
        key: ValueKey(viewModel.isEntityProvider),
        keyboardType: TextInputType.number,
        counterText: '',
        maxLength: 15,
        inputFormatters: [
          FilteringTextInputFormatter.digitsOnly,
        ],
        validator:
            viewModel.security.selectedIsSecurityProviderCbdCustomerValue?.id ==
                    ServerConstants.optionYESid
                ? null
                : !viewModel.isEntityProvider
                    ? CustomValidator.requiredField
                    : null,
        // errorText: !viewModel.isEntityProvider
        //     ? "common.validation.emptyField".tr()
        //     : null,
        onSaved: (String? securityProvidedEmiratesId) {
          viewModel.security.securityProviderEmiratesId =
              int.tryParse(securityProvidedEmiratesId!);
        },
      ),
    );
  }
}
