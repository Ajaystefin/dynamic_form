import "package:easy_localization/easy_localization.dart";
import "package:flutter/material.dart";
import "package:wcas_frontend/core/components/dropdown/dropdown.dart";
import "package:wcas_frontend/core/components/label.dart";
import "package:wcas_frontend/features/request/facilities_securities/create_security/model.dart";
import "package:wcas_frontend/models/admin/reference.dart";

class Emirates extends StatelessWidget {
  const Emirates({required this.viewModel, super.key});
  final CreateSecurityViewModel viewModel;
  @override
  Widget build(BuildContext context) {
    return LabelWidget(
      label: "security.createSecurity.emirates".tr(),
      isRequired: !viewModel.isFIFlow && viewModel.isCountrySecurityUAE,
      child: CustomDropdown<Reference>(
        isSearchable: true,
        isEnabled: viewModel.isCountrySecurityUAE && !viewModel.isCmoUpdate(),
        validationMessage: "common.validation.emptyRequiredField".tr(),
        items: viewModel.emiratesItems,
        selectedItems: viewModel.isCountrySecurityUAE
            ? [viewModel.security.emirates]
            : null,
        onSelected: (selectedValue) {
          viewModel.security.emirates = selectedValue.first;
        },
        itemBuilder: (context, item, isDisabled, isSelected) {
          return dropdownItemBuildWidget(
            item.name,
            isListTile: true,
            isSelected: isSelected,
          );
        },
        filterFn: (Reference item, String filter) {
          return (item.name ?? item.toString())
              .toLowerCase()
              .contains(filter.toLowerCase());
        },
        dropdownBuilder: (context, item) => viewModel.isCountrySecurityUAE
            ? dropdownBuilderWidget(text: item?.name, showToolTip: false)
            : const SizedBox.shrink(),
      ),
    );
  }
}
