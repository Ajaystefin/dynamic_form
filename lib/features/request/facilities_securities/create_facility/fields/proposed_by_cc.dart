import "package:easy_localization/easy_localization.dart";
import "package:flutter/material.dart";
import "package:wcas_frontend/core/components/currency/amount_field.dart";
import "package:wcas_frontend/core/components/currency/defaults.dart";
import "package:wcas_frontend/core/constants/_server_constants.dart";
import "package:wcas_frontend/features/request/facilities_securities/create_facility/model.dart";
import "package:wcas_frontend/features/request/facilities_securities/create_facility/state.dart";
import "package:wcas_frontend/models/admin/reference.dart";

/// Widget for displaying and managing the proposed by currency selection.
///
/// NOTE: this field shares `proposedByccController` and
/// `newProposedByccController` with `FiRevisedBankByCC`. Both widgets can be
/// alive at once, so the write ordering in the callbacks below must not change.
class FacilityProposedByCC extends StatelessWidget {
  /// Creates a facility proposed by currency widget.
  const FacilityProposedByCC({
    required this.viewModel,
    super.key,
  });

  /// View model containing proposed by currency data and actions.
  final CreateFacilityViewModel viewModel;

  @override
  Widget build(BuildContext context) {
    final NumberFormat formatter = NumberFormat("#,###");

    final Reference selectedCurrency = viewModel.isFIFlow
        ? viewModel.currencyCodes.first
        : Reference(
            name: viewModel.getFacility.proposedByCcCurrency ??
                ServerConstants.aedCurrency,
          );

    return CurrencyAmountField(
      label: "facilities.createFacility.proposedByCC".tr(),
      ignoreProvider: viewModel.isEditableForProposedByCC(),
      inputFormatters: currencyAmountFormatters(),
      currencies: viewModel.currencyCodes,
      isDropdownEnabled: viewModel.isEditableForProposedByCC(),
      selectedCurrencies: [selectedCurrency],
      onCurrencySelected: (Reference selected) {
        viewModel.getFacility.proposedByCcCurrency = selected.name;

        viewModel
          ..onCurrencyChanged(
            selected,
            CurrencyField.proposedBycc,
          )
          ..getCurrencyRatesDebounced(
            selected,
            CurrencyField.proposedBycc,
          );
      },
      controller: viewModel
          .proposedByccController, //removed initialValue when you already have a controller Avoids rebuild-based resets during Save.
      filled: !viewModel.isEditableForProposedByCC(),
      readOnly: !viewModel.isEditableForProposedByCC(),
      keyboardType: TextInputType.number,
      onChanged: (String? value) {
        // An empty box is an amount of 0, and has to reach the conversion below
        // like any other edit — otherwise the AED box keeps its last value.
        final String cleaned = (value ?? "").replaceAll(",", "");
        final int amount = int.tryParse(cleaned) ?? 0;

        viewModel.getFacility.proposedByCc = amount.toDouble();

        final Reference? selected =
            viewModel.getFacility.proposedByCcCurrency != null
                ? Reference(name: viewModel.getFacility.proposedByCcCurrency)
                : null;

        final String? selectedCode = selected?.name?.toUpperCase();

        if (selectedCode != ServerConstants.aedCurrency) {
          viewModel.getCurrencyRatesDebounced(
            selected,
            CurrencyField.proposedBycc,
          );
        } else if (cleaned.isNotEmpty) {
          // NOTE: unlike every other currency field, the AED branch here
          // writes back into its OWN source controller rather than the
          // converted `newProposedByccController`. That is intentional — do
          // not "fix" it to match the other fields. It is skipped for an empty
          // box, which would otherwise be refilled with "0" and never clear.
          final String formatted = formatter.format(amount);
          viewModel.proposedByccController.value = TextEditingValue(
            text: formatted,
            selection: TextSelection.collapsed(offset: formatted.length),
          );
        }
      },
      onSaved: (String? value) {
        viewModel.getFacility.proposedByCc =
            double.tryParse(value?.replaceAll(",", "") ?? "0") ?? 0;
      },
    );
  }
}
