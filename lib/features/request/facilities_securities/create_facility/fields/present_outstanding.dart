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

class PresentOutstanding extends StatelessWidget {
  const PresentOutstanding({required this.viewModel, super.key});
  final CreateFacilityViewModel viewModel;

  @override
  Widget build(BuildContext context) {
    final bool hasCountryCodes = viewModel.currencyCodes.isNotEmpty;
    final Reference? selectedCurrency =
        viewModel.getFacility.presentOutstandingCurrency;

    final bool isReadOnly =
        !viewModel.isFIFlow && viewModel.presentOutStandingReadOnly;

    final bool groupRequires = !(ServerConstants.fixedIncomeGroup ==
            viewModel.getFacility.limitGroup ||
        ServerConstants.corporateCrossBorderGroup ==
            viewModel.getFacility.limitGroup ||
        ServerConstants.treasuryGroup == viewModel.getFacility.limitGroup);

    final bool isRequired = viewModel.isFIFlow ? groupRequires : true;

    final NumberFormat formatter = NumberFormat("#,###");
    return LabelWidget(
      label: "facilities.createFacility.presentOutstanding".tr(),
      isRequired: isRequired,
      child: CustomTextField(
        inputFormatters: [
          LengthLimitingTextInputFormatter(15),
          FilteringTextInputFormatter.digitsOnly,
          ThousandsSeparatorFormatter(),
        ],
        validator: isRequired ? CustomValidator.requiredField : null,
        readOnly: isReadOnly,
        prefixIcon: CustomDropdown<Reference>(
          isEnabled: !isReadOnly,
          width: 70.w,
          height: null,
          validationMessage: "validation.emptyField".tr(),
          items: viewModel.currencyCodes,
          selectedItems: (selectedCurrency != null)
              ? [selectedCurrency]
              : (hasCountryCodes ? [viewModel.currencyCodes.first] : []),
          onSelected: (selectedValue) {
            if (selectedValue.isNotEmpty) {
              viewModel.getFacility.presentOutstandingCurrency =
                  selectedValue.first;

              //   Toggle converted AED field
              viewModel
                ..onCurrencyChanged(
                  selectedValue.first,
                  CurrencyField.presentOutstanding,
                )
                ..getCurrencyRates(
                  selectedValue.first,
                  CurrencyField.presentOutstanding,
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
        // initialValue: presentOutstandingAmount,
        controller: viewModel.presentOutstandingController,
        filled: isReadOnly,
        onChanged: (value) {
          if (value.isNotEmpty) {
            final int amount = int.tryParse(value.replaceAll(",", "")) ?? 0;

            viewModel.getFacility.presentOutstandingAmount = amount;

            final Reference? curr =
                viewModel.getFacility.presentOutstandingCurrency;
            final String code =
                curr?.name?.toUpperCase() ?? ServerConstants.aedCurrency;

            if (code != ServerConstants.aedCurrency) {
              viewModel.getCurrencyRates(
                curr,
                CurrencyField.presentOutstanding,
              );
            } else {
              viewModel.newPresentOutStandingController.value =
                  TextEditingValue(
                text: formatter.format(amount),
                selection: TextSelection.collapsed(
                  offset: formatter.format(amount).length,
                ),
              );
            }
          }
        },
        onSaved: (String? value) {
          viewModel.getFacility.presentOutstandingAmount =
              int.tryParse(value?.replaceAll(",", "") ?? "0");
          viewModel.getFacility.presentOutstandingAED = int.tryParse(
            viewModel.newPresentOutStandingController.text.replaceAll(",", ""),
          );
        },
      ),
    );
  }
}
