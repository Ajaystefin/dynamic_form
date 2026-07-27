import "package:easy_localization/easy_localization.dart";
import "package:flutter/material.dart";
import "package:wcas_frontend/core/components/currency/amount_field.dart";
import "package:wcas_frontend/core/components/currency/defaults.dart";
import "package:wcas_frontend/core/constants/_server_constants.dart";
import "package:wcas_frontend/core/utils/utils.dart";
import "package:wcas_frontend/core/utils/validators.dart";
import "package:wcas_frontend/features/request/facilities_securities/create_facility/model.dart";
import "package:wcas_frontend/features/request/facilities_securities/create_facility/state.dart";
import "package:wcas_frontend/models/admin/reference.dart";

/// Widget for displaying and managing the FI revised bank limit currency.
///
/// NOTE: this field shares `proposedByccController` and
/// `newProposedByccController` with `FacilityProposedByCC`. Both widgets can be
/// alive at once, so the write ordering in the callbacks below must not change.
class FiRevisedBankByCC extends StatelessWidget {
  /// Creates a FI revised bank limit currency widget.
  const FiRevisedBankByCC({required this.viewModel, super.key});

  /// View model containing FI revised bank limit currency data and actions.
  final CreateFacilityViewModel viewModel;

  @override
  Widget build(BuildContext context) {
    final NumberFormat formatter = NumberFormat("#,###");
    final Reference selectedCurrency = Reference(
      name: viewModel.getFacility.proposedByCcCurrency ??
          ServerConstants.aedCurrency,
    );
    final bool groupRequires = !(ServerConstants.fixedIncomeGroup ==
            viewModel.getFacility.limitGroup ||
        ServerConstants.corporateCrossBorderGroup ==
            viewModel.getFacility.limitGroup ||
        ServerConstants.treasuryGroup == viewModel.getFacility.limitGroup);
    return CurrencyAmountField(
      isLabelRequired: groupRequires,
      isLabelEnabled: Utils.checkRoles([UserRole.creditAnalyst]),
      label: "facilities.createFacility.revisedBankLimit".tr(),
      inputFormatters: currencyAmountFormatters(),
      filled: !Utils.checkRoles([UserRole.creditAnalyst]),
      currencies: viewModel.currencyCodes,
      selectedCurrencies: [selectedCurrency],
      onCurrencySelected: (Reference selected) {
        viewModel.getFacility.proposedByCcCurrency = selected.name;
        viewModel
          ..onCurrencyChanged(
            selected,
            CurrencyField.revisedBankLimitRecommendedByCredit,
          )
          ..getCurrencyRates(
            selected,
            CurrencyField.revisedBankLimitRecommendedByCredit,
          );
      },
      validator: Utils.checkRoles([UserRole.creditAnalyst])
          ? CustomValidator.requiredField
          : null,
      controller: viewModel.proposedByccController,
      onChanged: (String? value) {
        if (value != null && value.isNotEmpty) {
          final String cleaned = value.replaceAll(",", "");
          final double amount = double.tryParse(cleaned) ?? 0;
          viewModel.getFacility.proposedByCc = amount;

          final String? selectedCode =
              viewModel.getFacility.proposedByCcCurrency?.toUpperCase();

          if (selectedCode != ServerConstants.aedCurrency) {
            viewModel.getCurrencyRates(
              Reference(name: selectedCode),
              CurrencyField.revisedBankLimitRecommendedByCredit,
            );
          } else {
            final String formatted = formatter.format(amount);
            viewModel.newProposedByccController.value = TextEditingValue(
              text: formatted,
              selection: TextSelection.collapsed(offset: formatted.length),
            );
          }
        }
      },
      onSaved: (amount) {
        viewModel.getFacility.proposedByCc =
            double.tryParse(amount?.replaceAll(",", "") ?? "0") ?? 0;
      },
    );
  }
}
