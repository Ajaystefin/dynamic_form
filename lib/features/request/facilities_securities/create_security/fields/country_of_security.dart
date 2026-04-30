import "package:easy_localization/easy_localization.dart";
import "package:flutter/material.dart";
import "package:wcas_frontend/core/components/dropdown/dropdown.dart";
import "package:wcas_frontend/core/components/label.dart";
//import 'package:wcas_frontend/core/constants/_server_constants.dart';
//import 'package:wcas_frontend/core/constants/_server_constants.dart';
import "package:wcas_frontend/features/request/facilities_securities/create_security/model.dart";
import "package:wcas_frontend/models/request/country.dart";

class CountryOfSecurity extends StatelessWidget {
  const CountryOfSecurity({required this.viewModel, super.key});
  final CreateSecurityViewModel viewModel;
  @override
  Widget build(BuildContext context) {
    return LabelWidget(
      isRequired: !viewModel.isFIFlow,
      isEnabled: !viewModel.isCmoUpdate(),
      label: "security.createSecurity.countryOfSecurity".tr(),
      child: CustomDropdown<Country>(
        isSearchable: true,
        isEnabled: !viewModel.isCmoUpdate(),
        validationMessage: !viewModel.isFIFlow
            ? "common.validation.emptyRequiredField".tr()
            : null,
        items: viewModel.countries,
        selectedItems: <Country>[
          // Only include a Country if there's an actual value
          if ((viewModel.security.countryOfSecurity ?? "").trim().isNotEmpty)
            Country(description: viewModel.security.countryOfSecurity),
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
          return dropdownItemBuildWidget(
            item.description,
            isListTile: true,
            isSelected: isSelected,
          );
        },
        dropdownBuilder: (context, data) {
          return dropdownBuilderWidget(
            text: data?.description,
            showToolTip: false,
          );
        },
      ),
    );
  }
}
