import "package:flutter/material.dart";
import "package:wcas_frontend/core/components/dropdown/dropdown.dart";
import "package:wcas_frontend/core/components/dropdown/multi_select_dropdown.dart";
import "package:wcas_frontend/core/components/label.dart";
import "package:wcas_frontend/features/request/facilities_securities/create_security/model.dart";

/// Widget for displaying and managing the current/time deposit account
/// number.
class CurrentTimeDepositAccountNumber extends StatelessWidget {
  /// Creates a current/time deposit account number widget.
  const CurrentTimeDepositAccountNumber({
    required this.viewModel,
    super.key,
  });

  /// View model containing current/time deposit account data and actions.
  final CreateSecurityViewModel viewModel;

  @override
  Widget build(BuildContext context) {
    return LabelWidget(
      label: "Current/Time deposit account number ",
      // isEnabled: !viewModel.isCmoUpdate(),
      child: CustomDropdown<String?>(
        showEditIcon: true,
        items: viewModel.commitmentAccountNumbers,
        selectedItems: [viewModel.security.currentDepositAccountNumber ?? ""],
        onSelected: (selectedValue) async {
          if (selectedValue.isNotEmpty) {
            viewModel.security.currentDepositAccountNumber =
                selectedValue.first;
          }
        },
        onTextChanged: (changedValue) {
          viewModel.security.currentDepositAccountNumber = changedValue;
        },
        itemBuilder: (context, item, {isDisabled, isSelected}) {
          return dropdownMultiItemBuildWidget(
            item,
            isSelected: isSelected ?? false,
          );
        },
        dropdownBuilder: (context, data) {
          return Text(
            data ?? "",
            style: const TextStyle(fontSize: 14),
          );
        },
      ),
    );
  }
}
