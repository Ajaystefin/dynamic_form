import "package:easy_localization/easy_localization.dart";
import "package:flutter/material.dart";
import "package:flutter/services.dart";
import "package:wcas_frontend/core/components/dropdown/dropdown.dart";
import "package:wcas_frontend/core/components/dropdown/multi_select_dropdown.dart";
import "package:wcas_frontend/core/components/label.dart";
import "package:wcas_frontend/core/components/textfield.dart";
import "package:wcas_frontend/core/constants/_server_constants.dart";
import "package:wcas_frontend/core/utils/scale.dart";
import "package:wcas_frontend/core/utils/text_utils.dart";
import "package:wcas_frontend/core/utils/utils.dart";
import "package:wcas_frontend/core/utils/validators.dart";
import "package:wcas_frontend/features/request/facilities_securities/create_facility/model.dart";
import "package:wcas_frontend/features/request/facilities_securities/create_facility/state.dart";
import "package:wcas_frontend/models/admin/reference.dart";

class FiRevisedBankByCC extends StatelessWidget {
  const FiRevisedBankByCC({required this.viewModel, super.key});
  final CreateFacilityViewModel viewModel;

  @override
  Widget build(BuildContext context) {
    final NumberFormat formatter = NumberFormat("#,###");
    final Reference selectedCurrency = Reference(
      name: viewModel.getFacility.proposedByCcCurrency ??
          ServerConstants.aedCurrency,
    );
    final bool groupRequires = !(ServerConstants.fixedIncomeGroup ==
            viewModel.getFacility.limitGroup ||
        ServerConstants.corporateCrossBorderGroup ==
            viewModel.getFacility.limitGroup ||
        ServerConstants.treasuryGroup == viewModel.getFacility.limitGroup);
    return LabelWidget(
      isRequired: groupRequires,
      isEnabled: Utils.checkRoles([UserRole.creditAnalyst]),
      label: "facilities.createFacility.revisedBankLimit".tr(),
      child: CustomTextField(
        inputFormatters: [
          LengthLimitingTextInputFormatter(15),
          FilteringTextInputFormatter.digitsOnly,
          ThousandsSeparatorFormatter(),
        ],
        filled: !Utils.checkRoles([UserRole.creditAnalyst]),
        prefixIcon: CustomDropdown<Reference>(
          width: 70.w,
          validationMessage: "validation.emptyField".tr(),
          height: null,
          items: viewModel.currencyCodes,
          selectedItems: [selectedCurrency],
          onSelected: (selectedValue) {
            if (selectedValue.isNotEmpty) {
              viewModel.getFacility.proposedByCcCurrency =
                  selectedValue.first.name;
              viewModel
                ..onCurrencyChanged(
                  selectedValue.first,
                  CurrencyField.revisedBankLimitRecommendedByCredit,
                )
                ..getCurrencyRates(
                  selectedValue.first,
                  CurrencyField.revisedBankLimitRecommendedByCredit,
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
        validator: Utils.checkRoles([UserRole.creditAnalyst])
            ? CustomValidator.requiredField
            : null,
        controller: viewModel.proposedByccController,
        onChanged: (String? value) {
          if (value != null && value.isNotEmpty) {
            final String cleaned = value.replaceAll(",", "");
            final double amount = double.tryParse(cleaned) ?? 0;
            viewModel.getFacility.proposedByCc = amount;

            final String? selectedCode =
                viewModel.getFacility.proposedByCcCurrency?.toUpperCase();

            if (selectedCode != ServerConstants.aedCurrency) {
              viewModel.getCurrencyRates(
                Reference(name: selectedCode),
                CurrencyField.revisedBankLimitRecommendedByCredit,
              );
            } else {
              final String formatted = formatter.format(amount);
              viewModel.newProposedByccController.value = TextEditingValue(
                text: formatted,
                selection: TextSelection.collapsed(offset: formatted.length),
              );
            }
          }
        },
        onSaved: (amount) {
          viewModel.getFacility.proposedByCc =
              double.tryParse(amount?.replaceAll(",", "") ?? "0") ?? 0;
        },
      ),
    );
  }
}
