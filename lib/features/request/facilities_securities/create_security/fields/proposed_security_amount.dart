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

class ProposedSecurityAmount extends StatelessWidget {
  const ProposedSecurityAmount({required this.viewModel, super.key});
  final CreateSecurityViewModel viewModel;

  @override
  Widget build(BuildContext context) {
    final formatter = NumberFormat("#,###"); // For comma formatting

    return LabelWidget(
      isRequired: true,
      isEnabled:
          // Disabled for Receivables
          (viewModel.security.securityType?.id !=
                  ServerConstants
                      .securityTypeId[SecurityType.assignmentOfReceivables])
              // Enabled for Insurances only when Pari-passu is false; otherwise
              // enabled for other types by default
              &&
              (viewModel.security.securityType?.id !=
                      ServerConstants.securityTypeId[
                          SecurityType.assignmentOfInsurancess] ||
                  !viewModel.isParipassu),
      label: viewModel.securityProviderLabel(isPresent: false),
      child: CustomTextField(
        filled: !((viewModel.security.securityType?.id !=
                ServerConstants
                    .securityTypeId[SecurityType.assignmentOfReceivables]) &&
            (viewModel.security.securityType?.id !=
                    ServerConstants
                        .securityTypeId[SecurityType.assignmentOfInsurancess] ||
                !viewModel.isParipassu)),
        readOnly: viewModel.isCmoUpdate() ||
            !((viewModel.security.securityType?.id !=
                    ServerConstants.securityTypeId[
                        SecurityType.assignmentOfReceivables]) &&
                (viewModel.security.securityType?.id !=
                        ServerConstants.securityTypeId[
                            SecurityType.assignmentOfInsurancess] ||
                    !viewModel.isParipassu)),
        initialValue: (viewModel.security.proposedSecurityAmount == null ||
                viewModel.security.proposedSecurityAmount == 0)
            ? "0"
            : formatter
                .format(viewModel.security.proposedSecurityAmount!.toInt()),
        inputFormatters: [
          LengthLimitingTextInputFormatter(15),
          FilteringTextInputFormatter.digitsOnly,
        ],
        onChanged: (String? value) {
          if (value != null && value.isNotEmpty) {
            final String cleaned = value.replaceAll(",", "");
            final double amount = double.tryParse(cleaned) ?? 0;
            viewModel.security.proposedSecurityAmount = amount;
            // Format entered amount
            final String formatted = formatter.format(amount.toInt());
            viewModel.proposedSecurityAmountController.value = TextEditingValue(
              text: formatted,
              selection: TextSelection.collapsed(offset: formatted.length),
            );

            //  Trigger conversion update
            viewModel.getCurrencyRates(
              viewModel.security.proposedSecurityAmtCurrency,
              false,
              proposedAmount: amount,
            );
          }
        },
        hintText: "0",
        onSaved: (String? value) {
          viewModel.security.aedProposedSecurity = double.tryParse(
                viewModel.newProposedSecurityAmountController.text
                    .replaceAll(",", ""),
              ) ??
              double.tryParse(value?.replaceAll(",", "") ?? "0");

          viewModel.security.proposedSecurityAmount =
              double.tryParse(value?.replaceAll(",", "") ?? "0");
        },
        controller: viewModel.proposedSecurityAmountController,
        prefixIcon: CustomDropdown<Reference>(
          width: 70.w,
          height: null,
          validationMessage: "validation.emptyField".tr(),
          items: viewModel.currencyCodes,
          selectedItems: [
            viewModel.currencyCodes.isNotEmpty
                ? (viewModel.security.proposedSecurityAmtCurrency ??
                    viewModel.currencyCodes.first)
                : Reference(),
          ],
          onSelected: (selectedValue) {
            if (selectedValue.isNotEmpty) {
              viewModel.onCurrencyChanged(selectedValue.first, false);
              viewModel.getCurrencyRates(
                selectedValue.first,
                false,
                proposedAmount: viewModel.security.proposedSecurityAmount,
              );
            }
          },
          itemBuilder: (context, item, isDisabled, isSelected) {
            return ListTile(title: Text(item.name ?? ""));
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
