import "package:easy_localization/easy_localization.dart";
import "package:flutter/material.dart";
import "package:wcas_frontend/core/components/dropdown/dropdown.dart";
import "package:wcas_frontend/core/components/label.dart";
import "package:wcas_frontend/core/utils/utils.dart";
import "package:wcas_frontend/features/request/group_information/add_other_bank_dialog/model.dart";
import "package:wcas_frontend/models/request/customer.dart";

/// Customer RIM field widget.
class CustomerRim extends StatelessWidget {
  /// Creates a [CustomerRim] widget.
  const CustomerRim({required this.viewModel, super.key});

  /// View model used by the widget.
  final AddOtherBankDialogViewModel viewModel;

  @override
  Widget build(BuildContext context) {
    final int? rimNo = viewModel.selectedCustomer?.customerRimNo;
    final bool hasExistingRim =
        viewModel.isHasRimYes || (rimNo != null && rimNo != 0 && rimNo != -1);
    return LabelWidget(
      label: "groupInformation.facilitiesWithOtherBanks.customerRIM".tr(),
      isRequired: !viewModel.isFiFlow,
      child: CustomDropdown<Customer>(
        isEnabled: (viewModel.isAddNew)
            ? viewModel.isHasRimYes
            : viewModel.isHasRimYes && hasExistingRim,
        semanticLabel:
            "groupInformation.facilitiesWithOtherBanks.customerRIM".tr(),
        itemBuilder: (context, item, {isDisabled, isSelected}) {
          return dropdownItemBuildWidget(
            Utils.getValidRimNo(item.customerRimNo),
            isSelected: isSelected ?? false,
          );
        },
        dropdownBuilder: (context, item) {
          return Text(
            Utils.getValidRimNo(item?.customerRimNo),
            style: const TextStyle(fontSize: 14),
          );
        },
        items: viewModel.customers,
        onSelected: (selected) {
          //widget.viewModel.reconsiderationReferenceValue = selected.first;
          viewModel.customerRIMReferenceSelected(selected.first);
        },
        selectedItems: viewModel.selectedCustomer != null
            ? [viewModel.selectedCustomer]
            : null,
        // selectedItems:
        //     !hasExistingRim ? null : [viewModel.selectedCustomer ?? Customer()],
        validationMessage:
            (viewModel.isFiFlow) ? "" : "common.validation.requiredField".tr(),
      ),
    );
  }
}
