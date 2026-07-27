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

/// Widget for displaying and managing the security provider name.
class SecurityProviderName extends StatelessWidget {
  /// Creates a security provider name widget.
  const SecurityProviderName({
    required this.viewModel,
    super.key,
  });

  /// View model containing security provider name data and actions.
  final CreateSecurityViewModel viewModel;

  @override
  Widget build(BuildContext context) {
    final int? typeId = viewModel.security.securityType?.id;
    final bool isCorporateOrPersonalGuarantee =
        typeId == ServerConstants.corporateGuaranteeId ||
            typeId == ServerConstants.personalGuaranteeId;

    // "#" marks CMO-updatable fields (see "cmoUpdatableFields" legend).
    // Bank Guarantee already showed it; add Corporate & Personal Guarantee.
    final bool showCmoMarker = typeId == ServerConstants.bankGuaranteeId ||
        isCorporateOrPersonalGuarantee;

    // Editable during CMO update for all security types, regardless of CBD
    // customer status. Outside CMO update, locked when provider is a CBD customer.
    final bool isProviderNameReadOnly =
        !viewModel.isCmoUpdate() && viewModel.securityProviderCbdCustomer;

    return LabelWidget(
      label: viewModel.bankGuarantorFieldLabel() +
          "security.createSecurity.securityProviderName".tr(),
      isRequired: !viewModel.isFIFlow && !viewModel.securityProviderCbdCustomer,
      exponent: showCmoMarker ? "#" : "",
      child: (viewModel.security.securityType?.id ==
                  ServerConstants.securityTypeId[SecurityType.bankGuarantee] &&
              !isProviderNameReadOnly)
          ? CustomDropdown<Reference?>(
              ignoreProvider: viewModel.security.securityType?.id ==
                  ServerConstants.securityTypeId[SecurityType.bankGuarantee],
              isSearchable: true,
              validationMessage: viewModel.isFIFlow
                  ? null
                  : (!viewModel.securityProviderCbdCustomer ||
                          viewModel
                                  .security
                                  .selectedIsSecurityProviderCbdCustomerValue
                                  ?.id ==
                              ServerConstants.optionNOid)
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
              itemBuilder: (context, item, {isDisabled, isSelected}) {
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
              keyboardType: TextInputType.name,
              inputFormatters: [
                FilteringTextInputFormatter.allow(RegExp("[a-zA-Z0-9 ]")),
              ],
              controller: viewModel.securityProviderNameController,
              hintText: viewModel.security.securityProvidedName,
              readOnly: isProviderNameReadOnly,
              filled: isProviderNameReadOnly,
              validator: viewModel.isFIFlow
                  ? null
                  : (!viewModel.securityProviderCbdCustomer ||
                          viewModel
                                  .security
                                  .selectedIsSecurityProviderCbdCustomerValue
                                  ?.id ==
                              ServerConstants.optionNOid)
                      ? CustomValidator.requiredField
                      : null,
              onSaved: (String? value) {
                viewModel.security.securityProvidedName = value;
              },
            ),
    );
  }
}
