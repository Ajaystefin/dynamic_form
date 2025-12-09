import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:wcas_frontend/core/components/dropdown/dropdown.dart';
import 'package:wcas_frontend/core/components/label.dart';
import 'package:wcas_frontend/features/request/facilities_securities/create_security/model.dart';
import 'package:wcas_frontend/models/admin/reference.dart';

class SecurityHeldBy extends StatelessWidget {
  final CreateSecurityViewModel viewModel;
  const SecurityHeldBy({super.key, required this.viewModel});
  @override
  Widget build(BuildContext context) {
    return LabelWidget(
      isRequired: true,
      label: 'security.createSecurity.securityHeldBy'.tr(),
      child: CustomDropdown<Reference>(
        validationMessage: "validation.emptyField".tr(),
        items: viewModel.securityHeldAsList,
        selectedItems: [
          viewModel.securityHeldAsList.firstWhere(
              (item) => item.id == viewModel.security.securityHeldAs?.id,
              orElse: () => viewModel.securityHeldAsList.first)
        ],
        onSelected: (selectedValue) {
          if (selectedValue.isNotEmpty) {
            viewModel.security.securityHeldAs = (selectedValue.first);
          }
        },
        itemBuilder: (context, item, isDisabled, isSelected) {
          return dropdownItemBuildWidget(item.name,
              isListTile: true, isSelected: isSelected);
        },
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
