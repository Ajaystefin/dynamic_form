import "package:easy_localization/easy_localization.dart";
import "package:flutter/material.dart";
import "package:flutter/services.dart";
import "package:wcas_frontend/core/components/currency/amount_field.dart";
import "package:wcas_frontend/core/utils/text_utils.dart";
import "package:wcas_frontend/core/utils/utils.dart";
import "package:wcas_frontend/core/utils/validators.dart";
import "package:wcas_frontend/features/request/facilities_securities/create_facility/model.dart";
import "package:wcas_frontend/models/admin/reference.dart";

/// Widget for displaying and managing the proposed single borrower cap value.
class ProposedSingleBorrowerCap extends StatelessWidget {
  /// Creates a proposed single borrower cap widget.
  const ProposedSingleBorrowerCap({
    required this.viewModel,
    super.key,
  });

  /// View model containing proposed single borrower cap data and actions.
  final CreateFacilityViewModel viewModel;

  @override
  Widget build(BuildContext context) {
    // Make the field reset when limitCapType changes by including it in the key
    final String capTypeKey =
        viewModel.getFacility.limitCapType?.toString() ?? "none";
    final bool isRequired = !viewModel.isFIFlow;
    final bool hasCountryCodes = viewModel.currencyCodes.isNotEmpty;
    final Reference? selectedCurrency =
        viewModel.getFacility.presentOutstandingCCValue;
    return CurrencyAmountField(
      label: !Utils.isGroupApplication()
          ? "facilities.createFacility.proposedCompanyCap".tr()
          : "facilities.createFacility.proposedGroupCap".tr(),
      isLabelRequired: true,
      fieldKey: ValueKey("propCap:$capTypeKey"),
      validator: isRequired ? CustomValidator.requiredField : null,
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

      // Keep it simple: show whatever we currently hold in VM
      initialValue: (viewModel.getFacility.proposedLimit != null &&
              viewModel.getFacility.proposedLimit! > 0)
          ? viewModel.getFacility.proposedLimit!.toString()
          : "",
      onChanged: (String? value) {
        final String raw = (value ?? "").replaceAll(",", "").trim();
        viewModel.proposedCapRaw = raw;
        viewModel.proposedCapEdited = true;
        viewModel.getFacility.proposedLimit = int.tryParse(raw);
        viewModel.getFacility.proposedLimitAED =
            viewModel.getFacility.proposedLimit;
      },
    );
  }
}
