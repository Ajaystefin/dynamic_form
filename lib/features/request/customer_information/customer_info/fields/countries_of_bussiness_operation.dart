import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:wcas_frontend/core/components/dropdown/multi_select_dropdown.dart';
import 'package:wcas_frontend/core/components/label.dart';
import 'package:wcas_frontend/models/request/country.dart';

import 'package:wcas_frontend/features/request/customer_information/customer_info/model.dart';

class CountriesOfBussinessOperationField extends StatelessWidget {
  CountriesOfBussinessOperationField({super.key, required this.viewModel});
  final CustomerInfoViewModel viewModel;

  final ScrollController contrlr = ScrollController();
  @override
  Widget build(BuildContext context) {
    return LabelWidget(
        isRequired: (viewModel.showCurrentFiCreditRisk) ? false : true,
        label:
            "customerInformation.customerInformation.countryOfBussinessOperation"
                .tr(),
        child: CustomMultiSelectDropdown<Country>(
            key: ValueKey(
              viewModel
                  .customerInformation?.countriesofBussinessOperation?.length,
            ),
            isEnabled: viewModel.canEdit,
            semanticLabel:
                "customerInformation.customerInformation.countryOfBussinessOperation"
                    .tr(),
            isSearchable: true,
            validationMessage: "common.validation.emptyField".tr(),
            items: viewModel.countries ?? [],
            itemBuilder: (context, item, isDisabled, isSelected) {
              return dropdownMultiItemBuildWidget(item.description,
                  isListTile: true, isSelected: isSelected);
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
                key: ValueKey(viewModel.customerInformation
                    ?.countriesofBussinessOperation?.length),
                itemBuilder: (index) {
                  final country = data[index];
                  return Container(
                margin: const EdgeInsets.only(left: 5,top: 5,bottom: 5,right: 15),
                    child: buildMultiSelectChip(
                      label: buildItemText(
                        country.description ?? '',
                        FontSizeHelper(size: FontSize.small),
                      ),
                      onDeleted: () =>
                          viewModel.onCountryBuisnessOperationDeleted(index),
                    ),
                  );
                },
              );
            },
            onSelected: (selected) {
              // delegate to VM
              viewModel.updateCountriesOfBuisnessOperation(selected);
            },
            selectedItems:
                viewModel.customerInformation?.countriesofBussinessOperation ??
                    []));
  }
}
