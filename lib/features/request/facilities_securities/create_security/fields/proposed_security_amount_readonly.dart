import "package:easy_localization/easy_localization.dart";
import "package:flutter/material.dart";
import "package:flutter/services.dart";
import "package:wcas_frontend/core/components/dropdown/dropdown.dart";
import "package:wcas_frontend/core/components/textfield.dart";
import "package:wcas_frontend/core/constants/_server_constants.dart";
import "package:wcas_frontend/core/utils/scale.dart";
import "package:wcas_frontend/features/request/facilities_securities/create_security/model.dart";
import "package:wcas_frontend/models/admin/reference.dart";

class ProposedSecurityAmountReadOnly extends StatelessWidget {
  const ProposedSecurityAmountReadOnly({required this.viewModel, super.key});
  final CreateSecurityViewModel viewModel;

  @override
  Widget build(BuildContext context) {
    return CustomTextField(
      prefixIcon: CustomDropdown<Reference>(
        isEnabled: false,
        width: 70.w,
        height: null,
        validationMessage: "validation.emptyField".tr(),
        items: viewModel.currencyCodes,
        selectedItems: [
          viewModel.currencyCodes
              .where((code) => code.name == ServerConstants.aedCurrency)
              .first,
        ],
        itemBuilder: (context, item, isDisabled, isSelected) {
          return ListTile(title: Text(item.name ?? ""));
        },
        dropdownBuilder: (context, data) {
          return Text(
            data?.name ?? "",
            style: const TextStyle(fontSize: 12),
          );
        },
      ),
      controller: viewModel.newProposedSecurityAmountController,
      readOnly: true,
      filled: true,
      initialValue: "0",
      inputFormatters: [
        LengthLimitingTextInputFormatter(12),
        FilteringTextInputFormatter.digitsOnly,
      ],
    );
  }
}
