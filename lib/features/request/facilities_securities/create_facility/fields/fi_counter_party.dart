import "package:easy_localization/easy_localization.dart";
import "package:flutter/material.dart";
import "package:wcas_frontend/core/components/currency/amount_field.dart";
import "package:wcas_frontend/core/components/currency/defaults.dart";
import "package:wcas_frontend/core/constants/_server_constants.dart";
import "package:wcas_frontend/features/request/facilities_securities/create_facility/model.dart";
import "package:wcas_frontend/features/request/facilities_securities/create_facility/state.dart";
import "package:wcas_frontend/models/admin/reference.dart";

/// Widget for selecting and managing FI counterparty information.
class FiCounterParty extends StatelessWidget {
  /// Creates a FI counterparty widget.
  const FiCounterParty({required this.viewModel, super.key});

  /// View model containing FI counterparty data and actions.
  final CreateFacilityViewModel viewModel;

  @override
  Widget build(BuildContext context) {
    final NumberFormat formatter = NumberFormat("#,###");
    return CurrencyAmountField(
      label: "facilities.createFacility.counterPartyEquity".tr(),
      currencies: viewModel.currencyCodes,
      selectedCurrencies: [
        if (viewModel.facilityDetail.isNotEmpty)
          viewModel.facilityDetail.first.counterpartyEquity5PercentCurrency
        else
          viewModel.currencyCodes.first,
      ],
      onCurrencySelected: (Reference selected) {
        viewModel.getFacility.counterpartyEquity5PercentCurrency = selected;
        viewModel
          ..onCurrencyChanged(
            selected,
            CurrencyField.counterpartyEquity5Percent,
          )
          ..getCurrencyRates(
            selected,
            CurrencyField.counterpartyEquity5Percent,
          );
      },
      inputFormatters: currencyAmountFormatters(),
      initialValue: viewModel.facilityDetail.isNotEmpty
          ? formatter.format(
              viewModel.facilityDetail.first.counterpartyEquity5Percent ?? 0,
            )
          : "",
      onChanged: (String? value) {
        if (value != null && value.isNotEmpty) {
          final String cleaned = value.replaceAll(",", "");
          final double amount = double.tryParse(cleaned) ?? 0;
          viewModel.getFacility.counterpartyEquity5Percent = amount;
          final Reference? selected =
              viewModel.getFacility.counterpartyEquity5PercentCurrency;
          final String? selectedCode = selected?.name?.toUpperCase();

          if (selectedCode != ServerConstants.aedCurrency) {
            viewModel.getCurrencyRates(
              selected,
              CurrencyField.counterpartyEquity5Percent,
            );
          } else {
            final String formatted = formatter.format(amount);
            viewModel.newCounterpartyEquity5PercentController.value =
                TextEditingValue(
              text: formatted,
              selection: TextSelection.collapsed(offset: formatted.length),
            );
          }
        }
      },
      onSaved: (amount) {
        viewModel.getFacility.counterpartyEquity5Percent =
            double.tryParse(amount?.replaceAll(",", "") ?? "0");
      },
    );
  }
}
