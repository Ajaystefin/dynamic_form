import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:wcas_frontend/core/components/dropdown/dropdown.dart';
import 'package:wcas_frontend/core/components/textfield.dart';
import 'package:wcas_frontend/core/constants/_server_constants.dart';
import 'package:wcas_frontend/features/request/customer_information/customer_info/model.dart';
import 'package:wcas_frontend/models/request/customer.dart';

class IdentificationDropdown extends StatelessWidget {
  final CustomerOwnerShipInfo owner;
  final int index;
  final bool isEnabled;
  final CustomerInfoViewModel viewModel;

  const IdentificationDropdown({
    super.key,
    required this.owner,
    required this.index,
    required this.viewModel,
    required this.isEnabled,
  });

  @override
  Widget build(BuildContext context) {
    final items = [
      "customerInformation.customerInformation.tradeLicense".tr(),
      "customerInformation.customerInformation.certificateOfRegisteration".tr(),
      "customerInformation.customerInformation.emiratesId".tr(),
      "customerInformation.customerInformation.passportNo".tr(),
    ];

    final selectedItem = owner.identificationDetail;

    return isEnabled
        ? CustomDropdown<String>(
            key: ValueKey("identification_dropdown_$index"),
            items: items,
            isEnabled: true,
            // validationMessage:
            //     "customerInformation.customerInformation.selectIdentificationType"
            //         .tr(),
            selectedItems: selectedItem != null && items.contains(selectedItem)
                ? [selectedItem]
                : [],
            onSelected: (selectedValue) {
              // Safe Cubit emit without delay or setState
              viewModel.customerOwnerShipInfo?[index].identificationDetail =
                  selectedValue.first;
            },
            dropdownBuilder: (context, item) =>
                dropdownBuilderWidget(text: item ?? '', showToolTip: true),
            itemBuilder: (context, item, isDisabled, isSelected) =>
                dropdownItemBuildWidget(item,
                    isListTile: false, isSelected: isSelected),
          )
        : CustomTextField(
            readOnly: true,
            filled: true,
            initialValue: selectedItem.toString() ==ServerConstants.nationalID 
                ? ServerConstants.emirates
                : selectedItem ?? '',
          );
  }
}
