import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';

import 'package:wcas_frontend/core/components/dropdown/dropdown.dart';
import 'package:wcas_frontend/core/components/label.dart';
//import 'package:wcas_frontend/core/constants/_server_constants.dart';
//import 'package:wcas_frontend/core/constants/_server_constants.dart';
import 'package:wcas_frontend/features/request/facilities_securities/create_security/model.dart';
import 'package:wcas_frontend/models/request/country.dart';

class CountryOfSecurity extends StatelessWidget {
  final CreateSecurityViewModel viewModel;
  const CountryOfSecurity({super.key, required this.viewModel});
  @override
  Widget build(BuildContext context) {
    return LabelWidget(
      isRequired: !viewModel.isFIFlow,
      label: 'security.createSecurity.countryOfSecurity'.tr(),
      child: CustomDropdown<Country>(
        isSearchable: true,
        isEnabled: !viewModel.isCmoUpdate(),
        validationMessage: "common.validation.emptyRequiredField".tr(),
        items: viewModel.countries,
        selectedItems: [
          Country(description: viewModel.security.countryOfSecurity)
        ],
        onSelected: (selectedValue) {
          viewModel.onSelectCountryofSecurity(selectedValue.first);
        },
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
          return dropdownBuilderWidget(
              text: data?.description, showToolTip: false);
        },
      ),
    );
  }
}
