import "package:easy_localization/easy_localization.dart";
import "package:flutter/material.dart";
import "package:wcas_frontend/core/components/dropdown/model.dart";
import "package:wcas_frontend/core/components/dropdown_textbox.dart";
import "package:wcas_frontend/core/components/label.dart";
import "package:wcas_frontend/core/utils/logger.dart";
import "package:wcas_frontend/features/request/projects/link_contract/model.dart";

/// Contract value dropdown textbox field for the link contract screen.
class ContractValues extends StatelessWidget {
  /// Creates a contract value dropdown textbox field.
  const ContractValues({required this.viewModel, super.key});

  /// Link contract view model.
  final LinkContractViewModel viewModel;

  @override
  Widget build(BuildContext context) {
    return LabelWidget(
      label: "project.linkContract.contractValue".tr(),
      isRequired: true,
      child: CustomDropdownTextbox(
        options: viewModel.countryCodes
            .map(
              (ref) => CustomDropdownItem(
                value: ref.name,
                label: ref.name,
                title: ref.name,
              ),
            )
            .toList(),
        initialOption: viewModel.selectedCurrencyLabel,
        onChanged: (selectedValue) {
          logger.i("Dropdown emitted: $selectedValue");

          final currencyCode = selectedValue.keys.first;
          final amount = selectedValue.values.first;

          final selectedRef = viewModel.countryCodes.firstWhere(
            (r) => r.name == currencyCode,
            orElse: () => viewModel.countryCodes.first,
          );

          logger.i("Resolved Reference: ${selectedRef.name}");

          // - Update selected currency
          viewModel.onCurrencyChanged(selectedRef);

          // - Update contract value controller
          viewModel.contractorValueController.text = amount.toString();

          // - Trigger conversion
          viewModel.onContractValueChanged(amount.toString());
        },
      ),
    );
  }
}
