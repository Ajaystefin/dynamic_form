import "package:easy_localization/easy_localization.dart";
import "package:flutter/material.dart";
import "package:wcas_frontend/core/components/label.dart";
import "package:wcas_frontend/core/components/textfield.dart";
import "package:wcas_frontend/features/request/facilities_securities/create_security/model.dart";

class SecurityNumber extends StatelessWidget {
  const SecurityNumber({required this.viewModel, super.key});
  final CreateSecurityViewModel viewModel;

  @override
  Widget build(BuildContext context) {
    return LabelWidget(
      label: "security.createSecurity.securityNumber".tr(),
      isRequired: false,
      showLabel: true,
      child: CustomTextField(
        //TODO make better approach other than using textedit controller

        controller: viewModel.securityNumberController,
        readOnly: true,
        filled: true,
        // onSaved: (String? value) {
        //   debugPrint("security no onsaved check $value and number is
        // ${viewModel.security.securityNumber}");
        //   if (viewModel.security.securityNumber != null) {
        //     viewModel.security.securityNumber = value;
        //   }
        // },
      ),
    );
  }
}
