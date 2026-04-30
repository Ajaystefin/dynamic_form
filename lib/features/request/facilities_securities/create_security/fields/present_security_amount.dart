import "package:easy_localization/easy_localization.dart";
import "package:flutter/material.dart";
import "package:flutter/services.dart";
import "package:wcas_frontend/core/components/dropdown/dropdown.dart";
import "package:wcas_frontend/core/components/label.dart";
import "package:wcas_frontend/core/components/textfield.dart";
import "package:wcas_frontend/core/constants/_server_constants.dart";
import "package:wcas_frontend/core/utils/scale.dart";
import "package:wcas_frontend/core/utils/utils.dart";
import "package:wcas_frontend/features/request/facilities_securities/create_security/model.dart";
import "package:wcas_frontend/models/admin/reference.dart";

class PresentSecurityAmount extends StatelessWidget {
  const PresentSecurityAmount({required this.viewModel, super.key});
  final CreateSecurityViewModel viewModel;

  @override
  @override
  Widget build(BuildContext context) {
    final formatter = NumberFormat("#,###"); // For comma formatting
    return LabelWidget(
      label: viewModel.securityProviderLabel(isPresent: true),
      isEnabled: (viewModel.security.securityType?.id ==
              ServerConstants
                  .securityTypeId[SecurityType.assignmentOfInsurancess]) &&
          (!viewModel.isParipassu),
      child: CustomTextField(
        controller: viewModel.presentSecurityAmountController,
        filled: !((viewModel.security.securityType?.id ==
                ServerConstants
                    .securityTypeId[SecurityType.assignmentOfInsurancess]) &&
            (!viewModel.isParipassu)),
        readOnly: viewModel.isCmoUpdate() ||
            !((viewModel.security.securityType?.id ==
                    ServerConstants.securityTypeId[
                        SecurityType.assignmentOfInsurancess]) &&
                (!viewModel.isParipassu)),
        initialValue: (viewModel.security.presentSecurityAmount == null ||
                viewModel.security.presentSecurityAmount == 0)
            ? "0"
            : formatter
                .format(viewModel.security.presentSecurityAmount!.toInt()),
        inputFormatters: [
          LengthLimitingTextInputFormatter(15),
          FilteringTextInputFormatter.digitsOnly,
        ],
        hintText: "0",
        onSaved: (String? value) {
          viewModel.security.presentSecurityAmount = double.tryParse(
            value?.replaceAll(",", "") ?? "0",
          );

          viewModel.security.aedPresentSecurity = double.tryParse(
                viewModel.newPresentSecurityAmountController.text
                    .replaceAll(",", ""),
              ) ??
              double.tryParse(
                value?.replaceAll(",", "") ?? "0",
              );
        },
        onChanged: (String? value) {
          if (value != null && value.isNotEmpty) {
            final String cleaned = value.replaceAll(",", "");
            final double amount = double.tryParse(cleaned) ?? 0;

            viewModel.security.presentSecurityAmount = amount;

            // Format entered amount
            final String formatted = formatter.format(amount.toInt());
            viewModel.presentSecurityAmountController.value = TextEditingValue(
              text: formatted,
              selection: TextSelection.collapsed(offset: formatted.length),
            );

            //  Trigger conversion update
            viewModel.getCurrencyRates(
              viewModel.security.presentSecurityAmtCurrency,
              true,
            );
          }
        },
        textStyle: const TextStyle(fontSize: 14),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
        prefixIcon: CustomDropdown<Reference>(
          isEnabled: false,
          width: 70.w,
          height: null,
          validationMessage: "validation.emptyField".tr(),
          items: viewModel.currencyCodes,
          selectedItems: [
            viewModel.currencyCodes.isNotEmpty
                ? viewModel.security.presentSecurityAmtCurrency ??
                    viewModel.currencyCodes.first
                : Reference(),
          ],
          onSelected: (selectedValue) {
            if (selectedValue.isNotEmpty) {
              viewModel.security.presentSecurityAmtCurrency =
                  selectedValue.first;
              viewModel.onCurrencyChanged(selectedValue.first, true);
              viewModel.getCurrencyRates(selectedValue.first, true);
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
      ),
    );
  }
}
