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
import "package:wcas_frontend/features/request/facilities_securities/create_facility/model.dart";
import "package:wcas_frontend/features/request/facilities_securities/create_facility/state.dart";
import "package:wcas_frontend/models/admin/reference.dart";

class FiCbdEquity extends StatelessWidget {
  const FiCbdEquity({required this.viewModel, super.key});
  final CreateFacilityViewModel viewModel;

  @override
  Widget build(BuildContext context) {
    final NumberFormat formatter = NumberFormat("#,###");
    return LabelWidget(
      label: "facilities.createFacility.cbdEquityTierBanks".tr(),
      child: CustomTextField(
        inputFormatters: [
          LengthLimitingTextInputFormatter(15),
          FilteringTextInputFormatter.digitsOnly,
          ThousandsSeparatorFormatter(),
        ],
        controller: viewModel.cbdEquityTier325PercentController,
        prefixIcon: CustomDropdown<Reference>(
          width: 70.w,
          validationMessage: "validation.emptyField".tr(),
          height: null,
          items: viewModel.currencyCodes,
          selectedItems: [
            viewModel.facilityDetail.isNotEmpty
                ? viewModel.facilityDetail.first.cbdEquityTier325PercentCurrency
                : viewModel.currencyCodes.first,
          ],
          onSelected: (selectedValue) {
            if (selectedValue.isNotEmpty) {
              viewModel.getFacility.cbdEquityTier325PercentCurrency =
                  selectedValue.first;
              viewModel.onCurrencyChanged(
                selectedValue.first,
                CurrencyField.cbdEquityTier325Percent,
              );
              viewModel.getCurrencyRates(
                selectedValue.first,
                CurrencyField.cbdEquityTier325Percent,
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
        initialValue: viewModel.facilityDetail.isNotEmpty
            ? formatter.format(
                viewModel.facilityDetail.first.cbdEquityTier325Percent ?? 0,
              )
            : "",
        onChanged: (String? value) {
          if (value != null && value.isNotEmpty) {
            final String cleaned = value.replaceAll(",", "");
            final double amount = double.tryParse(cleaned) ?? 0;
            viewModel.getFacility.cbdEquityTier325Percent = amount;
            final Reference? selected =
                viewModel.getFacility.cbdEquityTier325PercentCurrency;
            final String? selectedCode = selected?.name?.toUpperCase();

            if (selectedCode != ServerConstants.aedCurrency) {
              viewModel.getCurrencyRates(
                selected,
                CurrencyField.cbdEquityTier325Percent,
              );
            } else {
              final String formatted = formatter.format(amount);
              viewModel.newCbdEquityTier325PercentController.value =
                  TextEditingValue(
                text: formatted,
                selection: TextSelection.collapsed(offset: formatted.length),
              );
            }
          }
        },
        onSaved: (amount) {
          viewModel.getFacility.cbdEquityTier325Percent =
              double.tryParse(amount?.replaceAll(",", "") ?? "0");
        },
      ),
    );
  }
}
