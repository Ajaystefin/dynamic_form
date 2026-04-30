import "package:flutter/material.dart";
import "package:wcas_frontend/core/components/dropdown/dropdown.dart";
import "package:wcas_frontend/core/components/textfield.dart";
import "package:wcas_frontend/core/constants/_server_constants.dart";
import "package:wcas_frontend/features/request/customer_information/customer_info/model.dart";
import "package:wcas_frontend/models/admin/reference.dart";
import "package:wcas_frontend/models/request/customer.dart";

class IdentificationDropdown extends StatelessWidget {
  const IdentificationDropdown({
    required this.owner,
    required this.index,
    required this.viewModel,
    required this.isEnabled,
    super.key,
  });
  final CustomerOwnerShipInfo owner;
  final int index;
  final bool isEnabled;
  final CustomerInfoViewModel viewModel;

  @override
  Widget build(BuildContext context) {
    final items = viewModel.customerIdentificationList;

    final Reference selectedItem =
        Reference(reference1: owner.identificationDetail);

    return isEnabled
        ? CustomDropdown<Reference>(
            key: ValueKey("identification_dropdown_$index"),
            items: items,
            isEnabled: true,
            // validationMessage:

            //         .tr(),
            selectedItems: [selectedItem],
            onSelected: (selectedValue) {
              // Safe Cubit emit without delay or setState
              viewModel.customerOwnerShipInfo?[index].identificationDetail =
                  selectedValue.first.reference1;
            },
            dropdownBuilder: (context, item) => dropdownBuilderWidget(
              text: item?.reference1 ?? "",
              showToolTip: true,
            ),
            itemBuilder: (context, item, isDisabled, isSelected) =>
                dropdownItemBuildWidget(
              item.reference1,
              isListTile: false,
              isSelected: isSelected,
            ),
          )
        : CustomTextField(
            readOnly: true,
            filled: true,
            initialValue:
                (selectedItem.reference2 == ServerConstants.nationalID)
                    ? ServerConstants.emirates
                    : selectedItem.reference1 ?? "",
          );
  }
}
