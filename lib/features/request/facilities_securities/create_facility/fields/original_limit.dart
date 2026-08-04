import "package:easy_localization/easy_localization.dart";
import "package:flutter/material.dart";
import "package:wcas_frontend/core/components/currency/amount_field.dart";
import "package:wcas_frontend/core/constants/_server_constants.dart";
import "package:wcas_frontend/core/constants/constants.dart";
import "package:wcas_frontend/core/globals.dart";
import "package:wcas_frontend/features/request/facilities_securities/create_facility/model.dart";
import "package:wcas_frontend/models/admin/reference.dart";

/// Widget for displaying and managing the original facility limit value.
class OriginalLimit extends StatelessWidget {
  /// Creates an original limit widget.
  const OriginalLimit({required this.viewModel, super.key});

  /// View model containing original limit data and actions.
  final CreateFacilityViewModel viewModel;

  @override
  Widget build(BuildContext context) {
    final NumberFormat formatter = NumberFormat("#,###");
    final bool hasData =
        viewModel.getFacility.originalLimitCCValue?.name?.isNotEmpty ?? false;

    final bool hasCountryCodes = viewModel.currencyCodes.isNotEmpty;
    final Reference? selectedCurrency =
        viewModel.getFacility.originalLimitCCValue;
    return CurrencyAmountField(
      label: "facilities.createFacility.originalLimit".tr(),
      fieldKey: ValueKey(viewModel.getFacility.limitAmount?.description ?? ""),
      readOnly: !(Globals.request?.applicationSubType ==
          ServerConstants.manualEntry),
      // This field has never applied input formatters — the first currency
      // field in the form, and it performs no AED conversion.
      currencies: viewModel.currencyCodes,
      isDropdownEnabled:
          Globals.request?.applicationSubType == ServerConstants.manualEntry,
      selectedCurrencies: (selectedCurrency != null)
          ? [selectedCurrency]
          : (hasCountryCodes ? [viewModel.currencyCodes.first] : []),
      onCurrencySelected: (Reference selected) {
        viewModel.getFacility.originalLimitCCValue = selected;
      },
      initialValue: (viewModel.facilityDetail.isNotEmpty
          ? formatter.format(
              viewModel.facilityDetail.first.originalLimit ?? 0,
            )
          : ""),
      // filled: true,
      fillColor: !hasData
          ? AppColors.textFieldDisabledFill
          : AppColors.accordionSecondary,
      onSaved: (String? value) {
        viewModel.getFacility.originalLimitCCValue?.description = value ??
            (viewModel.facilityDetail.isNotEmpty
                ? (viewModel.facilityDetail.first.originalLimit?.toString() ??
                    "")
                // Read-only: value comes from facility detail,
                // not from form parameter.
                : "");
      },
    );
  }
}
