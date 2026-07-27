import "package:easy_localization/easy_localization.dart";
import "package:flutter/material.dart";
import "package:wcas_frontend/core/components/dropdown/dropdown.dart";
import "package:wcas_frontend/core/components/label.dart";
import "package:wcas_frontend/features/request/projects/link_contract/model.dart";
import "package:wcas_frontend/models/admin/reference.dart";

/// Borrower role dropdown field.
class BorrowerRole extends StatelessWidget {
  /// Creates a borrower role dropdown field.
  const BorrowerRole({required this.viewModel, super.key});

  /// Link contract view model.
  final LinkContractViewModel viewModel;

  @override
  Widget build(BuildContext context) {
    final items = viewModel.borrowerRole;
    final selectedItem = viewModel.selectedBorrowerRole;
    return LabelWidget(
      label: "project.linkContract.borrowerRole".tr(),
      isRequired: true,
      child: CustomDropdown<Reference>(
        isEnabled: viewModel.canEdit,
        key: const ValueKey(
          "requestInformation.requestInformation.exposureStrategy",
        ),
        validationMessage: "project.linkContract.pleaseSelectBorrowerRole".tr(),
        semanticLabel: "project.linkContract.borrowerRole".tr(),
        items: items,
        selectedItems: selectedItem == null ? null : [selectedItem],
        onSelected: (selectedValue) {
          if (selectedValue.isNotEmpty) {
            viewModel.onBorrowerRoleSelected(selectedValue.first);
          }
        },
        itemBuilder: (context, item, {isDisabled, isSelected}) {
          return dropdownItemBuildWidget(
            item.name,
            isSelected: isSelected ?? false,
          );
        },
        dropdownBuilder: (context, data) {
          return Text(
            data?.name ?? "",
            style: const TextStyle(fontSize: 14),
          );
        },
      ),
    );
  }
}
