import "package:easy_localization/easy_localization.dart";
import "package:flutter/material.dart";
import "package:wcas_frontend/core/components/ccsys_tooltip.dart";
import "package:wcas_frontend/core/components/dropdown/multi_select_dropdown.dart";
import "package:wcas_frontend/core/components/label.dart";
import "package:wcas_frontend/features/request/ccsys/customer_information/model.dart";
import "package:wcas_frontend/models/admin/reference.dart";

/// Displays the country risk fund utilization multi-select field.
class CountryRisk extends StatelessWidget {
  /// Creates the country risk fund utilization field widget.
  CountryRisk(this.viewModel, {super.key});

  /// View model used to manage country risk fund utilization selections.
  final CustomerInformationViewModel viewModel;

  /// Scroll controller used by the selected country chips list.
  final ScrollController contrlr = ScrollController();

  @override
  Widget build(BuildContext context) {
    return CcsysTootltip(
      message:
          "ccsys.customerInformation.tooltip.countryFundsUtilizationTooltip"
              .tr(),
      child: LabelWidget(
        label: "ccsys.customerInformation.CountryFundsUtilization".tr(),
        customTooltip: true,
        child: CustomMultiSelectDropdown<Reference>(
          isEnabled: viewModel.canEdit,
          filterFn: (Reference item, String filter) {
            return (item.name ?? item.toString())
                .toLowerCase()
                .contains(filter.toLowerCase());
          },
          key: ValueKey(
            viewModel.customerInformation.countryOfRiskFundUtilization?.length,
          ),
          // semanticLabel: 'customerInformation.customerInformation.tooltip.countryFundsUtilizationTooltip'.tr(),
          isSearchable: true,
          // validationMessage: "common.validation.emptyField".tr(),
          items: viewModel.ccsysCountryList,
          itemBuilder: (context, item, {isDisabled, isSelected}) {
            return dropdownMultiItemBuildWidget(
              item.name,
              isSelected: isSelected ?? false,
            );
          },
          dropdownBuilder: (context, data) {
            return multiSelectDropDownBuilderWidget(
              data: data!,
              controller: contrlr,
              key: ValueKey(
                viewModel
                    .customerInformation.countryOfRiskFundUtilization?.length,
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
                      country.name ?? "",
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
          selectedItems:
              viewModel.customerInformation.countryOfRiskFundUtilization ?? [],
        ),
      ),
    );
  }
}
