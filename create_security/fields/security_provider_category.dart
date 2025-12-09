import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:wcas_frontend/core/components/dropdown/dropdown.dart';
import 'package:wcas_frontend/core/components/label.dart';
import 'package:wcas_frontend/features/request/facilities_securities/create_security/model.dart';
import 'package:wcas_frontend/models/admin/reference.dart';

class SecurityProviderCategory extends StatelessWidget {
  final CreateSecurityViewModel viewModel;
  const SecurityProviderCategory({super.key, required this.viewModel});
  @override
  Widget build(BuildContext context) {
    return LabelWidget(
      label: 'security.createSecurity.securityProviderCategory'.tr(),
      isRequired: viewModel.securityProviderCbdCustomer,
      child: CustomDropdown<Reference>(
        items: viewModel.securityProvidedCategories,
        // selectedItems: [viewModel.security.],

        onSelected: (selectedValue) {
          viewModel.changeSecurityProviderCategory(selectedValue.first);
        },

        itemBuilder: (context, item, isDisabled, isSelected) {
          return dropdownItemBuildWidget(item.name,
              isListTile: true, isSelected: isSelected);
        },
        validationMessage:  viewModel.securityProviderCbdCustomer?'common.validation.emptyRequiredField'.tr():null,
        dropdownBuilder: (context, data) {
          return Text(
            data?.name ?? "",
            style: const TextStyle(fontSize: 14),
          );
        },
      ),
    );
  }
}
