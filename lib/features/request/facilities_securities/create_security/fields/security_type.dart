import "package:easy_localization/easy_localization.dart";
import "package:flutter/material.dart";
import "package:wcas_frontend/core/components/dropdown/dropdown.dart";
import "package:wcas_frontend/core/components/label.dart";
import "package:wcas_frontend/core/components/textfield.dart";
import "package:wcas_frontend/core/constants/_server_constants.dart";
import "package:wcas_frontend/features/request/facilities_securities/create_security/model.dart";
import "package:wcas_frontend/models/admin/reference.dart";

class TypeOfSecurity extends StatelessWidget {
  const TypeOfSecurity({
    required this.viewModel,
    super.key,
  });
  final CreateSecurityViewModel viewModel;
  @override
  Widget build(BuildContext context) {
    return LabelWidget(
      label: "security.createSecurity.securityDescription".tr(),
      isRequired: true,
      child: viewModel.security.securityGroup?.id ==
              ServerConstants.fiOtherSecurityGroupId
          ? CustomTextField(
              initialValue: viewModel.security.securityType?.name ?? "",
              readOnly: viewModel.isCmoUpdate(),
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return "validation.emptyField".tr();
                }
                return null;
              },
              onChanged: (value) {
                viewModel.onSecurityTypeTextChanged(value);
              },
              onSaved: (value) {
                viewModel.onSecurityTypeTextChanged(value ?? "");
              },
              maxLength: 100,
            )
          : CustomDropdown<Reference?>(
              isSearchable: true,
              validationMessage: "validation.emptyField".tr(),
              items: viewModel.securityTypes,
              isEnabled: viewModel.securityTypes.isNotEmpty &&
                  !viewModel.isCmoUpdate(),
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
