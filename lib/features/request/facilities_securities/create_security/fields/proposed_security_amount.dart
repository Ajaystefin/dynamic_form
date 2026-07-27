import "package:easy_localization/easy_localization.dart";
import "package:flutter/material.dart";
import "package:wcas_frontend/core/components/currency/amount_field.dart";
import "package:wcas_frontend/core/components/currency/defaults.dart";
import "package:wcas_frontend/core/constants/_server_constants.dart";
import "package:wcas_frontend/core/utils/utils.dart";
import "package:wcas_frontend/features/request/facilities_securities/create_security/model.dart";
import "package:wcas_frontend/models/admin/reference.dart";

/// Widget for displaying and managing the proposed security amount.
class ProposedSecurityAmount extends StatelessWidget {
  /// Creates a proposed security amount widget.
  const ProposedSecurityAmount({
    required this.viewModel,
    super.key,
  });

  /// View model containing proposed security amount data and actions.
  final CreateSecurityViewModel viewModel;

  @override
  Widget build(BuildContext context) {
    final formatter = NumberFormat("#,###"); // For comma formatting

    return CurrencyAmountField(
      isLabelRequired: true,
      isLabelEnabled:
          // Disabled for Receivables
          (viewModel.security.securityType?.id !=
                  ServerConstants
                      .securityTypeId[SecurityType.assignmentOfReceivables])
              // Enabled for Insurances only when Pari-passu is false; otherwise
              // enabled for other types by default
              &&
              (viewModel.security.securityType?.id !=
                      ServerConstants.securityTypeId[
                          SecurityType.assignmentOfInsurancess] ||
                  !viewModel.isParipassu),
      label: viewModel.securityProviderLabel(isPresent: false),
      filled: !((viewModel.security.securityType?.id !=
              ServerConstants
                  .securityTypeId[SecurityType.assignmentOfReceivables]) &&
          (viewModel.security.securityType?.id !=
                  ServerConstants
                      .securityTypeId[SecurityType.assignmentOfInsurancess] ||
              !viewModel.isParipassu)),
      readOnly: viewModel.isCmoUpdate() ||
          !((viewModel.security.securityType?.id !=
                  ServerConstants
                      .securityTypeId[SecurityType.assignmentOfReceivables]) &&
              (viewModel.security.securityType?.id !=
                      ServerConstants.securityTypeId[
                          SecurityType.assignmentOfInsurancess] ||
                  !viewModel.isParipassu)),
      initialValue: (viewModel.security.proposedSecurityAmount == null ||
              viewModel.security.proposedSecurityAmount == 0)
          ? "0"
          : formatter.format(viewModel.security.proposedSecurityAmount?.toInt()),
      // No thousands-separator formatter here: onChanged below inserts the
      // commas itself by writing a formatted value back to the controller.
      inputFormatters: securityAmountFormatters(),
      onChanged: (String? value) {
        if (value != null && value.isNotEmpty) {
          final String cleaned = value.replaceAll(",", "");
          final double amount = double.tryParse(cleaned) ?? 0;
          viewModel.security.proposedSecurityAmount = amount;
          // Format entered amount
          final String formatted = formatter.format(amount.toInt());
          viewModel.proposedSecurityAmountController.value = TextEditingValue(
            text: formatted,
            selection: TextSelection.collapsed(offset: formatted.length),
          );

          //  Trigger conversion update
          viewModel.getCurrencyRates(
            viewModel.security.proposedSecurityAmtCurrency,
            isPresentSecurityAmount: false,
            proposedAmount: amount,
          );
        }
      },
      hintText: "0",
      onSaved: (String? value) {
        viewModel.security.aedProposedSecurity = double.tryParse(
              viewModel.newProposedSecurityAmountController.text
                  .replaceAll(",", ""),
            ) ??
            double.tryParse(value?.replaceAll(",", "") ?? "0");

        viewModel.security.proposedSecurityAmount =
            double.tryParse(value?.replaceAll(",", "") ?? "0");
      },
      controller: viewModel.proposedSecurityAmountController,
      currencies: viewModel.currencyCodes,
      selectedCurrencies: [
        if (viewModel.currencyCodes.isNotEmpty)
          viewModel.security.proposedSecurityAmtCurrency ??
              viewModel.currencyCodes.first
        else
          Reference(),
      ],
      onCurrencySelected: (Reference selected) {
        viewModel
          ..onCurrencyChanged(
            selected,
            isPresentSecurityAmount: false,
          )
          ..getCurrencyRates(
            selected,
            isPresentSecurityAmount: false,
            proposedAmount: viewModel.security.proposedSecurityAmount,
          );
      },
      // Preserves this feature's plain list rows (no selection highlight).
      dropdownItemBuilder: currencyListTileItemBuilder,
    );
  }
}
