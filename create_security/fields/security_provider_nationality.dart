import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';

import 'package:wcas_frontend/core/components/dropdown/dropdown.dart';
import 'package:wcas_frontend/core/components/label.dart';
import 'package:wcas_frontend/features/request/facilities_securities/create_security/model.dart';
import 'package:wcas_frontend/models/request/country.dart';

class SecurityProviderNationality extends StatelessWidget {
  final CreateSecurityViewModel viewModel;
  const SecurityProviderNationality({super.key, required this.viewModel});
  @override
  Widget build(BuildContext context) {
    return LabelWidget(
      isRequired: !viewModel.isEntityProvider,
      label: 'security.createSecurity.securityProviderNationality'.tr(),
      child: CustomDropdown<Country>(
        isEnabled: !viewModel.isEntityProvider,
        isSearchable: true,
        validationMessage: "common.validation.emptyField".tr(),
        items: viewModel.countries,
        // selectedItems: [viewModel.security.securityStatusValue],
        onSelected: (selectedValue) {
          if (selectedValue.isNotEmpty) {
            viewModel.security.securityProviderNationality =
                (selectedValue.first);
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
          return Text(
            data?.description ?? "",
            style: const TextStyle(fontSize: 14),
          );
        },
      ),
    );
  }
}
