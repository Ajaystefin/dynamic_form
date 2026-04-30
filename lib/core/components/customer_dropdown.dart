import "package:easy_localization/easy_localization.dart";
import "package:flutter/material.dart";
import "package:wcas_frontend/core/components/dropdown/dropdown.dart";
import "package:wcas_frontend/core/components/gap.dart";
import "package:wcas_frontend/core/components/label.dart";
import "package:wcas_frontend/core/components/textfield.dart";
import "package:wcas_frontend/core/globals.dart";
import "package:wcas_frontend/core/utils/utils.dart";
import "package:wcas_frontend/models/request/customer.dart";

class CustomCustomerDropdown extends StatelessWidget {
  const CustomCustomerDropdown({
    required this.onCustomerChange,
    required this.onRefresh,
    super.key,
    this.selectedCustomer,
    this.customerList,
  });
  final Function(Customer) onCustomerChange;
  final Function() onRefresh;
  final Customer? selectedCustomer;
  final List<Customer>? customerList;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Expanded(
          child: LabelWidget(
            label: "customerInformation.customerInformation.customerRim".tr(),
            isRequired: true,
            child: Utils.isGroupApplication()
                ? CustomDropdown<Customer>(
                    semanticLabel:
                        "customerInformation.customerInformation.customerRim"
                            .tr(),
                    validationMessage: "",
                    items: customerList ?? Globals.request?.customers ?? [],
                    onSelected: (selectedCustomer) {
                      if (selectedCustomer.isNotEmpty) {
                        onCustomerChange(selectedCustomer.first);
                      }
                    },
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
                        style: const TextStyle(fontSize: 13),
                      );
                    },
                    selectedItems:
                        selectedCustomer != null ? [selectedCustomer] : [],
                  )
                : CustomTextField(
                    initialValue: '${selectedCustomer?.customerRimNo ?? ''}',
                    filled: true,
                    readOnly: true,
                  ),
          ),
        ),
        const Gap(direction: Axis.horizontal),
        const Expanded(child: SizedBox()),
        const Expanded(child: SizedBox()),
      ],
    );
  }
}
