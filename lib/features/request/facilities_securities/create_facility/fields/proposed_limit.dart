import "package:easy_localization/easy_localization.dart";
import "package:flutter/material.dart";
import "package:wcas_frontend/core/components/currency/amount_field.dart";
import "package:wcas_frontend/core/components/currency/defaults.dart";
import "package:wcas_frontend/core/constants/_server_constants.dart";
import "package:wcas_frontend/core/utils/alert_manager.dart";
import "package:wcas_frontend/core/utils/validators.dart";
import "package:wcas_frontend/features/request/facilities_securities/create_facility/model.dart";
import "package:wcas_frontend/features/request/facilities_securities/create_facility/state.dart";
import "package:wcas_frontend/models/admin/reference.dart";

/// Handles Proposed Limit input changes and performs validation against cap.
///
/// ------------------ WORKFLOW ------------------
/// 1. Parses user-entered value
/// 2. Updates getFacility.proposedLimit
/// 3. Handles currency conversion (if non-AED)
/// 4. Determines validation context:
///     - Sub-limit vs main limit
///     - Project Specific / Standby groups
///     - Parent controlling limit presence
///
/// ------------------ VALIDATION RULE ------------------
/// Sub-limit Proposed Limit must not exceed:
///     -> getFacility.totalProposedLimit (parent limit cap)
/// /// Determines whether the current flow is a Sub-Limit.
///
/// ------------------ LOGIC ------------------
/// A Sub-Limit is identified when:
///   - isMainLimit == false
///   - AND controlling limit number is present
///
/// ------------------ WHY IMPORTANT ------------------
/// This flag controls:
///   Proposed limit validation logic
///   Error messaging type
///   cap comparison source
///
///  Incorrect detection will skip validation completely
///
/// ------------------ TOAST CONTROL ------------------
/// Uses shouldShowProposedLimitToastOnce() to prevent spam
///
/// ------------------ MESSAGE SELECTION ------------------
/// - PSPL → "exceedProjectSpecificLimit"
/// - PSBL → "exceedProjectStandbyLimit"
/// - Default → "subLimitProposedLimitExceed"
///
/// ------------------ IMPORTANT NOTES ------------------
///  totalProposedLimit MUST be correctly populated
///  Validation only applies when isSubLimit == true
///
/// NOTE: this field shares `proposedLimitController` and
/// `newProposedLimitController` with `FiRevisedBank`. Both widgets can be alive
/// at once, so the write ordering in the callbacks below must not be changed.
///
/// Widget for displaying and managing the proposed facility limit value.
class ProposedLimit extends StatelessWidget {
  /// Creates a proposed limit widget.
  const ProposedLimit({
    required this.viewModel,
    super.key,
  });

  /// View model containing proposed limit data and actions.
  final CreateFacilityViewModel viewModel;

