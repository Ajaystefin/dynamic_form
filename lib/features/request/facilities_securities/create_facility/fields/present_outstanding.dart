import "package:easy_localization/easy_localization.dart";
import "package:flutter/material.dart";
import "package:wcas_frontend/core/components/currency/amount_field.dart";
import "package:wcas_frontend/core/components/currency/defaults.dart";
import "package:wcas_frontend/core/constants/_server_constants.dart";
import "package:wcas_frontend/core/globals.dart";
import "package:wcas_frontend/core/utils/validators.dart";
import "package:wcas_frontend/features/request/facilities_securities/create_facility/model.dart";
import "package:wcas_frontend/features/request/facilities_securities/create_facility/state.dart";
import "package:wcas_frontend/models/admin/reference.dart";

/// Widget for displaying and managing the present outstanding amount.
class PresentOutstanding extends StatelessWidget {
  /// Creates a present outstanding widget.
  const PresentOutstanding({required this.viewModel, super.key});

  /// View model containing present outstanding data and actions.
  final CreateFacilityViewModel viewModel;

  @override
  Widget build(BuildContext context) {
    final bool hasCountryCodes = viewModel.currencyCodes.isNotEmpty;
    final Reference? selectedCurrency =
        viewModel.getFacility.presentOutstandingCurrency;

    // final bool isReadOnly = viewModel.presentOutStandingReadOnly;

    final bool groupRequires = !(ServerConstants.fixedIncomeGroup ==
            viewModel.getFacility.limitGroup ||
        ServerConstants.corporateCrossBorderGroup ==
            viewModel.getFacility.limitGroup ||
        ServerConstants.treasuryGroup == viewModel.getFacility.limitGroup);

    final bool isRequired = !viewModel.isFIFlow || groupRequires;

    final NumberFormat formatter = NumberFormat("#,###");
    return CurrencyAmountField(
      label: "facilities.createFacility.presentOutstanding".tr(),
      isLabelEnabled:
          Globals.request?.applicationSubType == ServerConstants.manualEntry,
      isLabelRequired: isRequired,
      inputFormatters: currencyAmountFormatters(),
      validator: isRequired ? CustomValidator.requiredField : null,
      currencies: viewModel.currencyCodes,
      selectedCurrencies: (selectedCurrency != null)
          ? [selectedCurrency]
          : (hasCountryCodes ? [viewModel.currencyCodes.first] : []),
      onCurrencySelected: (Reference selected) {
        viewModel.getFacility.presentOutstandingCurrency = selected;

        //   Toggle converted AED field
        viewModel
          ..onCurrencyChanged(
            selected,
            CurrencyField.presentOutstanding,
          )
          ..getCurrencyRates(
            selected,
            CurrencyField.presentOutstanding,
          );
      },
      controller: viewModel.presentOutstandingController,
      initialValue:
          formatter.format(viewModel.getFacility.presentOutstandingAmount ?? 0),
      onChanged: (value) {
        if (value.isNotEmpty) {
          final int amount = int.tryParse(value.replaceAll(",", "")) ?? 0;

          viewModel.getFacility.presentOutstandingAmount = amount;

          final Reference? curr =
              viewModel.getFacility.presentOutstandingCurrency;
          final String code =
              curr?.name?.toUpperCase() ?? ServerConstants.aedCurrency;

          if (code != ServerConstants.aedCurrency) {
            viewModel.getCurrencyRates(
              curr,
              CurrencyField.presentOutstanding,
            );
          } else {
            viewModel.newPresentOutStandingController.value = TextEditingValue(
              text: formatter.format(amount),
              selection: TextSelection.collapsed(
                offset: formatter.format(amount).length,
              ),
            );
          }
        }
      },
      onSaved: (String? value) {
        viewModel.getFacility.presentOutstandingAmount =
            int.tryParse(value?.replaceAll(",", "") ?? "0");
        viewModel.getFacility.presentOutstandingAED = int.tryParse(
          viewModel.newPresentOutStandingController.text.replaceAll(",", ""),
        );
      },
    );
  }
}
