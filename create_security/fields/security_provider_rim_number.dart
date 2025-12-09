import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:wcas_frontend/core/components/label.dart';
import 'package:wcas_frontend/core/components/textfield.dart';
import 'package:wcas_frontend/core/constants/constants.dart';
import 'package:wcas_frontend/core/utils/validators.dart';
import 'package:wcas_frontend/features/request/facilities_securities/create_security/model.dart';

class SecurityProviderRimNumber extends StatelessWidget {
  final CreateSecurityViewModel viewModel;

  const SecurityProviderRimNumber({super.key, required this.viewModel});

  @override
  Widget build(BuildContext context) {
    String? enteredValue;
    return LabelWidget(
      label: viewModel.bankGuarantorFieldLabel() +
          "security.createSecurity.securityProviderRimNo".tr(),
      isRequired: !viewModel.securityProviderCbdCustomer,
      child: CustomTextField(
        controller: viewModel.securityProviderRimNumberController,
        readOnly: viewModel.securityProviderCbdCustomer,
        filled: viewModel.securityProviderCbdCustomer,
        inputFormatters: [
          LengthLimitingTextInputFormatter(15),
          FilteringTextInputFormatter.digitsOnly,
        ],
        onSaved: (value) {
          viewModel.security.securityProvidedRim = value;
        },
        onChanged: (value) {
          enteredValue = value;
        },
        suffixIcon: Padding(
          padding: const EdgeInsets.all(4.0),
          child: Container(
            decoration: BoxDecoration(
              color: AppColors.primary,
              borderRadius: BorderRadius.circular(6),
            ),
            child: InkWell(
              onTap: () async {
                if (enteredValue != null) {
                  await viewModel.searchByRim(enteredValue ?? "");
                }
              },
              child: const Icon(
                Icons.search_rounded,
                color: AppColors.white,
              ),
            ),
          ),
        ),
        // initialValue: viewModel.security?.securityProvidedRim?.toString(),
        hintText: viewModel.security.securityProvidedRim?.toString(),
        validator: viewModel.securityProviderCbdCustomer
            ? null
            : CustomValidator.requiredField,
      ),
    );
  }
}
