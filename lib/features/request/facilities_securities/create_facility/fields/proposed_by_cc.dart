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

class FacilityProposedByCC extends StatelessWidget {
  const FacilityProposedByCC({required this.viewModel, super.key});
  final CreateFacilityViewModel viewModel;

  @override
  Widget build(BuildContext context) {
    final NumberFormat formatter = NumberFormat("#,###");

    final Reference selectedCurrency = viewModel.isFIFlow
        ? viewModel.currencyCodes.first
        : Reference(
            name: viewModel.getFacility.proposedByCcCurrency ??
                ServerConstants.aedCurrency,
          );

    return LabelWidget(
      label: "facilities.createFacility.proposedByCC".tr(),
      child: CustomTextField(
        inputFormatters: [
          LengthLimitingTextInputFormatter(15),
          FilteringTextInputFormatter.digitsOnly,
          ThousandsSeparatorFormatter(),
        ],
        prefixIcon: CustomDropdown<Reference>(
          isEnabled: viewModel.isEditableForProposedByCC(),
          width: 70.w,
          height: null,
          validationMessage: "validation.emptyField".tr(),
          items: viewModel.currencyCodes,
          selectedItems: [selectedCurrency],
          onSelected: (selectedValue) {
            if (selectedValue.isNotEmpty) {
              viewModel.getFacility.proposedByCcCurrency =
                  selectedValue.first.name;

              viewModel
                ..onCurrencyChanged(
                  selectedValue.first,
                  CurrencyField.proposedBycc,
                )
                ..getCurrencyRates(
                  selectedValue.first,
                  CurrencyField.proposedBycc,
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
        controller: viewModel.proposedByccController,
        initialValue: (!viewModel.showCreateFacilityForm &&
                viewModel.facilityDetail.isNotEmpty &&
                !viewModel.isFIFlow)
            ? viewModel.facilityDetail.first.proposedByCc?.toString() ?? ""
            : "",
        filled: !viewModel.isEditableForProposedByCC(),
        readOnly: !viewModel.isEditableForProposedByCC(),
        keyboardType: TextInputType.number,
        onChanged: (String? value) {
          if (value != null && value.isNotEmpty) {
            final String cleaned = value.replaceAll(",", "");
            final int amount = int.tryParse(cleaned) ?? 0;

            viewModel.getFacility.proposedByCc = amount.toDouble();

            final Reference? selected = viewModel
                        .getFacility.proposedByCcCurrency !=
                    null
                ? Reference(name: viewModel.getFacility.proposedByCcCurrency)
                : null;

            final String? selectedCode = selected?.name?.toUpperCase();

            if (selectedCode != ServerConstants.aedCurrency) {
              viewModel.getCurrencyRates(
                selected,
                CurrencyField.proposedBycc,
              );
            } else {
              final String formatted = formatter.format(amount);
              viewModel.proposedByccController.value = TextEditingValue(
                text: formatted,
                selection: TextSelection.collapsed(offset: formatted.length),
              );
            }
          }
        },
        onSaved: (String? value) {
          viewModel.getFacility.proposedByCc =
              double.tryParse(value?.replaceAll(",", "") ?? "0") ?? 0;
        },
      ),
    );
  }
}
