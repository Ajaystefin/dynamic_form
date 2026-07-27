import "package:easy_localization/easy_localization.dart";
import "package:flutter/material.dart";
import "package:wcas_frontend/core/components/dropdown/dropdown.dart";
import "package:wcas_frontend/core/components/gap.dart";
import "package:wcas_frontend/core/components/label.dart";
import "package:wcas_frontend/core/components/textfield.dart";
import "package:wcas_frontend/core/globals.dart";
import "package:wcas_frontend/core/utils/utils.dart";
import "package:wcas_frontend/models/request/customer.dart";

/// Customer selection dropdown widget.
class CustomCustomerDropdown extends StatelessWidget {
  /// Creates a [CustomCustomerDropdown].
  const CustomCustomerDropdown({
    required this.onCustomerChange,
    required this.onRefresh,
    super.key,
    this.selectedCustomer,
    this.customerList,
    this.ignoreProvider = false,
  });

  /// Callback invoked when the selected customer changes.
  final Function(Customer) onCustomerChange;

  /// Callback invoked to refresh customer data.
  final Function() onRefresh;

  /// Currently selected customer.
  final Customer? selectedCustomer;

  /// Available customers.
  final List<Customer>? customerList;

  /// Ignores form access restrictions when enabled.
  final bool ignoreProvider;

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
                    ignoreProvider: ignoreProvider,
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
                    itemBuilder: (context, item, {isDisabled, isSelected}) {
                      return dropdownItemBuildWidget(
                        item.customerRimNo.toString(),
                        isSelected: isSelected ?? false,
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
