import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:wcas_frontend/core/components/dropdown/dropdown.dart';

import 'package:wcas_frontend/core/components/label.dart';
import 'package:wcas_frontend/core/components/textfield.dart';
import 'package:wcas_frontend/core/utils/scale.dart';
import 'package:wcas_frontend/features/request/facilities_securities/create_security/model.dart';
import 'package:wcas_frontend/models/admin/reference.dart';

class ProposedSecurityAmount extends StatelessWidget {
  final CreateSecurityViewModel viewModel;
  const ProposedSecurityAmount({super.key, required this.viewModel});

  @override
  Widget build(BuildContext context) {
    final formatter = NumberFormat('#,###'); // For comma formatting

    return LabelWidget(
      isRequired: true,
      label: viewModel.securityProviderLabel(isPresent: false),
      child: CustomTextField(
        controller: viewModel.proposedSecurityAmountController,
        readOnly: viewModel.security.securityType?.id == 77,
        filled: viewModel.security.securityType?.id == 77,
        prefixIcon: CustomDropdown<Reference>(
          width: 70.w,
          height: null,
          isEnabled: viewModel.security.securityType?.id != 77,
          validationMessage: "validation.emptyField".tr(),
          items: viewModel.currencyCodes,
          selectedItems: [
            viewModel.currencyCodes.isNotEmpty
                ? (viewModel.security.proposedSecurityAmtCurrency ??
                    viewModel.currencyCodes.first)
                : Reference()
          ],
          onSelected: (selectedValue) {
            if (selectedValue.isNotEmpty) {
              viewModel.onCurrencyChanged(selectedValue.first);
              viewModel.getCurrencyRates(selectedValue.first);
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
        initialValue: "0",
        inputFormatters: [
          LengthLimitingTextInputFormatter(12),
          FilteringTextInputFormatter.digitsOnly,
        ],
        onChanged: (String? value) {
          if (value != null && value.isNotEmpty) {
            String cleaned = value.replaceAll(',', '');
            double amount = double.tryParse(cleaned) ?? 0;

            viewModel.security.proposedSecurityAmount = amount;

            // Format entered amount
            String formatted = formatter.format(amount.toInt());
            viewModel.proposedSecurityAmountController.value = TextEditingValue(
              text: formatted,
              selection: TextSelection.collapsed(offset: formatted.length),
            );

            //  Trigger conversion update
            viewModel.getCurrencyRates(
                viewModel.security.proposedSecurityAmtCurrency);
          }
        },
        hintText: '0',
        onSaved: (String? value) {
          viewModel.security.proposedSecurityAmount =
              double.tryParse(value.toString());
        },
      ),
    );
  }
}
