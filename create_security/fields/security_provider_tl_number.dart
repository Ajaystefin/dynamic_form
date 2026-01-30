import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:wcas_frontend/core/components/label.dart';
import 'package:wcas_frontend/core/components/textfield.dart';
import 'package:wcas_frontend/core/constants/_server_constants.dart';
import 'package:wcas_frontend/core/utils/validators.dart';

import 'package:wcas_frontend/features/request/facilities_securities/create_security/model.dart';

class SecurityProviderTlNumber extends StatelessWidget {
  final CreateSecurityViewModel viewModel;
  const SecurityProviderTlNumber({super.key, required this.viewModel});

  @override
  Widget build(BuildContext context) {
    bool isRimProvided =
        viewModel.security.selectedIsSecurityProviderCbdCustomerValue?.id ==
            ServerConstants.optionNOid;
    if (!viewModel.isEntityProvider) {
      viewModel.securityProviderTlNumberController.clear();
    }
    return LabelWidget(
      label: 'security.createSecurity.securityProviderTlNumber'.tr(),
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
