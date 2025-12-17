import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:wcas_frontend/core/components/dropdown/dropdown.dart';
import 'package:wcas_frontend/core/components/label.dart';
import 'package:wcas_frontend/features/request/group_information/add_cbrb_dialog/model.dart';
import 'package:wcas_frontend/models/request/customer.dart';

class CustomerRim extends StatelessWidget {
  final AddCbrbDialogViewModel viewModel;
  const CustomerRim({super.key, required this.viewModel});

  @override
  Widget build(BuildContext context) {
    return LabelWidget(
      label: 'groupInformation.facilitiesWithOtherBanks.customerRIM'.tr(),
      isRequired: (viewModel.showCurrentFiCreditRisk) ? false : true,
      showLabel: true,
      child: CustomDropdown<Customer>(
        isEnabled:
            viewModel.selectedCustomer?.customerRimNo == null ? true : false,
        semanticLabel:
            'groupInformation.facilitiesWithOtherBanks.customerRIM'.tr(),
        itemBuilder: (context, item, isDisabled, isSelected) {
          return dropdownItemBuildWidget(item.customerRimNo.toString(),
              isListTile: true, isSelected: isSelected);
        },
        dropdownBuilder: (context, data) {
          return Text(
            data?.customerRimNo.toString() ?? "",
            style: const TextStyle(fontSize: 14),
          );
        },
        items: viewModel.customers,
        onSelected: (selected) {
          viewModel.customerRIMReferenceSelected(selected.first);
        },
        selectedItems: viewModel.selectedCustomer?.customerRimNo == null
            ? null
            : [viewModel.selectedCustomer ?? Customer()],
        validationMessage: (viewModel.showCurrentFiCreditRisk)
            ? ''
            : "requestInformation.requestInformation.requiredField".tr(),
      ),
    );
  }
}