  @override
  Widget build(BuildContext context) {
    final NumberFormat formatter = NumberFormat("#,###");

    final Reference selectedCurrency = viewModel.isFIFlow
        ? viewModel.currencyCodes.first
        : (viewModel.getFacility.proposedLimitValue?.name != null
            ? Reference(name: viewModel.getFacility.proposedLimitValue?.name)
            : viewModel.currencyCodes.first);

    return CurrencyAmountField(
      label: "facilities.createFacility.proposedLimit".tr(),
      isLabelRequired: !viewModel.isFIFlow,
      isLabelEnabled: !viewModel.isFIFlow,
      inputFormatters: currencyAmountFormatters(),
      currencies: viewModel.currencyCodes,
      selectedCurrencies: [selectedCurrency],
      onCurrencySelected: (Reference selected) {
        viewModel.getFacility.proposedLimitValue = selected;
        viewModel
          ..onCurrencyChanged(
            selected,
            CurrencyField.proposedLimit,
          )
          ..getCurrencyRatesDebounced(
            selected,
            CurrencyField.proposedLimit,
          );
      },
      controller: viewModel.isFIFlow ? null : viewModel.proposedLimitController,
      filled: viewModel.isFIFlow,
      keyboardType: TextInputType.number,
      validator: viewModel.isFIFlow
          ? null
          : (String? value) {
              final String? req = CustomValidator.requiredField(value);
              return req;
            },
      onChanged: (String? value) {
        if (value != null && value.isNotEmpty) {
          final String cleaned = value.replaceAll(",", "");
          final int amount = int.tryParse(cleaned) ?? 0;

          //   Source amount (same as PresentOutstanding)
          viewModel.getFacility.proposedLimit = amount;

          final Reference? selected = viewModel.getFacility.proposedLimitValue;
          final String? selectedCode = selected?.name?.toUpperCase();
          final String parentCLN =
              (viewModel.parentControlliingNumber ?? "").trim().toUpperCase();

          final bool isPSBLParent = parentCLN.contains("PSBL");
          final bool isStandbyGroup = viewModel.getFacility.limitGroup ==
              ServerConstants.projectStandByLimitID;
          final bool isSpecificGroup = viewModel.getFacility.limitGroup ==
              ServerConstants.projectSpecificLimitsID;
          final bool isPSPLParent = parentCLN.contains("PSPL");
          final bool hasControlling =
              (viewModel.parentControlliingNumber ?? "").trim().isNotEmpty;
          final bool isSubLimit =
              (viewModel.getFacility.isMainLimit == false) && hasControlling;
          // ------------------ CURRENCY HANDLING (FIX) ------------------
          if (selectedCode != ServerConstants.aedCurrency) {
            //   DO NOT touch proposedLimitAED directly
            viewModel.getCurrencyRatesDebounced(
              selected,
              CurrencyField.proposedLimit,
            );
          } else {
            final String formatted = formatter.format(amount);
            viewModel.newProposedLimitController.value = TextEditingValue(
              text: formatted,
              selection: TextSelection.collapsed(offset: formatted.length),
            );
          }
          String proposedLimitExceedMessage() {
            if (isSpecificGroup && isPSPLParent) {
              return "facilities.facilitySummary.exceedProjectSpecificlimit"
                  .tr();
            }
            if (isStandbyGroup && isPSBLParent) {
              return "facilities.facilitySummary.exceedProjectStandbylimit"
                  .tr();
            }
            return "facilities.facilitySummary.subLimitProposedLimitExceed"
                .tr();
          }

          // ------------------ VALIDATION ------------------
          if (isSubLimit && !isStandbyGroup) {
            final int cap = viewModel.getFacility.totalProposedLimit ?? 0;
            if (amount > cap &&
                viewModel.shouldShowProposedLimitToastOnce(amount)) {
              AlertManager().showFailureToast(proposedLimitExceedMessage());
            }
          } else if (isSubLimit &&
              (viewModel.isStanbySublimitValidation ?? false) &&
              isStandbyGroup) {
            final int cap = viewModel.getFacility.totalProposedLimit ?? 0;
            if (amount > cap &&
                viewModel.shouldShowProposedLimitToastOnce(amount)) {
              AlertManager().showFailureToast(proposedLimitExceedMessage());
            }
          } else {
            if (viewModel.getFacility.totalProposedLimit == null) {
              return;
            }
            final int cap = viewModel.getFacility.totalProposedLimit ?? 0;
            if (amount > cap &&
                viewModel.shouldShowProposedLimitToastOnce(amount)) {
              final bool isNewStandbyFacility = isStandbyGroup &&
                  isSubLimit &&
                  !(viewModel.isStanbySublimitValidation ?? false) &&
                  parentCLN.isEmpty;
              final bool isExistingStandbyPSBL =
                  isStandbyGroup && isSubLimit && isPSBLParent;
              final bool isExistingSpecificPSPL =
                  isSpecificGroup && isSubLimit && isPSPLParent;

              AlertManager().showFailureToast(
                (isNewStandbyFacility ||
                        isExistingStandbyPSBL ||
                        isExistingSpecificPSPL)
                    ? proposedLimitExceedMessage()
                    : "facilities.facilitySummary.subLimitProposedLimitExceed"
                        .tr(),
              );
            }
          }
        }
      },
      onSaved: (amount) {
        viewModel.getFacility.proposedLimit =
            int.tryParse(amount?.replaceAll(",", "") ?? "0");
      },
    );
  }
}
