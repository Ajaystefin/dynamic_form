import "package:easy_localization/easy_localization.dart";
import "package:flutter/material.dart";
import "package:wcas_frontend/core/components/dropdown/dropdown.dart";
import "package:wcas_frontend/core/components/label.dart";
// import "package:wcas_frontend/core/components/textfield.dart";
// import "package:wcas_frontend/core/utils/validators.dart";
import "package:wcas_frontend/features/request/customer_information/customer_info/model.dart";
import "package:wcas_frontend/models/request/country.dart";

/// Country of incorporation field for the customer information screen.
class CountryOfIncoporationField extends StatelessWidget {
  /// Creates a country of incorporation field.
  const CountryOfIncoporationField({required this.viewModel, super.key});

  /// Customer information view model.
  final CustomerInfoViewModel viewModel;

  @override
  Widget build(BuildContext context) {
    // final String initialValue =
    //     viewModel.customerInformation?.incorporateCountry ?? "";
    // final bool isValid = initialValue.trim().isNotEmpty;

    /// Rule:
    /// - If page is not editable => readOnly
    /// - If trade license came from backend => readOnly
    /// - If trade license came from draft => editable
    /// - If empty => editable
    final bool isManual = viewModel.isManualEntry;
    final bool readOnly = !viewModel.canEdit ||
        viewModel.countryOfIncorporateSource ==
            CountryOfIncorporateSource.backend;

    return LabelWidget(
      isRequired: !viewModel.isFI,
      label:
          "customerInformation.customerInformation.countryOfIncorporation".tr(),
      child: CustomDropdown<Country>(
        isSearchable: true,
        key: const ValueKey("countryOfIncorporation"),
        semanticLabel:
            "customerInformation.customerInformation.countryOfIncorporation"
                .tr(),
        isEnabled: isManual || !readOnly,
        validationMessage:
            viewModel.isFI ? null : "common.validation.emptyField".tr(),
        items: viewModel.countries ?? [],
        itemBuilder: (context, item, {isDisabled, isSelected}) {
          return dropdownItemBuildWidget(
            item.description,
            isSelected: isSelected ?? false,
          );
        },
        filterFn: (Country item, String filter) {
          return (item.description ?? item.toString())
              .toLowerCase()
              .contains(filter.toLowerCase());
        },
        onSelected: (selectedValue) {
          if (!readOnly) {
            viewModel.customerInformation?.incorporateCountry =
                selectedValue[0].description;
            viewModel.selectedCountryOfIncorporate = selectedValue.first;
          }
        },
        dropdownBuilder: (context, item) =>
            dropdownBuilderWidget(text: item?.description),
        selectedItems: viewModel.selectedCountryOfIncorporate != null
            ? [viewModel.selectedCountryOfIncorporate]
            : null,
      ),
    );
  }
}
