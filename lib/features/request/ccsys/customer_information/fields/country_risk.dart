import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:wcas_frontend/core/components/dropdown/multi_select_dropdown.dart';
import 'package:wcas_frontend/core/components/label.dart';
import 'package:wcas_frontend/features/request/ccsys/customer_information/model.dart';
import 'package:wcas_frontend/models/request/country.dart';

class CountryRisk extends StatelessWidget {
  final CustomerInformationViewModel viewModel;
  const CountryRisk(this.viewModel, {super.key});

  @override
  Widget build(BuildContext context) {
    return LabelWidget(
      label: "ccsys.customerInformation.CountryofRisk".tr(),
      child: CustomMultiSelectDropdown<Country>(
        filterFn: (Country item, String filter) {
          return (item.description ?? item.toString())
              .toLowerCase()
              .contains(filter.toLowerCase());
        },
        semanticLabel:
            "ccsys.customerInformation.CountryofRisk".tr(),
        isSearchable: true,
        isEnabled: true,
        validationMessage: "common.validation.emptyField".tr(),
        items: viewModel.countries ?? [],
        itemBuilder: (context, item, isDisabled, isSelected) {
          return dropdownMultiItemBuildWidget(item.description,
              isListTile: true, isSelected: isSelected);
        },
        dropdownBuilder: (context, data) {
          return multiSelectDropDownBuilderWidget(
            data: data!,
            itemBuilder: (index) {
              final country = data[index];
              return Container(
                margin: const EdgeInsets.all(4),
                child: buildMultiSelectChip(
                  label: buildItemText(
                    country.description ?? '',
                    FontSizeHelper(size: FontSize.small),
                  ),
                  onDeleted: () {
                    // => viewModel.onCountryChipDeleted(index)
                  },
                ),
              );
            },
          );
        },
        onSelected: (selected) {
          // delegate to VM
          // viewModel.updateCountriesOfRisk(selected);
        },
        selectedItems: viewModel.customerInformation.countryRiskWith ?? [],
      ),
    );
  }
}
