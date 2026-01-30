import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';

import 'package:wcas_frontend/core/components/dropdown/dropdown.dart';
import 'package:wcas_frontend/core/components/label.dart';
import 'package:wcas_frontend/core/constants/_server_constants.dart';
import 'package:wcas_frontend/features/request/facilities_securities/create_security/model.dart';
import 'package:wcas_frontend/models/request/country.dart';

class SecurityProviderNationality extends StatelessWidget {
  final CreateSecurityViewModel viewModel;
  const SecurityProviderNationality({super.key, required this.viewModel});
  @override
  Widget build(BuildContext context) {
    bool isRequiredRim =
        viewModel.security.selectedIsSecurityProviderCbdCustomerValue?.id ==
            ServerConstants.optionYESid;
    return LabelWidget(
      isRequired: !viewModel.isFIFlow &&
          (isRequiredRim ? false : !viewModel.isEntityProvider),
      label: 'security.createSecurity.securityProviderNationality'.tr(),
      child: CustomDropdown<Country>(
        isEnabled: !viewModel.isEntityProvider && !viewModel.isCmoUpdate(),
        isSearchable: true,
        validationMessage:
            viewModel.security.selectedIsSecurityProviderCbdCustomerValue?.id ==
                    ServerConstants.optionYESid
                ? null
                : !viewModel.isEntityProvider
                    ? "common.validation.emptyRequiredField".tr()
                    : null,
        items: viewModel.countries,
        selectedItems: viewModel.isEntityProvider
            ? <Country>[
                if ((viewModel.security.securityProviderNationality ?? '')
                    .trim()
                    .isNotEmpty)
                  viewModel.countries.firstWhere(
                    (c) =>
                        (c.code ?? '').trim().toLowerCase() ==
                        (viewModel.security.securityProviderNationality ?? '')
                            .trim()
                            .toLowerCase(),
                    orElse: () => Country(),
                  ),
              ]
            : [
                Country(
                    description: viewModel.security.securityProviderNationality)
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
        itemBuilder: (context, item, isDisabled, isSelected) {
          return dropdownItemBuildWidget(item.description,
              isListTile: true, isSelected: isSelected);
        },
        dropdownBuilder: (context, data) {
          return (viewModel.isEntityProvider)
              ? const SizedBox.shrink()
              : Text(
                  data?.description ?? "",
                  style: const TextStyle(fontSize: 14),
                );
        },
      ),
    );
  }
}
