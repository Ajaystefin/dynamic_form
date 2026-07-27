import "package:easy_localization/easy_localization.dart";
import "package:flutter/material.dart";
import "package:wcas_frontend/core/components/label.dart";
import "package:wcas_frontend/core/components/textfield.dart";
import "package:wcas_frontend/core/constants/_server_constants.dart";
import "package:wcas_frontend/core/globals.dart";
import "package:wcas_frontend/features/request/facilities_securities/create_security/model.dart";

/// Widget for displaying and managing the security number.
class SecurityNumber extends StatelessWidget {
  /// Creates a security number widget.
  const SecurityNumber({
    required this.viewModel,
    super.key,
  });

  /// View model containing security number data and actions.
  final CreateSecurityViewModel viewModel;

  @override
  Widget build(BuildContext context) {
    return LabelWidget(
      label: "security.createSecurity.securityNumber".tr(),
      child: CustomTextField(
        controller: viewModel.securityNumberController,
        readOnly: !(Globals.request?.applicationSubType ==
            ServerConstants.manualEntry),
        filled: true,
        // onSaved: (String? value) {
        //   logger.i("security no onsaved check $value and number is
        // ${viewModel.security.securityNumber}");
        //   if (viewModel.security.securityNumber != null) {
        //     viewModel.security.securityNumber = value;
        //   }
        // },
      ),
    );
  }
}
