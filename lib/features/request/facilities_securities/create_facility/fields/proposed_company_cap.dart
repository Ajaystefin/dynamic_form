import "package:easy_localization/easy_localization.dart";
import "package:flutter/material.dart";
import "package:flutter/services.dart";
import "package:wcas_frontend/core/components/currency/amount_field.dart";
import "package:wcas_frontend/core/constants/_server_constants.dart";
import "package:wcas_frontend/core/constants/constants.dart";
import "package:wcas_frontend/core/utils/text_utils.dart";
import "package:wcas_frontend/core/utils/utils.dart";
import "package:wcas_frontend/features/request/facilities_securities/create_facility/model.dart";
import "package:wcas_frontend/models/admin/reference.dart";

/// Widget for displaying and managing the proposed company cap value.
class ProposedCompanyCap extends StatelessWidget {
  /// Creates a proposed company cap widget.
  const ProposedCompanyCap({
    required this.viewModel,
    super.key,
  });

  /// View model containing proposed company cap data and actions.
  final CreateFacilityViewModel viewModel;

  @override
  Widget build(BuildContext context) {
    final bool hasData =
        viewModel.getFacility.presentOutstandingCCValue?.name?.isNotEmpty ??
            false;

    final bool hasCountryCodes = viewModel.currencyCodes.isNotEmpty;
    final Reference? selectedCurrency =
        viewModel.getFacility.presentOutstandingCCValue;

    // ---enable only for Group Application AND "Yes" selected in
    // LimitCapGroupLevel
    final bool isGroupApp = !Utils.isGroupApplication();
    final int? sharedId = viewModel.getFacility.sharedLimit?.id;
    final String sharedName =
        (viewModel.getFacility.sharedLimit?.name ?? "").trim().toLowerCase();

    // Prefer ID check; fall back to name if IDs are unavailable in some
    // environments
    final bool isYesSelectedById =
        sharedId == ServerConstants.optionYESid; // 1904
    final bool isYesSelectedByName = sharedName == "yes";
    final bool enableProposedCap =
        isGroupApp || (isYesSelectedById || isYesSelectedByName);
    // ---------------------------------------------

    return CurrencyAmountField(
      label: !Utils.isGroupApplication()
          ? "facilities.createFacility.proposedCompanyCap".tr()
          : "facilities.createFacility.proposedGroupCap".tr(),
      isLabelRequired: true,
      readOnly: !enableProposedCap,
      filled: !enableProposedCap,
      fieldKey: ValueKey(
        "propCap:${enableProposedCap}_"
        '${viewModel.getFacility.proposedLimit ?? ''}_'
        '${selectedCurrency?.name ?? ''}',
      ),
      keyboardType: TextInputType.number,
      // Kept in this order deliberately: digitsOnly strips the commas before
      // the length cap is applied, so the cap counts digits rather than
      // grouped characters. Do not swap for currencyAmountFormatters().
      inputFormatters: [
        FilteringTextInputFormatter.digitsOnly,
        LengthLimitingTextInputFormatter(15),
        ThousandsSeparatorFormatter(),
      ],
      currencies: viewModel.currencyCodes,
      isDropdownEnabled: false,
      selectedCurrencies: (selectedCurrency != null)
          ? [selectedCurrency]
          : (hasCountryCodes ? [viewModel.currencyCodes.first] : []),
      onCurrencySelected: (Reference selected) {
        viewModel.getFacility.presentOutstandingCCValue = selected;
      },
      initialValue: (() {
        // If Group app and the Group Level Cap is NO, always render empty.
        if (Utils.isGroupApplication() && !enableProposedCap) {
          return "";
        }
        // existing logic (VM-first)...
        final int? vmVal = viewModel.getFacility.proposedLimit;
        final bool preferVm =
            viewModel.proposedCapEdited || viewModel.showCreateFacilityForm;

        if (preferVm && vmVal != null && vmVal > 0) {
          return vmVal.toString();
        }

        if (!viewModel.showCreateFacilityForm &&
            viewModel.facilityDetail.isNotEmpty) {
          final int? apiVal = viewModel.facilityDetail.first.proposedLimit;
          return (apiVal != null && apiVal > 0) ? apiVal.toString() : "";
        }

        return "";
      })(),
      fillColor: !enableProposedCap
          ? (!hasData
              ? AppColors.textFieldDisabledFill
              : AppColors.accordionSecondary)
          : null,
      onChanged: (String? value) {
        if (enableProposedCap) {
          final String raw = (value ?? "").replaceAll(",", "").trim();
          viewModel.proposedCapRaw = raw;
          viewModel.proposedCapEdited = true;

          viewModel.getFacility.proposedLimit = int.tryParse(raw) ?? 0;
          viewModel.getFacility.proposedLimitAED =
              viewModel.getFacility.proposedLimit;
        }
      },
    );
  }
}
