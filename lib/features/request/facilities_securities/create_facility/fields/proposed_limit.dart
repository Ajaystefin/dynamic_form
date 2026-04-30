import "package:easy_localization/easy_localization.dart";
import "package:flutter/material.dart";
import "package:flutter/services.dart";
import "package:wcas_frontend/core/components/dropdown/dropdown.dart";
import "package:wcas_frontend/core/components/dropdown/multi_select_dropdown.dart";
import "package:wcas_frontend/core/components/label.dart";
import "package:wcas_frontend/core/components/textfield.dart";
import "package:wcas_frontend/core/constants/_server_constants.dart";
import "package:wcas_frontend/core/utils/alert_manager.dart";
import "package:wcas_frontend/core/utils/scale.dart";
import "package:wcas_frontend/core/utils/text_utils.dart";
import "package:wcas_frontend/core/utils/validators.dart";
import "package:wcas_frontend/features/request/facilities_securities/create_facility/model.dart";
import "package:wcas_frontend/features/request/facilities_securities/create_facility/state.dart";
import "package:wcas_frontend/models/admin/reference.dart";

class ProposedLimit extends StatelessWidget {
  const ProposedLimit({required this.viewModel, super.key});
  final CreateFacilityViewModel viewModel;

  @override
  Widget build(BuildContext context) {
    final NumberFormat formatter = NumberFormat("#,###");

    final Reference selectedCurrency = viewModel.isFIFlow
        ? viewModel.currencyCodes.first
        : (viewModel.getFacility.proposedLimitValue?.name != null
            ? Reference(name: viewModel.getFacility.proposedLimitValue?.name)
            : viewModel.currencyCodes.first);

    return LabelWidget(
      label: "facilities.createFacility.proposedLimit".tr(),
      isRequired: !viewModel.isFIFlow,
      isEnabled: !viewModel.isFIFlow,
      child: CustomTextField(
        inputFormatters: [
          LengthLimitingTextInputFormatter(15),
          FilteringTextInputFormatter.digitsOnly,
          ThousandsSeparatorFormatter(),
        ],
        prefixIcon: CustomDropdown<Reference>(
          width: 70.w,
          height: null,
          validationMessage: "validation.emptyField".tr(),
          items: viewModel.currencyCodes,
          selectedItems: [selectedCurrency],
          onSelected: (selectedValue) {
            if (selectedValue.isNotEmpty) {
              viewModel.getFacility.proposedLimitValue = (selectedValue.first);
              viewModel.onCurrencyChanged(
                selectedValue.first,
                CurrencyField.proposedLimit,
              );
              viewModel.getCurrencyRates(
                selectedValue.first,
                CurrencyField.proposedLimit,
              );
            }
          },
          itemBuilder: (context, item, isDisabled, isSelected) {
            return dropdownMultiItemBuildWidget(
              item.name,
              isSelected: isSelected,
            );
          },
          dropdownBuilder: (context, data) {
            return Text(
              data?.name ?? "",
              style: const TextStyle(fontSize: 12),
            );
          },
        ),
        controller:
            viewModel.isFIFlow ? null : viewModel.proposedLimitController,
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

            final Reference? selected =
                viewModel.getFacility.proposedLimitValue;
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
              viewModel.getCurrencyRates(
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
              final int cap = (viewModel.getFacility.totalProposedLimit ?? 0);
              if (amount > cap &&
                  viewModel.shouldShowProposedLimitToastOnce(amount)) {
                AlertManager().showFailureToast(proposedLimitExceedMessage());
              }
            } else if (isSubLimit &&
                (viewModel.isStanbySublimitValidation ?? false) &&
                isStandbyGroup) {
              final int cap = (viewModel.getFacility.totalProposedLimit ?? 0);
              if (amount > cap &&
                  viewModel.shouldShowProposedLimitToastOnce(amount)) {
                AlertManager().showFailureToast(proposedLimitExceedMessage());
              }
            } else {
              if (viewModel.getFacility.totalProposedLimit == null) return;
              final int cap = (viewModel.getFacility.totalProposedLimit ?? 0);
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
      ),
    );
  }
}
