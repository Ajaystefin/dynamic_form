import "package:easy_localization/easy_localization.dart";
import "package:flutter/material.dart";
import "package:wcas_frontend/core/components/currency/amount_field.dart";
import "package:wcas_frontend/core/components/currency/defaults.dart";
import "package:wcas_frontend/core/constants/_server_constants.dart";
import "package:wcas_frontend/core/utils/validators.dart";
import "package:wcas_frontend/features/request/facilities_securities/create_facility/model.dart";
import "package:wcas_frontend/features/request/facilities_securities/create_facility/state.dart";
import "package:wcas_frontend/models/admin/reference.dart";

/// Widget for displaying and managing the FI revised bank limit value.
///
/// NOTE: this field shares `proposedLimitController` and
/// `newProposedLimitController` with `ProposedLimit`. Both widgets can be alive
/// at once, so the write ordering in the callbacks below must not be changed.
class FiRevisedBank extends StatelessWidget {
  /// Creates a FI revised bank limit widget.
  const FiRevisedBank({required this.viewModel, super.key});

  /// View model containing FI revised bank limit data and actions.
  final CreateFacilityViewModel viewModel;

  @override
  Widget build(BuildContext context) {
    final NumberFormat formatter = NumberFormat("#,###");
    final bool isRequired = (ServerConstants.generalTradeGroup ==
                viewModel.getFacility.limitGroup ||
            ServerConstants.dcmGroup == viewModel.getFacility.limitGroup) ||
        (ServerConstants.bilateralLoanGroup ==
            viewModel.getFacility.limitGroup) ||
        (ServerConstants.sovergianGroup == viewModel.getFacility.limitGroup);
    final Reference? selectedCurrency =
        viewModel.getFacility.proposedLimitValue;
    return CurrencyAmountField(
      isLabelRequired: isRequired,
      label: "facilities.createFacility.revisedBankLimit".tr(),
      inputFormatters: currencyAmountFormatters(),
      currencies: viewModel.currencyCodes,
      selectedCurrencies: (selectedCurrency != null)
          ? [selectedCurrency]
          : [viewModel.currencyCodes.first],
      onCurrencySelected: (Reference selected) {
        viewModel.getFacility.proposedLimitValue = selected;
        viewModel
          ..onCurrencyChanged(
            selected,
            CurrencyField.revisedBankLimitProposedByFi,
          )
          ..getCurrencyRatesDebounced(
            selected,
            CurrencyField.revisedBankLimitProposedByFi,
          );
      },
      controller: viewModel.proposedLimitController,
      validator: isRequired ? CustomValidator.requiredField : null,
      onChanged: (String? value) {
        if (value != null && value.isNotEmpty) {
          final String cleaned = value.replaceAll(",", "");
          final double amount = double.tryParse(cleaned) ?? 0;
          viewModel.getFacility.proposedLimit = int.tryParse(amount.toString());
          final Reference? selected = viewModel.getFacility.proposedLimitValue;
          final String? selectedCode = selected?.name?.toUpperCase();

          if (selectedCode != ServerConstants.aedCurrency) {
            viewModel.getCurrencyRatesDebounced(
              selected,
              CurrencyField.revisedBankLimitProposedByFi,
            );
          } else {
            final String formatted = formatter.format(amount);
            viewModel.newProposedLimitController.value = TextEditingValue(
              text: formatted,
              selection: TextSelection.collapsed(offset: formatted.length),
            );
          }
        }
      },
      onSaved: (amount) {
        viewModel.getFacility.proposedLimit =
            int.tryParse(amount?.replaceAll(",", "") ?? "0");
      },
    );
  }
}
