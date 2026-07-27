import "package:easy_localization/easy_localization.dart";
import "package:flutter/material.dart";
import "package:flutter/services.dart";
import "package:wcas_frontend/core/components/label.dart";
import "package:wcas_frontend/core/components/textfield.dart";
import "package:wcas_frontend/core/constants/_server_constants.dart";
import "package:wcas_frontend/core/constants/constants.dart";
import "package:wcas_frontend/core/utils/text_utils.dart";
import "package:wcas_frontend/core/utils/validators.dart";
import "package:wcas_frontend/features/request/facilities_securities/create_security/model.dart";

/// Widget for displaying and managing the security provider RIM number.
class SecurityProviderRimNumber extends StatelessWidget {
  /// Creates a security provider RIM number widget.
  const SecurityProviderRimNumber({
    required this.viewModel,
    super.key,
  });

  /// View model containing security provider RIM number data and actions.
  final CreateSecurityViewModel viewModel;

  @override
  Widget build(BuildContext context) {
    String? enteredValue;
    return LabelWidget(
      isEnabled:
          viewModel.securityProviderCbdCustomer && !viewModel.isCmoUpdate(),
      label: viewModel.bankGuarantorFieldLabel() +
          "security.createSecurity.securityProviderRimNo".tr(),
      isRequired: !viewModel.isFIFlow && viewModel.securityProviderCbdCustomer,
      child: CustomTextField(
        initialValue: viewModel.security.securityProvidedRim,
        controller: viewModel.securityProviderRimNumberController,
        inputFormatters: [
          ThousandsWithMaxDigitsFormatter(maxDigits: 15),
          FilteringTextInputFormatter.digitsOnly,
        ],
        onSaved: (value) {
          viewModel.security.securityProvidedRim = value;
        },
        onChanged: (value) {
          enteredValue = value;
        },
        suffixIcon: Padding(
          padding: const EdgeInsets.all(4),
          child: DecoratedBox(
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
        // hintText: viewModel.security.securityProvidedRim?.toString(),
        validator: (value) {
          if (viewModel.isFIFlow) {
            return null;
          }
          if (!viewModel.securityProviderCbdCustomer) {
            return null;
          }
          if (viewModel
                  .security.selectedIsSecurityProviderCbdCustomerValue?.id ==
              ServerConstants.optionNOid) {
            return null;
          }
          return CustomValidator.requiredField(value);
        },
      ),
    );
  }
}
