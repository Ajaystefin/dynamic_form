import "package:easy_localization/easy_localization.dart";
import "package:flutter/material.dart";
import "package:wcas_frontend/core/components/currency/amount_field.dart";
import "package:wcas_frontend/core/constants/constants.dart";
import "package:wcas_frontend/core/utils/utils.dart";
import "package:wcas_frontend/features/request/facilities_securities/create_facility/model.dart";
import "package:wcas_frontend/models/admin/reference.dart";

/// Widget for displaying the present company or group cap amount.
class PresentCompanyCap extends StatelessWidget {
  /// Creates a present company cap widget.
  const PresentCompanyCap({required this.viewModel, super.key});

  /// View model containing facility and currency data.
  final CreateFacilityViewModel viewModel;

  @override
  Widget build(BuildContext context) {
    final bool hasData =
        viewModel.getFacility.presentOutstandingCCValue?.name?.isNotEmpty ??
            false;

    final bool hasCountryCodes = viewModel.currencyCodes.isNotEmpty;
    final Reference? selectedCurrency =
        viewModel.getFacility.presentOutstandingCCValue;

// NEW: derive the text we show (so we can also feed it into the key)
    final String presentValue = (viewModel.facilityDetail.isNotEmpty)
        ? (viewModel.facilityDetail.first.presentLimit?.toString() ?? "")
        : "";

    return CurrencyAmountField(
      label: !Utils.isGroupApplication()
          ? "facilities.createFacility.presentCompanyCap".tr()
          : "facilities.createFacility.presentGroupCap".tr(),
      fieldKey:
          ValueKey('presCap:${presentValue}_${selectedCurrency?.name ?? ""}'),
      // NEW
      readOnly: true,
      // This field has never applied input formatters; it is read-only and its
      // text comes straight from the facility detail.
      currencies: viewModel.currencyCodes,
      isDropdownEnabled: false,
      selectedCurrencies: (selectedCurrency != null)
          ? [selectedCurrency]
          : (hasCountryCodes ? [viewModel.currencyCodes.first] : []),
      onCurrencySelected: (Reference selected) {
        viewModel.getFacility.presentOutstandingCCValue = selected;
      },

      // Use the same computed value for the field text
      initialValue: presentValue,

      filled: true,
      fillColor: !hasData
          ? AppColors.textFieldDisabledFill
          : AppColors.accordionSecondary,

      onSaved: (String? value) {
        viewModel.getFacility.presentOutstandingCCValue?.description = value;
      },
    );
  }
}
