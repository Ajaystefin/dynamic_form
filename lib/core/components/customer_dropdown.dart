import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:wcas_frontend/core/components/dropdown/dropdown.dart';
import 'package:wcas_frontend/core/components/gap.dart';
import 'package:wcas_frontend/core/components/label.dart';
import 'package:wcas_frontend/core/components/textfield.dart';
// import 'package:wcas_frontend/core/components/tooltip.dart';
import 'package:wcas_frontend/core/globals.dart';
import 'package:wcas_frontend/core/utils/utils.dart';
import 'package:wcas_frontend/models/request/customer.dart';

class CustomCustomerDropdown extends StatelessWidget {
  final Function(Customer) onCustomerChange;
  final Function() onRefresh;
  final Customer? selectedCustomer;
  final List<Customer>? customerList;

  const CustomCustomerDropdown({
    super.key,
    required this.onCustomerChange,
    required this.onRefresh,
    this.selectedCustomer,
    this.customerList,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Expanded(
          child: LabelWidget(
            label: 'customerInformation.customerInformation.customerName'.tr(),
            isRequired: true,
            child: Utils.isGroupApplication()
                ? CustomDropdown<Customer>(
                    semanticLabel:
                        'customerInformation.customerInformation.customerName'
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
                          item.displayName ?? item.preferredName ?? "",
                          isListTile: true,
                          isSelected: isSelected);
                    },
                    dropdownBuilder: (context, data) {
                      return Text(
                        data?.displayName ?? data?.preferredName ?? "",
                        style: const TextStyle(fontSize: 13),
                      );
                    },
                    selectedItems:
                        selectedCustomer != null ? [selectedCustomer] : [],
                  )
                : CustomTextField(
                    initialValue: selectedCustomer?.displayName ??
                        selectedCustomer?.preferredName ??
                        "",
                    filled: true,
                    readOnly: true,
                  ),
          ),
        ),
        const Gap(direction: Axis.horizontal),
        // Utils.isGroupApplication()
        //     ? SizedBox(
        //         width: 50,
        //         child: CustomTooltip(
        //           message: "Refresh",
        //           child: LabelWidget(
        //             label: " ",
        //             child: InkWell(
        //               onTap: onRefresh,
        //               child: Container(
        //                 decoration: BoxDecoration(border: Border.all()),
        //                 child: const Icon(Icons.refresh),
        //               ),
        //             ),
        //           ),
        //         ),
        //       )
        //     : const SizedBox(),
        const Expanded(child: SizedBox()),
        const Expanded(child: SizedBox()),
      ],
    );
  }
}
