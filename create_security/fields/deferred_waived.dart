import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';

import 'package:wcas_frontend/core/components/dropdown/dropdown.dart';
import 'package:wcas_frontend/core/components/label.dart';
import 'package:wcas_frontend/features/request/facilities_securities/create_security/model.dart';
import 'package:wcas_frontend/models/admin/reference.dart';

class DeferredWaivedBy extends StatelessWidget {
  final CreateSecurityViewModel viewModel;
  const DeferredWaivedBy({super.key, required this.viewModel});
  @override
  Widget build(BuildContext context) {
    return LabelWidget(
      label: 'security.createSecurity.deferredWaivedBy'.tr(),
      exponent: "#",
      isRequired: false,
      showLabel: true,
      child: CustomDropdown<Reference>(
        // validationMessage: "common.validation.emptyField".tr(),
        items: viewModel.securityDeferredWaivedItems,
        itemBuilder: (context, item, isDisabled, isSelected) {
          return dropdownItemBuildWidget(item.name,
              isListTile: true, isSelected: isSelected);
        },
        onSelected: (selectedValue) {
          if (selectedValue.isNotEmpty) {
            viewModel.security.deferredWaivedBy = selectedValue.first.name;
          }
        },
        filterFn: (Reference item, String filter) {
          return (item.name ?? item.toString())
              .toLowerCase()
              .contains(filter.toLowerCase());
        },
        dropdownBuilder: (context, item) =>
            dropdownBuilderWidget(text: item?.name, showToolTip: false),
      ),
    );
  }
}
