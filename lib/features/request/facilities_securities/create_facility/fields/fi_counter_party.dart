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

class FiCounterParty extends StatelessWidget {
  const FiCounterParty({required this.viewModel, super.key});
  final CreateFacilityViewModel viewModel;

  @override
  Widget build(BuildContext context) {
    final NumberFormat formatter = NumberFormat("#,###");
    return LabelWidget(
      label: "facilities.createFacility.counterPartyEquity".tr(),
      child: CustomTextField(
        prefixIcon: CustomDropdown<Reference>(
          width: 70.w,
          validationMessage: "validation.emptyField".tr(),
          height: null,
          items: viewModel.currencyCodes,
          selectedItems: [
            viewModel.facilityDetail.isNotEmpty
                ? viewModel
                    .facilityDetail.first.counterpartyEquity5PercentCurrency
                : viewModel.currencyCodes.first,
          ],
          onSelected: (selectedValue) {
            if (selectedValue.isNotEmpty) {
              viewModel.getFacility.counterpartyEquity5PercentCurrency =
                  (selectedValue.first);
              viewModel.onCurrencyChanged(
                selectedValue.first,
                CurrencyField.counterpartyEquity5Percent,
              );
              viewModel.getCurrencyRates(
                selectedValue.first,
                CurrencyField.counterpartyEquity5Percent,
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
        inputFormatters: [
          LengthLimitingTextInputFormatter(15),
          FilteringTextInputFormatter.digitsOnly,
          ThousandsSeparatorFormatter(),
        ],
        initialValue: viewModel.facilityDetail.isNotEmpty
            ? formatter.format(
                viewModel.facilityDetail.first.counterpartyEquity5Percent ?? 0,
              )
            : "",
        onChanged: (String? value) {
          if (value != null && value.isNotEmpty) {
            final String cleaned = value.replaceAll(",", "");
            final double amount = double.tryParse(cleaned) ?? 0;
            viewModel.getFacility.counterpartyEquity5Percent = amount;
            final Reference? selected =
                viewModel.getFacility.counterpartyEquity5PercentCurrency;
            final String? selectedCode = selected?.name?.toUpperCase();

            if (selectedCode != ServerConstants.aedCurrency) {
              viewModel.getCurrencyRates(
                selected,
                CurrencyField.counterpartyEquity5Percent,
              );
            } else {
              final String formatted = formatter.format(amount);
              viewModel.newCounterpartyEquity5PercentController.value =
                  TextEditingValue(
                text: formatted,
                selection: TextSelection.collapsed(offset: formatted.length),
              );
            }
          }
        },
        onSaved: (amount) {
          viewModel.getFacility.counterpartyEquity5Percent =
              double.tryParse(amount?.replaceAll(",", "") ?? "0");
        },
      ),
    );
  }
}
