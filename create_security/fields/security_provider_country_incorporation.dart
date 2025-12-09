import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';

import 'package:wcas_frontend/core/components/dropdown/dropdown.dart';
import 'package:wcas_frontend/core/components/label.dart';
import 'package:wcas_frontend/core/constants/_server_constants.dart';
import 'package:wcas_frontend/features/request/facilities_securities/create_security/model.dart';
import 'package:wcas_frontend/models/request/country.dart';

class SecurityProviderCountryIncorporation extends StatelessWidget {
  final CreateSecurityViewModel viewModel;
  const SecurityProviderCountryIncorporation(
      {super.key, required this.viewModel});
  @override
  Widget build(BuildContext context) {
    return LabelWidget(
      label: viewModel.bankGuarantorFieldLabel() +
          'security.createSecurity.securityProviderCountryIncorporation'.tr(),
      isRequired:
          !viewModel.securityProviderCbdCustomer || viewModel.isEntityProvider,
      child: CustomDropdown<Country>(
        isEnabled: !viewModel.securityProviderCbdCustomer ||
            viewModel.isEntityProvider,
        isSearchable: true,
        validationMessage: "common.validation.emptyField".tr(),
        items: viewModel.countries,
        onSelected: (selectedValue) {
          viewModel.security.securityProvidedCountry = (selectedValue.first);
        },
        selectedItems: viewModel.didPrefillCountryFromRim &&
                viewModel.preselectedCountry != null
            ? viewModel.countries
                .where((country) =>
                    country.description ==
                    viewModel.preselectedCountry?.description)
                .toList()
            : viewModel.isSecurityProviderCbdCustomerNo
                ? viewModel.countries
                    .where((country) =>
                        country.description == ServerConstants.aedDescription)
                    .toList()
                : [],
        filterFn: (Country item, String filter) {
          return (item.description ?? item.toString())
              .toLowerCase()
              .contains(filter.toLowerCase());
        },
        itemBuilder: (context, item, isDisabled, isSelected) {
          return dropdownItemBuildWidget(item.description,
              isListTile: true, isSelected: isSelected);
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
}
