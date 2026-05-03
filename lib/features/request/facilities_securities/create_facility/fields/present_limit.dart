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

class PresentLimit extends StatelessWidget {
  const PresentLimit({required this.viewModel, super.key});
  final CreateFacilityViewModel viewModel;

  @override
  Widget build(BuildContext context) {
    final NumberFormat formatter = NumberFormat("#,###");
    final bool hasCountryCodes = viewModel.currencyCodes.isNotEmpty;
    final Reference? selectedCurrency = viewModel.getFacility.presentLimitValue;
    final bool isRequired = ServerConstants.sovergianGroup ==
            viewModel.getFacility.facilityTypeSelectedValue?.id ||
        (ServerConstants.generalTradeGroup ==
                viewModel.getFacility.facilityTypeSelectedValue?.id ||
            ServerConstants.dcmGroup ==
                viewModel.getFacility.facilityTypeSelectedValue?.id) ||
        (ServerConstants.bilateralLoanGroup ==
            viewModel.getFacility.facilityTypeSelectedValue?.id);
    return LabelWidget(
      isEnabled: false,
      label: "facilities.createFacility.presentLimit".tr(),
      isRequired: isRequired,
      child: CustomTextField(
        key: ValueKey(viewModel.getFacility.limitAmount?.description ?? ""),
        inputFormatters: [
          LengthLimitingTextInputFormatter(15),
          FilteringTextInputFormatter.digitsOnly,
          ThousandsSeparatorFormatter(),
        ],
        readOnly: true, //!viewModel.isFIFlow,
        filled: true, // !viewModel.isFIFlow,
        prefixIcon: CustomDropdown<Reference>(
          isEnabled: viewModel.isFIFlow,
          width: 70.w,
          validationMessage: "validation.emptyField".tr(),
          height: null,
          items: viewModel.currencyCodes,
          selectedItems: (selectedCurrency != null)
              ? [selectedCurrency]
              : (hasCountryCodes ? [viewModel.currencyCodes.first] : []),
          onSelected: (selectedValue) {
            if (selectedValue.isNotEmpty) {
              viewModel.getFacility.presentLimitValue = selectedValue.first;
              viewModel
                ..onCurrencyChanged(
                  selectedValue.first,
                  CurrencyField.presentLimit,
                )
                ..getCurrencyRates(
                  selectedValue.first,
                  CurrencyField.presentLimit,
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
        controller: viewModel.presentLimitController,
        initialValue: (viewModel.facilityDetail.isNotEmpty
            ? formatter.format(viewModel.facilityDetail.first.presentLimit ?? 0)
            : ""),
        validator: isRequired ? CustomValidator.requiredField : null,
        onChanged: (String? value) {
          if (value != null && value.isNotEmpty) {
            final String cleaned = value.replaceAll(",", "");
            final int amount = int.tryParse(cleaned) ?? 0;
            viewModel.getFacility.presentLimit = amount == 0
                ? (viewModel.facilityDetail.isNotEmpty
                    ? viewModel.facilityDetail.first.presentLimit
                    : 0)
                : amount;
            final Reference? selected = viewModel.getFacility.presentLimitValue;
            final String? selectedCode = selected?.name?.toUpperCase();

            if (selectedCode != ServerConstants.aedCurrency) {
              viewModel.getCurrencyRates(selected, CurrencyField.presentLimit);
            } else {
              final String formatted = formatter.format(amount);
              viewModel.newPresentLimitController.value = TextEditingValue(
                text: formatted,
                selection: TextSelection.collapsed(offset: formatted.length),
              );
            }
          }
        },
      ),
    );
  }
}
