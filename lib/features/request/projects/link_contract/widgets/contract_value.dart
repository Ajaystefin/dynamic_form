import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:wcas_frontend/core/components/dropdown/model.dart';
import 'package:wcas_frontend/core/components/dropdown_textbox.dart';
import 'package:wcas_frontend/core/components/label.dart';
import 'package:wcas_frontend/features/request/projects/link_contract/model.dart';

class ContractValue extends StatelessWidget {
  final LinkContractViewModel viewModel;
  const ContractValue({super.key, required this.viewModel});

  @override
  Widget build(BuildContext context) {
    return LabelWidget(
      label: 'project.linkContract.contractValue'.tr(),
      isRequired: true,
      child: CustomDropdownTextbox(
          options: viewModel.safeCountryCodes
              .map((ref) => CustomDropdownItem(
                    value: ref.name,
                    label: ref.name,
                    title: ref.name,
                  ))
              .toList(),
          initialOption: viewModel.selectedCurrencyLabel,
          onChanged: (selectedValue) {
            debugPrint('Dropdown emitted: $selectedValue');

            final currencyCode = selectedValue.keys.first;
            final amount = selectedValue.values.first;

            final selectedRef = viewModel.safeCountryCodes.firstWhere(
              (r) => r.name == currencyCode,
              orElse: () => viewModel.safeCountryCodes.first,
            );

            debugPrint('Resolved Reference: ${selectedRef.name}');

            // ✅ Update selected currency
            viewModel.onCurrencyChanged(selectedRef);

            // ✅ Update contract value controller
            viewModel.contractorValueController.text = amount.toString();

            // ✅ Trigger conversion
            viewModel.onContractValueChanged(amount.toString());
          }),
    );
  }
}
