import "package:easy_localization/easy_localization.dart";
import "package:flutter/material.dart";
import "package:flutter/services.dart";
import "package:wcas_frontend/core/components/dropdown/dropdown.dart";
import "package:wcas_frontend/core/components/label.dart";
import "package:wcas_frontend/core/components/textfield.dart";
import "package:wcas_frontend/core/constants/_server_constants.dart";
import "package:wcas_frontend/core/constants/constants.dart";
import "package:wcas_frontend/core/utils/scale.dart";
import "package:wcas_frontend/core/utils/validators.dart";
import "package:wcas_frontend/features/request/projects/edit_contract/model.dart";
import "package:wcas_frontend/features/request/projects/edit_contract/utils/project_contract_numeric_helper.dart";
import "package:wcas_frontend/models/admin/reference.dart";

class ContractValue extends StatelessWidget {
  const ContractValue(this.viewModel, {super.key});
  final EditContractViewModel viewModel;

  @override
  Widget build(BuildContext context) {
    final formatter = NumberFormat("#,###"); // For comma formatting
    final items = viewModel.countryCodes;
    final selectedItem = viewModel.selectedContractValueCurrency;

    return LabelWidget(
      label: "project.linkContract.contractValue".tr(),
      isRequired: true,
      child: Column(
        children: [
          CustomTextField(
            semanticLabel: "project.linkContract.contractValue".tr(),
            prefixIcon: CustomDropdown<Reference>(
              width: 70.w,
              height: null,
              validationMessage: "validation.emptyField".tr(),
              items: items,
              selectedItems: selectedItem == null ? null : [selectedItem],
              onSelected: (selectedValue) {
                if (selectedValue.isNotEmpty) {
                  viewModel
                    ..onCurrencyChanged(selectedValue.first)
                    ..getCurrencyRates(selectedValue.first);
                }
              },
              itemBuilder: (context, item, isDisabled, isSelected) {
                return ListTile(
                  title: Text(item.name ?? ""),
                );
              },
              dropdownBuilder: (context, data) {
                return Text(
                  data?.name ?? "",
                  style: const TextStyle(fontSize: 12),
                );
              },
            ),
            controller: viewModel.contractorValueController,
            inputFormatters: [
              // Allow only digits, comma, and dot (no anchors!)
              FilteringTextInputFormatter.allow(RegExp(r"[0-9,\.]")),
              NumericDecimalTextInputFormatter(
                maxIntegerDigits: 15, // ← your requirement
                maxDecimalDigits: 6, // ← your requirement
              ),
            ],
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            validator: (v) => CustomValidator.requiredFieldCustomMsg(
              v,
              "project.linkContract.pleaseEnterContractValue".tr(),
            ),
            onChanged: (String? value) async {
              if (value == null) return;

              final String raw = value;

              // User still typing fractional part?
              final bool isInProgressDecimal =
                  raw.endsWith(".") || RegExp(r"\.\d{0,6}$").hasMatch(raw);

              // Remove grouping separators before parsing
              final String cleaned = raw.replaceAll(",", "");

              // --- NEW: Detect if integer part exceeds safe double precision
              // (~15-16 digits) ---
              final List<String> parts = cleaned.split(".");
              final int integerDigits = parts[0].length;
              final bool exceedsDoublePrecision = integerDigits > 15;

              // Parse to double if possible (will be approximate for huge
              // numbers)
              final double amount = double.tryParse(cleaned) ?? 0.0;
              viewModel.contract.contractAmount = cleaned;

              // Store raw numeric (in the selected currency, not AED)
              viewModel.contract.contractValue = cleaned;

              // If the user is still typing, avoid auto-formatting the input
              // text
              if (!isInProgressDecimal) {
                // --- CHANGED: Choose formatter depending on precision safety
                // ---
                String formatted;
                if (exceedsDoublePrecision) {
                  // For very large values, format the raw string to avoid
                  // double precision loss
                  formatted = ProjectContractNumericHelper
                      .formatAsThousandsPreservingDecimals(cleaned);
                } else {
                  // Use your existing formatter (grouped, up to 6 decimals) for
                  // safe ranges
                  formatted = formatter.format(amount);
                }

                // Only update the field if the formatted differs from the
                // current raw
                if (formatted != raw) {
                  viewModel.contractorValueController.value = TextEditingValue(
                    text: formatted,
                    selection:
                        TextSelection.collapsed(offset: formatted.length),
                  );
                }
              }

              // Trigger conversion to AED (await if async)
              await viewModel.getCurrencyRates(
                Reference(name: viewModel.contract.contractCurrency),
              );
              // Assuming getCurrencyRates populates:
              // contract.contractValueAedAmount
              // Now refresh variation in AED
              viewModel.updateVariationField(isChanged: true);
            },
            filled: (viewModel.canEdit) ? false : true,
            readOnly: (viewModel.canEdit) ? false : true,
          ),
          if (viewModel.selectedCurrencyLabel != ServerConstants.aedCurrency)
            CustomTextField(
              prefixIcon: CustomDropdown<Reference>(
                width: 70.w,
                height: null,
                isEnabled: false,
                showClearIcon: false,
                items: viewModel.countryCodes,
                validationMessage: "validation.emptyField".tr(),
                selectedItems: [
                  viewModel.countryCodes
                      .where(
                        (code) => code.name == ServerConstants.aedCurrency,
                      )
                      .first,
                ],
                itemBuilder: (context, item, isDisabled, isSelected) {
                  return ListTile(
                    title: Text(item.name ?? ""),
                  );
                },
                dropdownBuilder: (context, data) {
                  return Text(
                    data?.name ?? "",
                    style: const TextStyle(fontSize: 12),
                  );
                },
              ),
              initialValue: "0",
              semanticLabel: "project.linkContract.convertedAmount".tr(),
              readOnly: true,
              filled: true,
              inputFormatters: [DecimalInputFormatter()],
              fillColor: AppColors.tableActivatedColor,
              controller: viewModel.convertedAmountController,
            ),
        ],
      ),
    );
  }
}
