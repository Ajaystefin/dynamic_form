import "package:easy_localization/easy_localization.dart";
import "package:flutter/material.dart";
import "package:flutter/services.dart";
import "package:wcas_frontend/core/components/label.dart";
import "package:wcas_frontend/core/components/textfield.dart";
import "package:wcas_frontend/core/constants/_server_constants.dart";
import "package:wcas_frontend/core/utils/validators.dart";
import "package:wcas_frontend/features/request/facilities_securities/create_security/model.dart";

/// Widget for displaying and managing the security provider TL number.
class SecurityProviderTlNumber extends StatelessWidget {
  /// Creates a security provider TL number widget.
  const SecurityProviderTlNumber({
    required this.viewModel,
    super.key,
  });

  /// View model containing security provider TL number data and actions.
  final CreateSecurityViewModel viewModel;

  @override
  Widget build(BuildContext context) {
    final bool isRimProvided =
        viewModel.security.selectedIsSecurityProviderCbdCustomerValue?.id ==
            ServerConstants.optionNOid;

    return LabelWidget(
      isEnabled: !viewModel.isCmoUpdate(),
      label: "security.createSecurity.securityProviderTlNumber".tr(),
      isRequired: !viewModel.isFIFlow &&
          (isRimProvided &&
              viewModel.isEntityProvider &&
              !viewModel.isCmoUpdate()),
      child: CustomTextField(
        initialValue: " ${viewModel.security.securityProviderTlNo ?? ""}",
        controller: viewModel.securityProviderTlNumberController,
        filled: !viewModel.isEntityProvider,
        readOnly: !viewModel.isEntityProvider, // || viewModel.isCmoUpdate(),
        validator: isRimProvided &&
                viewModel.isEntityProvider &&
                !viewModel.isCmoUpdate()
            ? CustomValidator.requiredField
            : null,
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
