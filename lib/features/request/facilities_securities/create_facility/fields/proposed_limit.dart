import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:wcas_frontend/core/components/dropdown/dropdown.dart';
import 'package:wcas_frontend/core/components/dropdown/multi_select_dropdown.dart';
import 'package:wcas_frontend/core/components/label.dart';
import 'package:wcas_frontend/core/components/textfield.dart';
import 'package:wcas_frontend/core/constants/_server_constants.dart';
import 'package:wcas_frontend/core/utils/alert_manager.dart';
import 'package:wcas_frontend/core/utils/scale.dart';
import 'package:wcas_frontend/core/utils/validators.dart';
import 'package:wcas_frontend/features/request/facilities_securities/create_facility/model.dart';
import 'package:wcas_frontend/models/admin/reference.dart';

class ProposedLimit extends StatelessWidget {
  final CreateFacilityViewModel viewModel;
  const ProposedLimit({super.key, required this.viewModel});

  @override
  Widget build(BuildContext context) {
    final bool hasCountryCodes = viewModel.countryCodes.isNotEmpty;
    final Reference? selectedCurrency = viewModel.facility.presentLimitValue;
    return LabelWidget(
      label: 'facilities.createFacility.proposedLimit'.tr(),
      isRequired: !viewModel.showFacilityFi,
      child: CustomTextField(
        inputFormatters: [
          LengthLimitingTextInputFormatter(21),
          FilteringTextInputFormatter.digitsOnly,
          if (viewModel.isSubLimitMode)
            MaxValueTextInputFormatter(viewModel.maxInputInSelectedCurrency),
        ],

        prefixIcon: CustomDropdown<Reference>(
          width: 70.w,
          height: null,
          validationMessage:
              !viewModel.showFacilityFi ? "validation.emptyField".tr() : null,
          items: viewModel.countryCodes,
          selectedItems: (selectedCurrency != null)
              ? [selectedCurrency]
              : (hasCountryCodes ? [viewModel.countryCodes.first] : []),
          onSelected: (selectedValue) {
            if (selectedValue.isNotEmpty) {
              viewModel.facility.proposedLimitValue = (selectedValue.first);
              viewModel.onCurrencyChanged(selectedValue.first);
              viewModel.getCurrencyRates(selectedValue.first);
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
        keyboardType: TextInputType.number,

        validator: (String? value) {
          final String? req = !viewModel.showFacilityFi
              ? CustomValidator.requiredField(value)
              : null;
          final String? cap = viewModel.validateProposedLimit(value);
          return req ?? cap;
        },
        onChanged: (String? value) {
          if (value != null && value.isNotEmpty) {
            final formatter = NumberFormat('#,###');
            final cleaned = value.replaceAll(',', '');
            final int amount = int.tryParse(cleaned) ?? 0;

            if (viewModel.isSubLimitMode &&
                viewModel.exceedsParentLimit(amount)) {
              AlertManager().showWarningToast(
                'Proposed limit exceeds parent limit',
              );
              return;
            }

            viewModel.facility.proposedLimit = amount;

            final selected = viewModel.facility.proposedLimitValue;
            final selectedCode = selected?.name?.toUpperCase();

            if (selectedCode != ServerConstants.aedCurrency) {
              viewModel.getCurrencyRates(selected);
            } else {
              final formatted = formatter.format(amount);
              viewModel.newProposedFacilityAmountController.value =
                  TextEditingValue(
                text: formatted,
                selection: TextSelection.collapsed(offset: formatted.length),
              );
            }
          }
        },
        onSaved: (String? value) {
          // viewModel.facility.proposedLimit =value.toString();
          // double.tryParse(value.toString());
        },
      ),
    );
  }
}
