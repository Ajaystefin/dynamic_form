import "package:easy_localization/easy_localization.dart";
import "package:flutter/material.dart";
import "package:wcas_frontend/core/components/currency/amount_field.dart";
import "package:wcas_frontend/core/components/currency/defaults.dart";
import "package:wcas_frontend/core/constants/_server_constants.dart";
import "package:wcas_frontend/features/request/facilities_securities/create_facility/model.dart";
import "package:wcas_frontend/features/request/facilities_securities/create_facility/state.dart";
import "package:wcas_frontend/models/admin/reference.dart";

/// Widget for displaying and managing FI counterparty asset information.
class FiCounterPartyAssets extends StatelessWidget {
  /// Creates a FI counterparty assets widget.
  const FiCounterPartyAssets({required this.viewModel, super.key});

  /// View model containing FI counterparty asset data and actions.
  final CreateFacilityViewModel viewModel;

  @override
  Widget build(BuildContext context) {
    final NumberFormat formatter = NumberFormat("#,###");
    return CurrencyAmountField(
      label: "facilities.createFacility.counterpartyTotalAssets".tr(),
      currencies: viewModel.currencyCodes,
      selectedCurrencies: [
        if (viewModel.facilityDetail.isNotEmpty)
          viewModel.facilityDetail.first.counterpartyTotalAssets2PercentCurrency
        else
          viewModel.currencyCodes.first,
      ],
      onCurrencySelected: (Reference selected) {
        viewModel.getFacility.counterpartyTotalAssets2PercentCurrency =
            selected;
        viewModel
          ..onCurrencyChanged(
            selected,
            CurrencyField.counterpartyTotalAssets2Percent,
          )
          ..getCurrencyRatesDebounced(
            selected,
            CurrencyField.counterpartyTotalAssets2Percent,
          );
      },
      inputFormatters: currencyAmountFormatters(),
      initialValue: viewModel.facilityDetail.isNotEmpty
          ? formatter.format(
              viewModel.facilityDetail.first.counterpartyTotalAssets2Percent ??
                  0,
            )
          : "",
      onChanged: (String? value) {
        if (value != null && value.isNotEmpty) {
          final String cleaned = value.replaceAll(",", "");
          final double amount = double.tryParse(cleaned) ?? 0;
          viewModel.getFacility.counterpartyTotalAssets2Percent = amount;
          final Reference? selected =
              viewModel.getFacility.counterpartyTotalAssets2PercentCurrency;
          final String? selectedCode = selected?.name?.toUpperCase();

          if (selectedCode != ServerConstants.aedCurrency) {
            viewModel.getCurrencyRatesDebounced(
              selected,
              CurrencyField.counterpartyTotalAssets2Percent,
            );
          } else {
            final String formatted = formatter.format(amount);
            viewModel.newCounterpartyTotalAssets2PercentController.value =
                TextEditingValue(
              text: formatted,
              selection: TextSelection.collapsed(offset: formatted.length),
            );
          }
        }
      },
      onSaved: (amount) {
        viewModel.getFacility.counterpartyTotalAssets2Percent =
            double.tryParse(amount?.replaceAll(",", "") ?? "0");
      },
    );
  }
}
