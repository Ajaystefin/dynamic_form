import "package:easy_localization/easy_localization.dart";
import "package:flutter/material.dart";
import "package:wcas_frontend/core/components/currency/amount_field.dart";
import "package:wcas_frontend/core/components/currency/defaults.dart";
import "package:wcas_frontend/core/constants/_server_constants.dart";
import "package:wcas_frontend/core/utils/utils.dart";
import "package:wcas_frontend/features/request/facilities_securities/create_facility/model.dart";
import "package:wcas_frontend/features/request/facilities_securities/create_facility/state.dart";
import "package:wcas_frontend/models/admin/reference.dart";

/// Widget for displaying and managing the FI excess maximum limit currency.
class FiExcessMaxLimitCC extends StatelessWidget {
  /// Creates a FI excess maximum limit currency widget.
  const FiExcessMaxLimitCC({required this.viewModel, super.key});

  /// View model containing FI excess maximum limit currency data and actions.
  final CreateFacilityViewModel viewModel;

  @override
  Widget build(BuildContext context) {
    final NumberFormat formatter = NumberFormat("#,###");
    return CurrencyAmountField(
      label: "facilities.createFacility.maxLimitLowest".tr(),
      isLabelEnabled: Utils.checkRoles([UserRole.creditAnalyst]),
      filled: !Utils.checkRoles([UserRole.creditAnalyst]),
      currencies: viewModel.currencyCodes,
      selectedCurrencies: [
        if (viewModel.facilityDetail.isNotEmpty)
          viewModel
              .facilityDetail.first.excessOverMaxLimitAllowanceCurrencyByCredit
        else
          viewModel.currencyCodes.first,
      ],
      onCurrencySelected: (Reference selected) {
        viewModel.getFacility.excessOverMaxLimitAllowanceCurrencyByCredit =
            selected;
        viewModel
          ..onCurrencyChanged(
            selected,
            CurrencyField.excessOverMaxLimitAllowanceRecommendedByCredit,
          )
          ..getCurrencyRatesDebounced(
            selected,
            CurrencyField.excessOverMaxLimitAllowanceRecommendedByCredit,
          );
      },
      inputFormatters: currencyAmountFormatters(),
      controller:
          viewModel.excessOverMaxLimitAllowanceRecommendedByCreditController,
      initialValue: viewModel.facilityDetail.isNotEmpty
          ? formatter.format(
              viewModel.facilityDetail.first
                      .excessOverMaxLimitAllowanceByCredit ??
                  0,
            )
          : "",
      onChanged: (String? value) {
        // An empty box is an amount of 0, and has to reach the conversion below
        // like any other edit — otherwise the AED box keeps its last value.
        final String cleaned = (value ?? "").replaceAll(",", "");
        final double amount = double.tryParse(cleaned) ?? 0;
        viewModel.getFacility.excessOverMaxLimitAllowanceByCredit = amount;
        final Reference? selected =
            viewModel.getFacility.excessOverMaxLimitAllowanceCurrencyByCredit;
        final String? selectedCode = selected?.name?.toUpperCase();

        if (selectedCode != ServerConstants.aedCurrency) {
          viewModel.getCurrencyRatesDebounced(
            selected,
            CurrencyField.excessOverMaxLimitAllowanceRecommendedByCredit,
          );
        } else {
          final String formatted = formatter.format(amount);
          viewModel.newExcessOverMaxLimitAllowanceRecommendedByCreditController
              .value = TextEditingValue(
            text: formatted,
            selection: TextSelection.collapsed(offset: formatted.length),
          );
        }
      },
      onSaved: (amount) {
        viewModel.getFacility.excessOverMaxLimitAllowanceByCredit =
            double.tryParse(amount?.replaceAll(",", "") ?? "0");
      },
    );
  }
}
