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
import "package:wcas_frontend/core/utils/validators.dart";
import "package:wcas_frontend/features/request/facilities_securities/create_facility/model.dart";
import "package:wcas_frontend/features/request/facilities_securities/create_facility/state.dart";
import "package:wcas_frontend/models/admin/reference.dart";

class FiRevisedBank extends StatelessWidget {
  const FiRevisedBank({required this.viewModel, super.key});
  final CreateFacilityViewModel viewModel;

  @override
  Widget build(BuildContext context) {
    final NumberFormat formatter = NumberFormat("#,###");
    final bool isRequired = (ServerConstants.generalTradeGroup ==
                viewModel.getFacility.limitGroup ||
            ServerConstants.dcmGroup == viewModel.getFacility.limitGroup) ||
        (ServerConstants.bilateralLoanGroup ==
            viewModel.getFacility.limitGroup) ||
        (ServerConstants.sovergianGroup == viewModel.getFacility.limitGroup);
    final Reference? selectedCurrency =
        viewModel.getFacility.proposedLimitValue;
    return LabelWidget(
      isRequired: isRequired,
      label: "facilities.createFacility.revisedBankLimit".tr(),
      child: CustomTextField(
        inputFormatters: [
          LengthLimitingTextInputFormatter(15),
          FilteringTextInputFormatter.digitsOnly,
          ThousandsSeparatorFormatter(),
        ],
        prefixIcon: CustomDropdown<Reference>(
          width: 70.w,
          validationMessage: "validation.emptyField".tr(),
          height: null,
          items: viewModel.currencyCodes,
          selectedItems: (selectedCurrency != null)
              ? [selectedCurrency]
              : [viewModel.currencyCodes.first],
          onSelected: (selectedValue) {
            if (selectedValue.isNotEmpty) {
              viewModel.getFacility.proposedLimitValue = selectedValue.first;
              viewModel
                ..onCurrencyChanged(
                  selectedValue.first,
                  CurrencyField.revisedBankLimitProposedByFi,
                )
                ..getCurrencyRates(
                  selectedValue.first,
                  CurrencyField.revisedBankLimitProposedByFi,
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
        controller: viewModel.proposedLimitController,
        validator: isRequired ? CustomValidator.requiredField : null,
        onChanged: (String? value) {
          if (value != null && value.isNotEmpty) {
            final String cleaned = value.replaceAll(",", "");
            final double amount = double.tryParse(cleaned) ?? 0;
            viewModel.getFacility.proposedLimit =
                int.tryParse(amount.toString());
            final Reference? selected =
                viewModel.getFacility.proposedLimitValue;
            final String? selectedCode = selected?.name?.toUpperCase();

            if (selectedCode != ServerConstants.aedCurrency) {
              viewModel.getCurrencyRates(
                selected,
                CurrencyField.revisedBankLimitProposedByFi,
              );
            } else {
              final String formatted = formatter.format(amount);
              viewModel.newProposedLimitController.value = TextEditingValue(
                text: formatted,
                selection: TextSelection.collapsed(offset: formatted.length),
              );
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
