import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:wcas_frontend/core/components/dropdown/dropdown.dart';
import 'package:wcas_frontend/core/components/dropdown/multi_select_dropdown.dart';
import 'package:wcas_frontend/core/components/label.dart';
import 'package:wcas_frontend/features/request/facilities_securities/create_facility/model.dart';
import 'package:wcas_frontend/models/request/country.dart';

class FacilityCountryOfRisk extends StatelessWidget {
  final CreateFacilityViewModel viewModel;
  const FacilityCountryOfRisk({super.key, required this.viewModel});
  @override
  Widget build(BuildContext context) {
    return LabelWidget(
      label: 'facilities.createFacility.countryOfRisk'.tr(),
      isRequired: !viewModel.showFacilityFi,
      child: CustomDropdown<Country>(
        isSearchable: true,
        filterFn: (Country item, String filter) {
          return (item.description ?? item.toString())
              .toLowerCase()
              .contains(filter.toLowerCase());
        },
        validationMessage:
            !viewModel.showFacilityFi ? "validation.emptyField".tr() : null,
        semanticLabel: 'facilities.createFacility.countryOfRisk'.tr(),
        items: viewModel.countryList,
        // selectedItems: [
        //   viewModel.facility.selectedCountry ??
        //       Country(description: "United Arab Emirates")
        // ],
        // onSelected: (selectedValue) {
        //   if (selectedValue.isNotEmpty) {
        //     viewModel.facility.selectedCountry = selectedValue.first;
        //   }
        // },

        selectedItems: [
          viewModel.facility.selectedCountry ??
              (() {
                final apiValue = (viewModel.facility.countryOfRisk ??
                        (viewModel.facilityDetail.isNotEmpty
                            ? viewModel.facilityDetail.first.countryOfRisk
                            : null))
                    ?.trim();
                final effective = (apiValue == null || apiValue.isEmpty)
                    ? "United Arab Emirates"
                    : apiValue;
                return (viewModel.countryList?.isNotEmpty ?? false)
                    ? viewModel.countryList!.firstWhere(
                        (c) =>
                            (c.description ?? '').trim().toLowerCase() ==
                            effective.toLowerCase(),
                        orElse: () => Country(description: effective),
                      )
                    : Country(description: effective);
              })(),
        ],

        onSelected: (selectedValue) {
          if (selectedValue.isNotEmpty) {
            viewModel.onCountryOfRiskSelected(selectedValue.first);
          }
        },

        itemBuilder: (context, item, isDisabled, isSelected) {
          return dropdownMultiItemBuildWidget(
            item.description,
            isSelected: isSelected,
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
