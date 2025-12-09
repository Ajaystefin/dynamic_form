import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:wcas_frontend/core/components/dropdown/dropdown.dart';
import 'package:wcas_frontend/core/components/label.dart';
import 'package:wcas_frontend/features/request/facilities_securities/create_security/model.dart';
import 'package:wcas_frontend/models/admin/reference.dart';

class TypeOfSecurity extends StatelessWidget {
  final CreateSecurityViewModel viewModel;
  const TypeOfSecurity({
    super.key,
    required this.viewModel,
  });
  @override
  Widget build(BuildContext context) {
    return LabelWidget(
      label: "security.createSecurity.securityDescription".tr(),
      isRequired: true,
      showLabel: true,
      child: CustomDropdown<Reference?>(
        isSearchable: true,
        validationMessage: "validation.emptyField".tr(),
        items: viewModel.securityTypes,
        isEnabled: viewModel.securityTypes.isNotEmpty,
        selectedItems: viewModel.security.securityType != null
            ? [viewModel.security.securityType]
            : [],
        onSelected: (selectedValue) async {
          await viewModel.securityTypeSelected(selectedValue.first);
        },
        itemBuilder: (context, item, isDisabled, isSelected) {
          return ListTile(
            title: Text(item?.name ?? ""),
          );
        },
        filterFn: (item, search) {
          return (item?.name ?? "")
              .toLowerCase()
              .contains(search.toLowerCase());
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
