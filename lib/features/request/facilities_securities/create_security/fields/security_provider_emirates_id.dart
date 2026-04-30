import "package:easy_localization/easy_localization.dart";
import "package:flutter/material.dart";
import "package:flutter/services.dart";
import "package:wcas_frontend/core/components/label.dart";
import "package:wcas_frontend/core/components/textfield.dart";
import "package:wcas_frontend/core/constants/_server_constants.dart";
import "package:wcas_frontend/core/utils/validators.dart";

import "package:wcas_frontend/features/request/facilities_securities/create_security/model.dart";

class SecurityProviderEmiratesId extends StatelessWidget {
  const SecurityProviderEmiratesId({required this.viewModel, super.key});
  final CreateSecurityViewModel viewModel;

  @override
  Widget build(BuildContext context) {
    return LabelWidget(
      isEnabled: !viewModel.isCmoUpdate(),
      label: "security.createSecurity.securityProviderEmiratesId".tr(),
      isRequired: !viewModel.isFIFlow &&
          (viewModel.security.selectedIsSecurityProviderCbdCustomerValue?.id ==
                  ServerConstants.optionYESid
              ? false
              : !viewModel.isEntityProvider),
      child: CustomTextField(
        initialValue: "${viewModel.security.securityProviderEmiratesId ?? ''}",
        controller: viewModel.securityProviderEmiratesIDController,
        filled: viewModel.isEntityProvider && viewModel.isCmoUpdate(),
        readOnly: viewModel.security.securityProviderCategory == null ||
            viewModel.isEntityProvider ||
            viewModel.isCmoUpdate(),
        key: ValueKey(viewModel.isEntityProvider),
        keyboardType: TextInputType.number,
        counterText: "",
        maxLength: 15,
        inputFormatters: [
          FilteringTextInputFormatter.digitsOnly,
        ],
        validator: (value) {
          if (viewModel.isFIFlow) {
            return null;
          }
          if (viewModel
                  .security.selectedIsSecurityProviderCbdCustomerValue?.id ==
              ServerConstants.optionYESid) {
            return null;
          }
          if (!viewModel.isEntityProvider) {
            return CustomValidator.requiredField(value);
          }
          return null;
        },
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
