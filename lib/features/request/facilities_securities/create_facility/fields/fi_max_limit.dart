import "package:easy_localization/easy_localization.dart";
import "package:flutter/material.dart";
import "package:wcas_frontend/core/components/currency/amount_field.dart";
import "package:wcas_frontend/core/components/currency/defaults.dart";
import "package:wcas_frontend/core/constants/_server_constants.dart";
import "package:wcas_frontend/features/request/facilities_securities/create_facility/model.dart";
import "package:wcas_frontend/features/request/facilities_securities/create_facility/state.dart";
import "package:wcas_frontend/models/admin/reference.dart";

/// Widget for displaying and managing the FI excess maximum limit value.
class FiExcessMaxLimit extends StatelessWidget {
  /// Creates a FI excess maximum limit widget.
  const FiExcessMaxLimit({required this.viewModel, super.key});

  /// View model containing FI excess maximum limit data and actions.
  final CreateFacilityViewModel viewModel;

  @override
  Widget build(BuildContext context) {
    final NumberFormat formatter = NumberFormat("#,###");

    return CurrencyAmountField(
      label: "facilities.createFacility.maxLimitLowest".tr(),
      currencies: viewModel.currencyCodes,
      selectedCurrencies: [
        if (viewModel.facilityDetail.isNotEmpty)
          viewModel.facilityDetail.first.excessOverMaxLimitAllowanceCurrencyByFi
        else
          viewModel.currencyCodes.first,
      ],
      onCurrencySelected: (Reference selected) {
        viewModel.getFacility.excessOverMaxLimitAllowanceCurrencyByFi =
            selected;

        //  Toggle visibility + sync currency
        viewModel
          ..onCurrencyChanged(
            selected,
            CurrencyField.excessOverMaxLimitAllowanceProposedByFi,
          )
          ..getCurrencyRatesDebounced(
            selected,
            CurrencyField.excessOverMaxLimitAllowanceProposedByFi,
          );
      },
      inputFormatters: currencyAmountFormatters(),
      controller: viewModel.excessOverMaxLimitAllowanceProposedByFiController,
      initialValue: viewModel.facilityDetail.isNotEmpty
          ? formatter.format(
              viewModel.facilityDetail.first.excessOverMaxLimitAllowanceByFi ??
                  0,
            )
          : "",
      onChanged: (String? value) {
        if (value != null && value.isNotEmpty) {
          final String cleaned = value.replaceAll(",", "");
          final double amount = double.tryParse(cleaned) ?? 0;

          viewModel.getFacility.excessOverMaxLimitAllowanceByFi = amount;

          final Reference? selected =
              viewModel.getFacility.excessOverMaxLimitAllowanceCurrencyByFi;
          final String? selectedCode = selected?.name?.toUpperCase();

          if (selectedCode != ServerConstants.aedCurrency) {
            //  Convert amount
            viewModel.getCurrencyRatesDebounced(
              selected,
              CurrencyField.excessOverMaxLimitAllowanceProposedByFi,
            );
          } else {
            final String formatted = formatter.format(amount);
            viewModel.newExcessOverMaxLimitAllowanceProposedByFiController
                .value = TextEditingValue(
              text: formatted,
              selection: TextSelection.collapsed(offset: formatted.length),
            );
          }
        }
      },
      onSaved: (amount) {
        viewModel.getFacility.excessOverMaxLimitAllowanceByFi =
            double.tryParse(amount?.replaceAll(",", "") ?? "0");
      },
    );
  }
}
