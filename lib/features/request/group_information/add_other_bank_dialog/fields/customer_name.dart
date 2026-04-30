import "package:easy_localization/easy_localization.dart";
import "package:flutter/material.dart";
import "package:wcas_frontend/core/components/label.dart";
import "package:wcas_frontend/core/components/textfield.dart";
import "package:wcas_frontend/core/components/tooltip.dart";
import "package:wcas_frontend/core/constants/constants.dart";
import "package:wcas_frontend/features/request/group_information/add_other_bank_dialog/model.dart";
import "package:wcas_frontend/features/request/group_information/add_other_bank_dialog/state.dart";

class CustomerName extends StatelessWidget {
  const CustomerName({required this.viewModel, required this.state, super.key});
  final AddOtherBankDialogViewModel viewModel;
  final AddOtherBankDialogState state;

  @override
  Widget build(BuildContext context) {
    final String initialValue =
        viewModel.selectedCustomer?.concatCustomerFullName ??
            viewModel.selectedCustomer?.customerName ??
            "";
    return LabelWidget(
      label: "groupInformation.facilitiesWithOtherBanks.customerName".tr(),
      isRequired: false,
      showLabel: true,
      child: CustomTooltip(
        message: initialValue,
        child: CustomTextField(
          controller: viewModel.customerController,
          semanticLabel:
              "groupInformation.facilitiesWithOtherBanks.customerName".tr(),
          filled: true,
          readOnly: true,
          initialValue: initialValue,
          fillColor: AppColors.textFieldDisabledFill,
          onChanged: (value) {
            viewModel.selectedCustomer?.customerName = value;
          },
        ),
      ),
    );
  }
}
