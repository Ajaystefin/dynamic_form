import "package:easy_localization/easy_localization.dart";
import "package:flutter/material.dart";
import "package:wcas_frontend/core/components/dropdown/dropdown.dart";
import "package:wcas_frontend/core/components/dropdown/multi_select_dropdown.dart";
import "package:wcas_frontend/core/components/textfield.dart";
import "package:wcas_frontend/features/request/customer_information/customer_info/model.dart";
import "package:wcas_frontend/models/request/country.dart";

class NationalityDropdown extends StatelessWidget {
  const NationalityDropdown({
    required this.viewModel,
    required this.selectedNationality,
    required this.isEnabled,
    required this.onSelected,
    required this.index,
    required this.initial,
    super.key,
  });
  final CustomerInfoViewModel viewModel;
  final Country? selectedNationality;
  final bool isEnabled;
  final Function(Country) onSelected;
  final int index;
  final String? initial;

  @override
  Widget build(BuildContext context) {
    return isEnabled
        ? CustomDropdown<Country>(
            key: ValueKey("nationality_dropdown_$index"),
            items: viewModel.countries,
            // isEnabled: isEnabled,
            isSearchable: true,
            selectedItems:
                selectedNationality != null ? [selectedNationality] : null,
            itemBuilder: (context, item, isDisabled, isSelected) {
              return dropdownMultiItemBuildWidget(
                item.description,
                isListTile: true,
                isSelected: isSelected,
              );
            },
            dropdownBuilder: (context, item) => dropdownBuilderWidget(
              text: item?.description,
              showToolTip: false,
            ),
            filterFn: (Country item, String filter) {
              return (item.description ?? item.toString())
                  .toLowerCase()
                  .contains(filter.toLowerCase());
            },
            onSelected: (selected) => onSelected(selected[0]),
            validationMessage:
                (viewModel.isFI) ? null : "common.validation.emptyField".tr(),
            semanticLabel:
                "customerInformation.customerInformation.nationality".tr(),
          )
        : CustomTextField(
            readOnly: !isEnabled,
            filled: !isEnabled,
            initialValue: initial,
          );
  }
}
