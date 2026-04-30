import "package:easy_localization/easy_localization.dart";
import "package:flutter/material.dart";
import "package:flutter/services.dart";
import "package:wcas_frontend/core/components/dropdown/dropdown.dart";
import "package:wcas_frontend/core/components/label.dart";
import "package:wcas_frontend/core/components/textfield.dart";
import "package:wcas_frontend/core/constants/_server_constants.dart";
import "package:wcas_frontend/core/utils/utils.dart";
import "package:wcas_frontend/core/utils/validators.dart";
import "package:wcas_frontend/features/request/facilities_securities/create_security/model.dart";
import "package:wcas_frontend/models/admin/reference.dart";

class SecurityProviderName extends StatelessWidget {
  const SecurityProviderName({required this.viewModel, super.key});
  final CreateSecurityViewModel viewModel;

  @override
  Widget build(BuildContext context) {
    return LabelWidget(
      label: viewModel.bankGuarantorFieldLabel() +
          "security.createSecurity.securityProviderName".tr(),
      isRequired: !viewModel.isFIFlow && !viewModel.securityProviderCbdCustomer,
      exponent: viewModel.security.securityType?.id ==
              ServerConstants.securityTypeId[SecurityType.bankGuarantee]
          ? "#"
          : "",
      child: (viewModel.security.securityType?.id ==
                  ServerConstants.securityTypeId[SecurityType.bankGuarantee] &&
              !viewModel.securityProviderCbdCustomer)
          ? CustomDropdown<Reference?>(
              isSearchable: true,
              validationMessage: !viewModel.securityProviderCbdCustomer ||
                      viewModel.security
                              .selectedIsSecurityProviderCbdCustomerValue?.id ==
                          ServerConstants.optionNOid
                  ? "validation.emptyField".tr()
                  : null,
              items: viewModel.bankNames,
              isEnabled: viewModel.bankNames.isNotEmpty,
              selectedItems: viewModel.security.securityProvidedName != null
                  ? [Reference(name: viewModel.security.securityProvidedName)]
                  : null,
              onSelected: (selectedValue) async {
                viewModel.security.securityProvidedName =
                    selectedValue.first?.name;
              },
              itemBuilder: (context, item, isDisabled, isSelected) {
                return ListTile(
                  title: Text(item?.name ?? ""),
                );
              },
              filterFn: (item, search) {
                return (item?.name ?? "")
                    .toLowerCase()
                    .contains(search.toLowerCase());
              },
              dropdownBuilder: (context, data) {
                return Text(
                  data?.name ?? "",
                  style: const TextStyle(fontSize: 14),
                );
              },
            )
          : CustomTextField(
              initialValue: viewModel.security.securityProvidedName,
              maxLength: 50,
              counterText: "",
              keyboardType: TextInputType.name,
              inputFormatters: [
                FilteringTextInputFormatter.allow(RegExp("[a-zA-Z0-9 ]")),
              ],
              controller: viewModel.securityProviderNameController,
              hintText: viewModel.security.securityProvidedName,
              readOnly: viewModel.securityProviderCbdCustomer,
              filled: viewModel.securityProviderCbdCustomer,
              validator: !viewModel.securityProviderCbdCustomer ||
                      viewModel.security
                              .selectedIsSecurityProviderCbdCustomerValue?.id ==
                          ServerConstants.optionNOid
                  ? CustomValidator.requiredField
                  : null,
              onSaved: (String? value) {
                viewModel.security.securityProvidedName = value;
              },
            ),
    );
  }
}
