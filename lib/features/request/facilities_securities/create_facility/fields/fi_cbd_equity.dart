import "package:easy_localization/easy_localization.dart";
import "package:flutter/material.dart";
import "package:wcas_frontend/core/components/currency/amount_field.dart";
import "package:wcas_frontend/core/components/currency/defaults.dart";
import "package:wcas_frontend/core/constants/_server_constants.dart";
import "package:wcas_frontend/features/request/facilities_securities/create_facility/model.dart";
import "package:wcas_frontend/features/request/facilities_securities/create_facility/state.dart";
import "package:wcas_frontend/models/admin/reference.dart";

/// Widget for managing CBD equity details in the FI facility workflow.
class FiCbdEquity extends StatelessWidget {
  /// Creates a FI CBD equity widget.
  const FiCbdEquity({required this.viewModel, super.key});

  /// View model containing CBD equity data and actions.
  final CreateFacilityViewModel viewModel;

  @override
  Widget build(BuildContext context) {
    final NumberFormat formatter = NumberFormat("#,###");
    return CurrencyAmountField(
      label: "facilities.createFacility.cbdEquityTierBanks".tr(),
      inputFormatters: currencyAmountFormatters(),
      controller: viewModel.cbdEquityTier325PercentController,
      currencies: viewModel.currencyCodes,
      selectedCurrencies: [
        if (viewModel.facilityDetail.isNotEmpty)
          viewModel.facilityDetail.first.cbdEquityTier325PercentCurrency
        else
          viewModel.currencyCodes.first,
      ],
      onCurrencySelected: (Reference selected) {
        viewModel.getFacility.cbdEquityTier325PercentCurrency = selected;
        viewModel
          ..onCurrencyChanged(
            selected,
            CurrencyField.cbdEquityTier325Percent,
          )
          ..getCurrencyRatesDebounced(
            selected,
            CurrencyField.cbdEquityTier325Percent,
          );
      },
      initialValue: viewModel.facilityDetail.isNotEmpty
          ? formatter.format(
              viewModel.facilityDetail.first.cbdEquityTier325Percent ?? 0,
            )
          : "",
      onChanged: (String? value) {
        // An empty box is an amount of 0, and has to reach the conversion below
        // like any other edit — otherwise the AED box keeps its last value.
        final String cleaned = (value ?? "").replaceAll(",", "");
        final double amount = double.tryParse(cleaned) ?? 0;
        viewModel.getFacility.cbdEquityTier325Percent = amount;
        final Reference? selected =
            viewModel.getFacility.cbdEquityTier325PercentCurrency;
        final String? selectedCode = selected?.name?.toUpperCase();

        if (selectedCode != ServerConstants.aedCurrency) {
          viewModel.getCurrencyRatesDebounced(
            selected,
            CurrencyField.cbdEquityTier325Percent,
          );
        } else {
          final String formatted = formatter.format(amount);
          viewModel.newCbdEquityTier325PercentController.value =
              TextEditingValue(
            text: formatted,
            selection: TextSelection.collapsed(offset: formatted.length),
          );
        }
      },
      onSaved: (amount) {
        viewModel.getFacility.cbdEquityTier325Percent =
            double.tryParse(amount?.replaceAll(",", "") ?? "0");
      },
    );
  }
}
