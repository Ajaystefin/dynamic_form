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

/// Widget for displaying and managing the present facility limit.
class PresentLimit extends StatelessWidget {
  /// Creates a present limit widget.
  const PresentLimit({
    required this.viewModel,
    super.key,
  });

  /// View model containing present limit data and actions.
  final CreateFacilityViewModel viewModel;

  /// Controls whether the widget is enabled.

  @override
  Widget build(BuildContext context) {
    final NumberFormat formatter = NumberFormat("#,###");

    final Reference selectedCurrency =
        viewModel.getFacility.presentLimitValue ??
            Reference(
              name:
                  viewModel.getFacility.currency ?? ServerConstants.aedCurrency,
            );
    final bool isRequired = ServerConstants.sovergianGroup ==
            viewModel.getFacility.facilityTypeSelectedValue?.id ||
        (ServerConstants.generalTradeGroup ==
                viewModel.getFacility.facilityTypeSelectedValue?.id ||
            ServerConstants.dcmGroup ==
                viewModel.getFacility.facilityTypeSelectedValue?.id) ||
        (ServerConstants.bilateralLoanGroup ==
            viewModel.getFacility.facilityTypeSelectedValue?.id);
    return CurrencyAmountField(
      isLabelEnabled:
          Globals.request?.applicationSubType == ServerConstants.manualEntry,
      // isEnabled: isEnable??false,
      label: "facilities.createFacility.presentLimit".tr(),
      isLabelRequired: isRequired,
      fieldKey: ValueKey(viewModel.getFacility.limitAmount?.description ?? ""),
      inputFormatters: currencyAmountFormatters(),
      currencies: viewModel.currencyCodes,
      selectedCurrencies: [selectedCurrency],
      isDropdownEnabled: viewModel.isFIFlow,
      onCurrencySelected: (Reference selected) {
        viewModel.getFacility.presentLimitValue = selected;
        viewModel
          ..onCurrencyChanged(
            selected,
            CurrencyField.presentLimit,
          )
          ..getCurrencyRates(
            selected,
            CurrencyField.presentLimit,
          );
      },
      controller: viewModel.presentLimitController,
      initialValue:
          formatter.format(viewModel.getFacility.presentLimitAED ?? 0),
      validator: isRequired ? CustomValidator.requiredField : null,
      onChanged: (String? value) {
        if (value != null && value.isNotEmpty) {
          final String cleaned = value.replaceAll(",", "");
          final int amount = int.tryParse(cleaned) ?? 0;
          viewModel.getFacility.presentLimit = amount == 0
              ? (viewModel.facilityDetail.isNotEmpty
                  ? viewModel.facilityDetail.first.presentLimit
                  : 0)
              : amount;
          final Reference? selected = viewModel.getFacility.presentLimitValue;
          final String? selectedCode = selected?.name?.toUpperCase();

          if (selectedCode != ServerConstants.aedCurrency) {
            viewModel.getCurrencyRates(selected, CurrencyField.presentLimit);
          } else {
            final String formatted = formatter.format(amount);
            viewModel.newPresentLimitController.value = TextEditingValue(
              text: formatted,
              selection: TextSelection.collapsed(offset: formatted.length),
            );
          }
        }
      },
    );
  }
}
