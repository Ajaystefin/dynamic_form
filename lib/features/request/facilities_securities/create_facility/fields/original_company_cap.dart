import "package:easy_localization/easy_localization.dart";
import "package:flutter/material.dart";
import "package:wcas_frontend/core/components/currency/amount_field.dart";
import "package:wcas_frontend/core/constants/constants.dart";
import "package:wcas_frontend/core/utils/utils.dart";
import "package:wcas_frontend/features/request/facilities_securities/create_facility/model.dart";
import "package:wcas_frontend/models/admin/reference.dart";

/// Widget for displaying and managing the original company cap value.
class OriginalCompanyCap extends StatelessWidget {
  /// Creates an original company cap widget.
  const OriginalCompanyCap({required this.viewModel, super.key});

  /// View model containing original company cap data and actions.
  final CreateFacilityViewModel viewModel;

  @override
  Widget build(BuildContext context) {
    final bool hasData =
        viewModel.getFacility.presentOutstandingCCValue?.name?.isNotEmpty ??
            false;

    final bool hasCountryCodes = viewModel.currencyCodes.isNotEmpty;
    final Reference? selectedCurrency =
        viewModel.getFacility.presentOutstandingCCValue;

    final String originalValue = (viewModel.facilityDetail.isNotEmpty)
        ? (viewModel.facilityDetail.first.originalLimit?.toString() ?? "")
        : "";

    return CurrencyAmountField(
      label: !Utils.isGroupApplication()
          ? "facilities.createFacility.originalCompanyCap".tr()
          : "facilities.createFacility.originalGroupCap".tr(),
      fieldKey: ValueKey(
        'origCap:${originalValue}_${selectedCurrency?.name ?? ""}',
      ), // NEW
      readOnly: true,
      // Read-only cap field; it has never applied input formatters.
      currencies: viewModel.currencyCodes,
      isDropdownEnabled: false,
      selectedCurrencies: (selectedCurrency != null)
          ? [selectedCurrency]
          : (hasCountryCodes ? [viewModel.currencyCodes.first] : []),
      onCurrencySelected: (Reference selected) {
        viewModel.getFacility.presentOutstandingCCValue = selected;
      },
      initialValue: originalValue,
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
