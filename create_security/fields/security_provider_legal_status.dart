import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';

import 'package:wcas_frontend/core/components/dropdown/dropdown.dart';
import 'package:wcas_frontend/core/components/label.dart';
import 'package:wcas_frontend/core/constants/_server_constants.dart';
import 'package:wcas_frontend/features/request/facilities_securities/create_security/model.dart';
import 'package:wcas_frontend/models/admin/reference.dart';

class SecurityProviderLegalStatus extends StatelessWidget {
  final CreateSecurityViewModel viewModel;
  const SecurityProviderLegalStatus({super.key, required this.viewModel});
  @override
  Widget build(BuildContext context) {
    bool isRimProvided =
        viewModel.security.selectedIsSecurityProviderCbdCustomerValue?.id ==
            ServerConstants.optionNOid;
    return LabelWidget(
      label: 'security.createSecurity.securityProviderLegalStatus'.tr(),
      isRequired: !viewModel.isFIFlow &&
          (isRimProvided &&
              viewModel.isEntityProvider &&
              !viewModel.isCmoUpdate()),
      // ? false
      // : viewModel.isEntityProvider ||
      //     !viewModel.securityProviderCbdCustomer,
      child: CustomDropdown<Reference>(
        isSearchable: true,
        validationMessage: isRimProvided &&
                viewModel.isEntityProvider &&
                !viewModel.isCmoUpdate()
            ? "common.validation.emptyField".tr()
            : null,
        items: viewModel.securityLegalStatus,
        isEnabled: viewModel.isEntityProvider,
        //  ? false !isRimProvided
        //     ? true
        //     : viewModel.isEntityProvider && !viewModel.isCmoUpdate(),
        onSelected: (selectedValue) {
          if (selectedValue.isNotEmpty) {
            viewModel.security.securityProviderLegalStatus =
                (selectedValue.first);
          }
        },
        itemBuilder: (context, item, isDisabled, isSelected) {
          return dropdownItemBuildWidget(item.name,
              isListTile: true, isSelected: isSelected);
        },
        dropdownBuilder: (context, data) {
          return (viewModel.isEntityProvider)
              ? Text(
                  data?.name ?? "",
                  style: const TextStyle(fontSize: 14),
                )
              : const SizedBox.shrink();
        },
        selectedItems: viewModel.isEntityProvider
            ? [viewModel.security.securityProviderLegalStatus]
            : null,
      ),
    );
  }
}
