import "package:easy_localization/easy_localization.dart";
import "package:flutter/material.dart";
import "package:wcas_frontend/core/components/dropdown/multi_select_dropdown.dart";
import "package:wcas_frontend/core/components/label.dart";
import "package:wcas_frontend/features/request/customer_information/customer_info/model.dart";
import "package:wcas_frontend/models/request/country.dart";

/// Countries traded with field for the customer information screen.
class CountriesTradedWithField extends StatelessWidget {
  /// Creates a countries traded with field.
  CountriesTradedWithField({required this.viewModel, super.key});

  /// Customer information view model.
  final CustomerInfoViewModel viewModel;

  /// Scroll controller used by the selected countries chip list.
  final ScrollController contrlr = ScrollController();

  @override
  Widget build(BuildContext context) {
    return LabelWidget(
      isRequired: !viewModel.isFI,
      label: "customerInformation.customerInformation.contriesTradedWith".tr(),
      child: CustomMultiSelectDropdown<Country>(
        key: ValueKey(
          viewModel.customerInformation?.countriesTradedWith?.length,
        ),
        semanticLabel:
            "customerInformation.customerInformation.contriesTradedWith".tr(),
        isSearchable: true,
        isEnabled: viewModel.canEdit,
        validationMessage:
            (viewModel.isFI) ? null : "common.validation.emptyField".tr(),
        items: viewModel.countries ?? [],
        itemBuilder: (context, item, {isDisabled, isSelected}) {
          return dropdownMultiItemBuildWidget(
            item.description,
            isSelected: isSelected ?? false,
          );
        },
        filterFn: (Country item, String filter) {
          return (item.description ?? item.toString())
              .toLowerCase()
              .contains(filter.toLowerCase());
        },
        dropdownBuilder: (context, data) {
          return multiSelectDropDownBuilderWidget(
            data: data!,
            controller: contrlr,
            key: ValueKey(
              viewModel.customerInformation?.countriesTradedWith?.length,
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
                  onDeleted: () => viewModel.onCountryTradedDeleted(index),
                ),
              );
            },
          );
        },
        onSelected: (selected) {
          // delegate to VM
          viewModel.updateCountriesOfTraded(selected);
        },
        selectedItems: viewModel.customerInformation?.countriesTradedWith ?? [],
      ),
    );
  }
}
