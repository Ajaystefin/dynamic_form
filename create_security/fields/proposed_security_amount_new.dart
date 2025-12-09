import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:wcas_frontend/core/components/dropdown/dropdown.dart';
import 'package:wcas_frontend/core/components/textfield.dart';
import 'package:wcas_frontend/core/constants/_server_constants.dart';
import 'package:wcas_frontend/core/utils/scale.dart';
import 'package:wcas_frontend/features/request/facilities_securities/create_security/model.dart';
import 'package:wcas_frontend/models/admin/reference.dart';

class ProposedSecurityAmountNew extends StatelessWidget {
  final CreateSecurityViewModel viewModel;
  const ProposedSecurityAmountNew({super.key, required this.viewModel});

  @override
  Widget build(BuildContext context) {
    final formatter = NumberFormat('#,###'); // For comma formatting
    // Move cursor to the end

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
              .first
        ],
        onSelected: (selectedValue) {
          if (selectedValue.isNotEmpty) {
            final ref = selectedValue.first;

            viewModel.onCurrencyChanged(ref);
          }
        },
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
      initialValue: '0',
      inputFormatters: [
        LengthLimitingTextInputFormatter(12),
        FilteringTextInputFormatter.digitsOnly,
      ],
      onChanged: (String? value) {
        if (value != null && value.isNotEmpty) {
          // Remove commas for parsing
          String cleaned = value.replaceAll(',', '');
          // Update model with raw number
          viewModel.security.proposedSecurityAmount = double.tryParse(cleaned);

          // Format for display
          String formatted = formatter.format(int.parse(cleaned));
          viewModel.proposedSecurityAmountController.value = TextEditingValue(
            text: formatted,
            selection: TextSelection.collapsed(offset: formatted.length),
          );
        }
      },
      onSaved: (String? value) {
        viewModel.security.proposedSecurityAmount =
            double.tryParse(value.toString());
      },
    );
  }
}
