import "package:easy_localization/easy_localization.dart";
import "package:flutter/material.dart";
import "package:wcas_frontend/core/components/currency/amount_field.dart";
import "package:wcas_frontend/core/constants/_server_constants.dart";
import "package:wcas_frontend/core/constants/constants.dart";
import "package:wcas_frontend/core/globals.dart";
import "package:wcas_frontend/features/request/facilities_securities/create_facility/model.dart";
import "package:wcas_frontend/models/admin/reference.dart";

/// Widget for displaying and managing facility past dues information.
class FacilityPastDues extends StatelessWidget {
  /// Creates a facility past dues widget.
  const FacilityPastDues({required this.viewModel, super.key});

  /// View model containing facility past dues data and actions.
  final CreateFacilityViewModel viewModel;

  @override
  Widget build(BuildContext context) {
    final bool hasData =
        viewModel.getFacility.pastDues?.name?.isNotEmpty ?? false;

    final bool hasCountryCodes = viewModel.currencyCodes.isNotEmpty;
    final Reference? selectedCurrency = viewModel.getFacility.pastDues;
    return CurrencyAmountField(
      label: "facilities.createFacility.pastDue".tr(), readOnly: true,
      isLabelEnabled:
          Globals.request?.applicationSubType == ServerConstants.manualEntry,
      fieldKey: ValueKey(viewModel.getFacility.pastDues?.description ?? ""), //

      // This field stores a free-text description rather than a parsed amount,
      // so it has never applied input formatters.
      currencies: viewModel.currencyCodes,
      selectedCurrencies: (selectedCurrency != null)
          ? [selectedCurrency]
          : (hasCountryCodes ? [viewModel.currencyCodes.first] : []),
      onCurrencySelected: (Reference selected) {
        viewModel.getFacility.pastDues = selected;
      },
      // initialValue: viewModel.showCreateFacilityForm
      //     ? (viewModel.getFacility.pastDues?.description ?? "")
      //     : (viewModel.facilityDetail.isNotEmpty
      //         ? (viewModel.facilityDetail.first.pastDues?.toString() ?? "")
      //         : ""),
      initialValue: viewModel.getFacility.pastDues?.description ?? "",
      fillColor: !hasData
          ? AppColors.textFieldDisabledFill
          : AppColors.accordionSecondary,
      onSaved: (String? value) {
        viewModel.getFacility.pastDues?.description = value;
      },
    );
  }
}
