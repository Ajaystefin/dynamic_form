import "package:easy_localization/easy_localization.dart";
import "package:flutter/material.dart";
import "package:wcas_frontend/core/components/dropdown/dropdown.dart";
import "package:wcas_frontend/core/components/label.dart";
import "package:wcas_frontend/features/request/group_information/add_other_bank_dialog/model.dart";
import "package:wcas_frontend/models/request/customer.dart";

class CustomerRim extends StatelessWidget {
  const CustomerRim({required this.viewModel, super.key});
  final AddOtherBankDialogViewModel viewModel;

  @override
  Widget build(BuildContext context) {
    return LabelWidget(
      label: "groupInformation.facilitiesWithOtherBanks.customerRIM".tr(),
      isRequired: (viewModel.isFiFlow) ? false : true,
      showLabel: true,
      child: CustomDropdown<Customer>(
        semanticLabel:
            "groupInformation.facilitiesWithOtherBanks.customerRIM".tr(),
        itemBuilder: (context, item, isDisabled, isSelected) {
          return dropdownItemBuildWidget(
            item.customerRimNo.toString(),
            isListTile: true,
            isSelected: isSelected,
          );
        },
        dropdownBuilder: (context, data) {
          return Text(
            data?.customerRimNo.toString() ?? "",
            style: const TextStyle(fontSize: 14),
          );
        },
        items: viewModel.customers,
        onSelected: (selected) {
          //widget.viewModel.reconsiderationReferenceValue = selected.first;
          viewModel.customerRIMReferenceSelected(selected.first);
        },
        selectedItems: viewModel.selectedCustomer?.customerRimNo == null
            ? null
            : [viewModel.selectedCustomer ?? Customer()],
        validationMessage:
            (viewModel.isFiFlow) ? "" : "common.validation.requiredField".tr(),
      ),
    );
  }
}
