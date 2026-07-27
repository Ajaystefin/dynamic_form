import "package:easy_localization/easy_localization.dart";
import "package:flutter/material.dart";
import "package:wcas_frontend/core/components/currency/amount_field.dart";
import "package:wcas_frontend/core/components/currency/defaults.dart";
import "package:wcas_frontend/core/constants/_server_constants.dart";
import "package:wcas_frontend/core/globals.dart";
import "package:wcas_frontend/features/request/facilities_securities/create_security/model.dart";
import "package:wcas_frontend/models/admin/reference.dart";

/// Widget for displaying and managing the present security amount.
class PresentSecurityAmount extends StatelessWidget {
  /// Creates a present security amount widget.
  const PresentSecurityAmount({
    required this.viewModel,
    super.key,
  });

  /// View model containing present security amount data and actions.
  final CreateSecurityViewModel viewModel;

  @override
  Widget build(BuildContext context) {
    final formatter = NumberFormat("#,###"); // For comma formatting
    return CurrencyAmountField(
      label: viewModel.securityProviderLabel(isPresent: true),
      // isLabelEnabled: (viewModel.security.securityType?.id ==
      //         ServerConstants
      //             .securityTypeId[SecurityType.assignmentOfInsurancess]) &&
      //     (!viewModel.isParipassu),
      controller: viewModel.presentSecurityAmountController,
      readOnly: !(Globals.request?.applicationSubType ==
          ServerConstants.manualEntry),
      // filled: !((viewModel.security.securityType?.id ==
      //         ServerConstants
      //             .securityTypeId[SecurityType.assignmentOfInsurancess]) &&
      //     (!viewModel.isParipassu)),
      // readOnly: viewModel.isCmoUpdate() ||
      //     !((viewModel.security.securityType?.id ==
      //             ServerConstants.securityTypeId[
      //                 SecurityType.assignmentOfInsurancess]) &&
      //         (!viewModel.isParipassu)),
      initialValue: (viewModel.security.presentSecurityAmount == null ||
              viewModel.security.presentSecurityAmount == 0)
          ? "0"
          : formatter.format(viewModel.security.presentSecurityAmount!.toInt()),
      // No thousands-separator formatter here: onChanged below inserts the
      // commas itself by writing a formatted value back to the controller.
      inputFormatters: securityAmountFormatters(),
      hintText: "0",
      onSaved: (String? value) {
        viewModel.security.presentSecurityAmount = double.tryParse(
          value?.replaceAll(",", "") ?? "0",
        );

        viewModel.security.aedPresentSecurity = double.tryParse(
              viewModel.newPresentSecurityAmountController.text
                  .replaceAll(",", ""),
            ) ??
            double.tryParse(
              value?.replaceAll(",", "") ?? "0",
            );
      },
      onChanged: (String? value) {
        if (value != null && value.isNotEmpty) {
          final String cleaned = value.replaceAll(",", "");
          final double amount = double.tryParse(cleaned) ?? 0;

          viewModel.security.presentSecurityAmount = amount;

          // Format entered amount
          final String formatted = formatter.format(amount.toInt());
          viewModel.presentSecurityAmountController.value = TextEditingValue(
            text: formatted,
            selection: TextSelection.collapsed(offset: formatted.length),
          );

          //  Trigger conversion update
          viewModel.getCurrencyRates(
            viewModel.security.presentSecurityAmtCurrency,
            isPresentSecurityAmount: true,
          );
        }
      },
      textStyle: const TextStyle(fontSize: 14),
      // isDropdownEnabled: false,
      currencies: viewModel.currencyCodes,
      selectedCurrencies: [
        if (viewModel.currencyCodes.isNotEmpty)
          viewModel.security.presentSecurityAmtCurrency ??
              viewModel.currencyCodes.first
        else
          Reference(),
      ],
      onCurrencySelected: (Reference selected) {
        viewModel.security.presentSecurityAmtCurrency = selected;
        viewModel
          ..onCurrencyChanged(
            selected,
            isPresentSecurityAmount: true,
          )
          ..getCurrencyRates(
            selected,
            isPresentSecurityAmount: true,
          );
      },
      // Preserves this feature's plain list rows (no selection highlight).
      dropdownItemBuilder: currencyListTileItemBuilder,
    );
  }
}
