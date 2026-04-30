import "package:easy_localization/easy_localization.dart";
import "package:flutter/material.dart";
import "package:wcas_frontend/core/components/dropdown/dropdown.dart";
import "package:wcas_frontend/core/components/label.dart";
import "package:wcas_frontend/core/components/textfield.dart";
import "package:wcas_frontend/core/constants/_server_constants.dart";
import "package:wcas_frontend/core/utils/scale.dart";
import "package:wcas_frontend/core/utils/validators.dart";
import "package:wcas_frontend/features/request/projects/edit_contract/model.dart";
import "package:wcas_frontend/models/admin/reference.dart";

class InitialContractValue extends StatelessWidget {
  const InitialContractValue({required this.viewModel, super.key});
  final EditContractViewModel viewModel;

  @override
  Widget build(BuildContext context) {
    final items = viewModel.countryCodes;
    final Reference selectedItem = Reference(
      name: ServerConstants.aedCurrency,
    ); //  viewModel.selectedContractValueCurrency;
    return LabelWidget(
      label: "project.viewEditContractDetails.initialContractValue".tr(),
      isRequired: true,
      child: Column(
        children: [
          CustomTextField(
            readOnly: true,
            filled: true,
            semanticLabel:
                "project.viewEditContractDetails.initialContractValue".tr(),
            prefixIcon: CustomDropdown<Reference>(
              isEnabled: false,
              width: 70.w,
              height: null,
              validationMessage: "validation.emptyField".tr(),
              items: items,
              selectedItems: [selectedItem],
              onSelected: (selectedValue) {
                if (selectedValue.isNotEmpty) {
                  viewModel.onCurrencyChanged(selectedValue.first);
                  viewModel.getCurrencyRates(selectedValue.first);
                }
              },
              itemBuilder: (context, item, isDisabled, isSelected) {
                return ListTile(
                  title: Text(item.name ?? ""),
                );
              },
              dropdownBuilder: (context, data) {
                return Text(
                  data?.name ?? "",
                  style: const TextStyle(fontSize: 12),
                );
              },
            ),
            // controller: viewModel.contractorValueController,
            initialValue: viewModel.contract.initialContractValue.toString(),
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            inputFormatters: [
              DecimalInputFormatter(
                regEx: RegExp(r"^[0-9,]{0,21}(\.\d{0,6})?$"),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
