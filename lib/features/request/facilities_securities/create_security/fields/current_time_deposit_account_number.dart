import "package:flutter/material.dart";
import "package:wcas_frontend/core/components/dropdown/dropdown.dart";
import "package:wcas_frontend/core/components/dropdown/multi_select_dropdown.dart";
import "package:wcas_frontend/core/components/label.dart";
import "package:wcas_frontend/features/request/facilities_securities/create_security/model.dart";

class CurrentTimeDepositAccountNumber extends StatelessWidget {
  const CurrentTimeDepositAccountNumber({
    required this.viewModel,
    super.key,
  });
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
        itemBuilder: (context, item, isDisabled, isSelected) {
          return dropdownMultiItemBuildWidget(
            item,
            isSelected: isSelected,
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
