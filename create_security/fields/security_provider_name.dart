import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:wcas_frontend/core/components/dropdown/dropdown.dart';
import 'package:wcas_frontend/core/components/label.dart';
import 'package:wcas_frontend/core/components/textfield.dart';
import 'package:wcas_frontend/core/utils/validators.dart';
import 'package:wcas_frontend/features/request/facilities_securities/create_security/model.dart';
import 'package:wcas_frontend/models/admin/reference.dart';

class SecurityProviderName extends StatelessWidget {
  final CreateSecurityViewModel viewModel;
  const SecurityProviderName({super.key, required this.viewModel});

  @override
  Widget build(BuildContext context) {
    return LabelWidget(
      label: viewModel.bankGuarantorFieldLabel() +
          'security.createSecurity.securityProviderName'.tr(),
      isRequired: viewModel.securityProviderCbdCustomer,
      child: (viewModel.security.securityType?.id == 79 &&
              !viewModel.securityProviderCbdCustomer)
          ? CustomDropdown<Reference?>(
              isSearchable: true,
              validationMessage:viewModel.securityProviderCbdCustomer? "validation.emptyField".tr():null,
              items: viewModel.bankNames,
              isEnabled: viewModel.bankNames.isNotEmpty,
              // selectedItems: viewModel.security.bankNmae != null
              //     ? [viewModel.security.bankNmae]
              //     : [],
              onSelected: (selectedValue) async {
                viewModel.security.securityProvidedName =
                    selectedValue.first?.name;
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
            )
          : CustomTextField(
              maxLength: 50,
              counterText: '',
              controller: viewModel.securityProviderNameController,
              hintText: viewModel.security.securityProvidedName,
              readOnly: !viewModel.securityProviderCbdCustomer,
              filled: !viewModel.securityProviderCbdCustomer,
              validator: !viewModel.securityProviderCbdCustomer
                  ? null
                  : CustomValidator.requiredField,
              onSaved: (String? value) {
                viewModel.security.securityProvidedName = value;
              },
            ),
    );
  }
}
