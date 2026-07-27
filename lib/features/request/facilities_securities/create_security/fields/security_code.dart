import "package:easy_localization/easy_localization.dart";
import "package:flutter/material.dart";
import "package:wcas_frontend/core/components/label.dart";
import "package:wcas_frontend/core/components/textfield.dart";
import "package:wcas_frontend/core/constants/_server_constants.dart";
import "package:wcas_frontend/core/globals.dart";
import "package:wcas_frontend/core/utils/logger.dart";
import "package:wcas_frontend/core/utils/validators.dart";
import "package:wcas_frontend/features/request/facilities_securities/create_security/model.dart";

/// Widget for displaying the security code.
class SecurityCode extends StatelessWidget {
  /// Creates a security code widget.
  const SecurityCode({
    required this.viewModel,
    super.key,
  });

  /// View model containing security code data and actions.
  final CreateSecurityViewModel viewModel;

  @override
  Widget build(BuildContext context) {
    return LabelWidget(
      label: "security.createSecurity.securityCode".tr(),
      isRequired: !viewModel.isFIFlow,
      child: CustomTextField(
        initialValue: viewModel.security.securityType?.reference3 ??
            viewModel.security.securityCode,
        validator: CustomValidator.requiredField,
        readOnly: !(Globals.request?.applicationSubType ==
            ServerConstants.manualEntry),
        onSaved: (String? value) {
          logger.i("security Code: $value");
          if (viewModel.security.securityCode != null) {
            viewModel.security.securityCode = value;
          }
        },
      ),
    );
  }
}
