import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:wcas_frontend/core/components/dropdown/dropdown.dart';
import 'package:wcas_frontend/core/components/label.dart';
import 'package:wcas_frontend/core/components/textfield.dart';
import 'package:wcas_frontend/core/constants/_server_constants.dart';
import 'package:wcas_frontend/core/utils/scale.dart';
import 'package:wcas_frontend/core/utils/utils.dart';
import 'package:wcas_frontend/features/request/facilities_securities/create_security/model.dart';
import 'package:wcas_frontend/models/admin/reference.dart';

class PresentSecurityAmount extends StatelessWidget {
  final CreateSecurityViewModel viewModel;
  const PresentSecurityAmount({super.key, required this.viewModel});

  @override
  @override
  Widget build(BuildContext context) {
    final formatter = NumberFormat('#,###'); // For comma formatting
    return LabelWidget(
      label: viewModel.securityProviderLabel(isPresent: true),
      isEnabled: (viewModel.security.securityType?.id ==
              ServerConstants
                  .securityTypeId[SecurityType.assignmentOfInsurancess]) &&
          (viewModel.isParipassu == false),
      child: CustomTextField(
        filled: !((viewModel.security.securityType?.id ==
                ServerConstants
                    .securityTypeId[SecurityType.assignmentOfInsurancess]) &&
            (viewModel.isParipassu == false)),
        readOnly: viewModel.isCmoUpdate() ||
            !((viewModel.security.securityType?.id ==
                    ServerConstants.securityTypeId[
                        SecurityType.assignmentOfInsurancess]) &&
                (viewModel.isParipassu == false)),
        initialValue: viewModel.security.presentSecurityAmount?.toString(),
        hintText: '0',
        onSaved: (String? value) {
          viewModel.security.presentSecurityAmount =
              double.tryParse(value.toString());
        },
        onChanged: (String? value) {
          if (value != null && value.isNotEmpty) {
            String cleaned = value.replaceAll(',', '');
            double amount = double.tryParse(cleaned) ?? 0;

            viewModel.security.presentSecurityAmount = amount;

            // Format entered amount
            String formatted = formatter.format(amount.toInt());
            viewModel.presentSecurityAmountController.value = TextEditingValue(
              text: formatted,
              selection: TextSelection.collapsed(offset: formatted.length),
            );

            //  Trigger conversion update
            viewModel.getCurrencyRates(
                viewModel.security.presentSecurityAmtCurrency, true);
          }
        },
        textStyle: const TextStyle(fontSize: 14),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
        prefixIcon: CustomDropdown<Reference>(
          width: 70.w,
          height: null,
          validationMessage: "validation.emptyField".tr(),
          items: viewModel.currencyCodes,
          selectedItems: [
            viewModel.currencyCodes.isNotEmpty
                ? viewModel.security.presentSecurityAmtCurrency ??
                    viewModel.currencyCodes.first
                : Reference()
          ],
          onSelected: (selectedValue) {
            if (selectedValue.isNotEmpty) {
              viewModel.security.presentSecurityAmtCurrency =
                  selectedValue.first;
              viewModel.onCurrencyChanged(selectedValue.first, true);
              viewModel.getCurrencyRates(selectedValue.first, true);
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
      ),
    );
  }
}
