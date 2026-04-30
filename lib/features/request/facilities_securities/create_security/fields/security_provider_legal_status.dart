import "package:easy_localization/easy_localization.dart";
import "package:flutter/material.dart";
import "package:wcas_frontend/core/components/dropdown/dropdown.dart";
import "package:wcas_frontend/core/components/label.dart";
import "package:wcas_frontend/core/constants/_server_constants.dart";
import "package:wcas_frontend/features/request/facilities_securities/create_security/model.dart";
import "package:wcas_frontend/models/admin/reference.dart";

class SecurityProviderLegalStatus extends StatelessWidget {
  const SecurityProviderLegalStatus({required this.viewModel, super.key});
  final CreateSecurityViewModel viewModel;
  @override
  Widget build(BuildContext context) {
    final bool isRimProvided =
        viewModel.security.selectedIsSecurityProviderCbdCustomerValue?.id ==
            ServerConstants.optionNOid;
    return LabelWidget(
      isEnabled: !viewModel.isCmoUpdate(),
      label: "security.createSecurity.securityProviderLegalStatus".tr(),
      isRequired: viewModel.isEntityProvider || isRimProvided,

      //   ||  (!viewModel.isFIFlow && isRimProvided &&
      // !viewModel.isCmoUpdate()),
      // ? false
      // : viewModel.isEntityProvider ||
      //     !viewModel.securityProviderCbdCustomer,
      child: CustomDropdown<Reference>(
        isSearchable: true,
        validationMessage: viewModel.isEntityProvider || isRimProvided
            // || (isRimProvided && !viewModel.isCmoUpdate())
            ? "common.validation.emptyField".tr()
            : null,
        items: viewModel.securityLegalStatus,
        isEnabled: viewModel.isEntityProvider,
        //  ? false !isRimProvided
        //     ? true
        //     : viewModel.isEntityProvider && !viewModel.isCmoUpdate(),
        onSelected: (selectedValue) {
          viewModel.security.securityProviderLegalStatus =
              (selectedValue.first);
        },
        itemBuilder: (context, item, isDisabled, isSelected) {
          return dropdownItemBuildWidget(
            item.name,
            isListTile: true,
            isSelected: isSelected,
          );
        },
        dropdownBuilder: (context, data) {
          return viewModel.isEntityProvider
              ? dropdownBuilderWidget(text: data?.name)
              : const SizedBox.shrink();
        },

        selectedItems: [
          if (viewModel.isEntityProvider &&
              viewModel.security.securityProviderLegalStatus != null &&
              (viewModel.security.securityProviderLegalStatus?.name ?? "")
                  .trim()
                  .isNotEmpty)
            viewModel.security.securityProviderLegalStatus,
        ],
      ),
    );
  }
}
