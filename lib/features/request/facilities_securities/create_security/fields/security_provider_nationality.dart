import "package:easy_localization/easy_localization.dart";
import "package:flutter/material.dart";
import "package:wcas_frontend/core/components/dropdown/dropdown.dart";
import "package:wcas_frontend/core/components/label.dart";
import "package:wcas_frontend/core/constants/_server_constants.dart";
import "package:wcas_frontend/features/request/facilities_securities/create_security/model.dart";
import "package:wcas_frontend/models/request/country.dart";

/// Widget for displaying and managing the security provider nationality.
class SecurityProviderNationality extends StatelessWidget {
  /// Creates a security provider nationality widget.
  const SecurityProviderNationality({
    required this.viewModel,
    super.key,
  });

  /// View model containing security provider nationality data and actions.
  final CreateSecurityViewModel viewModel;

  @override
  Widget build(BuildContext context) {
    final bool isCbdCustomer =
        (viewModel.security.selectedIsSecurityProviderCbdCustomerValue?.id ??
                ServerConstants.optionYESid) ==
            ServerConstants.optionYESid;
    final bool isRequired = !viewModel.isFIFlow &&
        !isCbdCustomer &&
        viewModel.isNaturalPersonProvider;
    return LabelWidget(
      isRequired: isRequired,
      isEnabled: !viewModel.isCmoUpdate(),
      label: "security.createSecurity.securityProviderNationality".tr(),
      child: CustomDropdown<Country>(
        isEnabled: viewModel.isNaturalPersonProvider,
        isSearchable: true,
        validationMessage:
            isRequired ? "common.validation.emptyRequiredField".tr() : null,
        items: viewModel.countries,
        selectedItems:

            // viewModel.isNaturalPersonProvider
            //     ? <Country>[
            //         if ((viewModel.security.securityProviderNationality ??
            // '').trim().isNotEmpty)
            //           viewModel.countries.firstWhere(
            //             (c) =>
            //                 (c.code ?? '').trim().toLowerCase() ==
            //                 (viewModel.security.securityProviderNationality
            // ?? '').trim().toLowerCase(),
            //             orElse: Country.new,
            //           ),
            //       ]
            //     :

            <Country>[
          // Only include a Country if there's an actual value
          if ((viewModel.security.securityProviderNationality ?? "")
              .trim()
              .isNotEmpty)
            Country(
              description: viewModel.security.securityProviderNationality,
            ),
        ],
        onSelected: (selectedValue) {
          if (selectedValue.isNotEmpty) {
            viewModel.security.securityProviderNationality =
                selectedValue.first.description;
          }
        },
        filterFn: (country, filter) {
          return country.description!
              .toLowerCase()
              .contains(filter.toLowerCase());
        },
        itemBuilder: (context, item, {isDisabled, isSelected}) {
          return dropdownItemBuildWidget(
            item.description,
            isSelected: isSelected ?? false,
          );
        },
        dropdownBuilder: (context, data) {
          return (viewModel.isNaturalPersonProvider)
              ? dropdownBuilderWidget(text: data?.description)
              : const SizedBox.shrink();
        },
      ),
    );
  }
}
