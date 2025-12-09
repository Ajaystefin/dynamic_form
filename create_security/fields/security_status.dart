import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';

import 'package:wcas_frontend/core/components/dropdown/dropdown.dart';
import 'package:wcas_frontend/core/components/label.dart';
import 'package:wcas_frontend/features/request/facilities_securities/create_security/model.dart';
import 'package:wcas_frontend/models/admin/reference.dart';

class SecurityStatus extends StatelessWidget {
  final CreateSecurityViewModel viewModel;
  const SecurityStatus({super.key, required this.viewModel});
  @override
  Widget build(BuildContext context) {
    return LabelWidget(
      label: 'security.createSecurity.securityStatus'.tr(),
      exponent: "#",
      isRequired: true,
      child: CustomDropdown<Reference>(
        validationMessage: "common.validation.emptyField".tr(),
        items: viewModel.securityStatusList,
        // selectedItems: [viewModel.security?.securityStatus],
        onSelected: (selectedValue) {
          if (selectedValue.isNotEmpty) {
            viewModel.security.securityStatus = (selectedValue.first);
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
