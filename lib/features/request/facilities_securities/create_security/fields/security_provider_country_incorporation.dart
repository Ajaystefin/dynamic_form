import "package:easy_localization/easy_localization.dart";
import "package:flutter/material.dart";
import "package:wcas_frontend/core/components/dropdown/dropdown.dart";
import "package:wcas_frontend/core/components/label.dart";
import "package:wcas_frontend/core/constants/_server_constants.dart";
import "package:wcas_frontend/features/request/facilities_securities/create_security/model.dart";
import "package:wcas_frontend/models/request/country.dart";

class SecurityProviderCountryIncorporation extends StatelessWidget {
  const SecurityProviderCountryIncorporation({
    required this.viewModel,
    super.key,
  });
  final CreateSecurityViewModel viewModel;
  @override
  Widget build(BuildContext context) {
    // Extract boolean flags for readability
    final bool isCbdCustomer =
        viewModel.security.selectedIsSecurityProviderCbdCustomerValue?.id ==
            ServerConstants.optionYESid;
    final bool isEntityProvider = viewModel.isEntityProvider;

    // Determine field state
    final bool isRequired =
        !viewModel.isFIFlow && (!isCbdCustomer && isEntityProvider);
    final bool isEnabled =
        (!isCbdCustomer && (isEntityProvider || viewModel.isGuaranteeType)) &&
            !viewModel.isCmoUpdate();

    // Define Label
    final bool isBankOrCorporateGuarantee =
        viewModel.security.securityType?.id ==
                ServerConstants.bankGuaranteeId ||
            viewModel.security.securityType?.id ==
                ServerConstants.corporateGuaranteeId;

    final String labelPrefix =
        isBankOrCorporateGuarantee ? "" : viewModel.bankGuarantorFieldLabel();
    final String label = labelPrefix +
        "security.createSecurity.securityProviderCountryIncorporation".tr();
    final List<Country> selectedItems = _getSelectedItems();
    return LabelWidget(
      label: label,
      isRequired: isRequired,
      child: CustomDropdown<Country>(
        key: ValueKey(selectedItems.hashCode),
        isEnabled: isEnabled,
        isSearchable: true,
        // Shows validation message only if logic dictates (currently strict
        // based on flags)
        validationMessage:
            isRequired ? "common.validation.emptyRequiredField".tr() : null,
        items: viewModel.countries,
        onSelected: (selectedValue) {
          viewModel.security.securityProvidedCountry = selectedValue.first;
        },
        selectedItems: selectedItems,
        filterFn: (Country item, String filter) {
          return (item.description ?? item.toString())
              .toLowerCase()
              .contains(filter.toLowerCase());
        },
        itemBuilder: (context, item, isDisabled, isSelected) {
          return dropdownItemBuildWidget(
            item.description,
            isListTile: true,
            isSelected: isSelected,
          );
        },
        dropdownBuilder: (context, data) {
          return Text(
            data?.description ?? "",
            style: const TextStyle(fontSize: 14),
          );
        },
      ),
    );
  }

  List<Country> _getSelectedItems() {
    if (viewModel.security.securityProvidedCountry != null) {
      viewModel.security.securityProvidedCountry =
          viewModel.security.securityProvidedCountry;
      return [viewModel.security.securityProvidedCountry!];
    }

    if (viewModel.didPrefillCountryFromRim &&
        viewModel.preselectedCountry != null) {
      final List<Country> filteredCountry = viewModel.countries
          .where(
            (country) =>
                country.description ==
                viewModel.preselectedCountry?.description,
          )
          .toList();
      viewModel.security.securityProvidedCountry = filteredCountry.first;
      return filteredCountry;
    }

    if (viewModel.security.selectedIsSecurityProviderCbdCustomerValue?.id ==
        ServerConstants.optionNOid) {
      if (viewModel.security.securityProviderCategory != null &&
          !viewModel.isEntityProvider) {
        return [];
      }
      final List<Country> selectedCountries = viewModel.countries
          .where(
            (country) => country.description == ServerConstants.aedDescription,
          )
          .toList();
      viewModel.security.securityProvidedCountry = selectedCountries.first;
      return selectedCountries;
    }

    return [];
  }
}
