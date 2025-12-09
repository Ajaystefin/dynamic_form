import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:wcas_frontend/core/components/dropdown/dropdown.dart';
import 'package:wcas_frontend/core/components/label.dart';
import 'package:wcas_frontend/features/request/facilities_securities/create_security/model.dart';
import 'package:wcas_frontend/models/request/country.dart';

class CountryOfIncorporation extends StatelessWidget {
  final CreateSecurityViewModel viewModel;
  const CountryOfIncorporation({super.key, required this.viewModel});

  @override
  Widget build(BuildContext context) {
    false;
    return LabelWidget(
      label: 'security.createSecurity.countryOfIncorporation'.tr(),
      isRequired: viewModel.securityProviderCbdCustomer,
      child: CustomDropdown<Country>(
        isSearchable: true,
        validationMessage: "validation.emptyField".tr(),
        items: viewModel.countries,
        isEnabled: viewModel.securityProviderCbdCustomer,
        selectedItems: [viewModel.security.countryOfIncorporate],
        onSelected: (selectedValue) {
          viewModel.security.countryOfIncorporate = (selectedValue.first);
        },
        filterFn: (Country item, String filter) {
          return (item.description ?? item.toString())
              .toLowerCase()
              .contains(filter.toLowerCase());
        },
        itemBuilder: (context, item, isDisabled, isSelected) {
          return ListTile(
            title: Text(item.description ?? ""),
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
}
