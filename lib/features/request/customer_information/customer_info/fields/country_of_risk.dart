import "package:easy_localization/easy_localization.dart";
import "package:flutter/material.dart";
import "package:wcas_frontend/core/components/dropdown/multi_select_dropdown.dart";
import "package:wcas_frontend/core/components/label.dart";
import "package:wcas_frontend/features/request/customer_information/customer_info/model.dart";
import "package:wcas_frontend/models/request/country.dart";

class CountryOfRisk extends StatelessWidget {
  CountryOfRisk({required this.viewModel, super.key});
  final CustomerInfoViewModel viewModel;
  final ScrollController contrlr = ScrollController();

  @override
  Widget build(BuildContext context) {
    return LabelWidget(
      isRequired: !viewModel.isFI,
      label: "customerInformation.customerInformation.countryOfRisk".tr(),
      child: CustomMultiSelectDropdown<Country>(
        filterFn: (Country item, String filter) {
          return (item.description ?? item.toString())
              .toLowerCase()
              .contains(filter.toLowerCase());
        },
        key: ValueKey(viewModel.customerInformation?.countryRiskWith?.length),
        semanticLabel:
            "customerInformation.customerInformation.countryOfRisk".tr(),
        isSearchable: true,
        isEnabled: viewModel.canEdit,
        validationMessage:
            (viewModel.isFI) ? null : "common.validation.emptyField".tr(),
        items: viewModel.countries ?? [],
        itemBuilder: (context, item, isDisabled, isSelected) {
          return dropdownMultiItemBuildWidget(
            item.description,
            isListTile: true,
            isSelected: isSelected,
          );
        },
        dropdownBuilder: (context, data) {
          return multiSelectDropDownBuilderWidget(
            data: data!,
            controller: contrlr,
            key: ValueKey(
              viewModel.customerInformation?.countryRiskWith?.length,
            ),
            itemBuilder: (index) {
              final country = data[index];
              return Container(
                margin: const EdgeInsets.only(
                  left: 5,
                  top: 5,
                  bottom: 5,
                  right: 15,
                ),
                child: buildMultiSelectChip(
                  label: buildItemText(
                    country.description ?? "",
                    FontSizeHelper(size: FontSize.small),
                  ),
                  onDeleted: () => viewModel.onCountryChipDeleted(index),
                ),
              );
            },
          );
        },
        onSelected: (selected) {
          // delegate to VM
          viewModel.updateCountriesOfRisk(selected);
        },
        selectedItems: viewModel.customerInformation?.countryRiskWith ?? [],
      ),
    );
  }
}
