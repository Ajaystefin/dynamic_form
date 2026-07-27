import "package:easy_localization/easy_localization.dart";
import "package:flutter/material.dart";
import "package:wcas_frontend/core/components/dropdown/dropdown.dart";
import "package:wcas_frontend/core/components/label.dart";
import "package:wcas_frontend/features/request/projects/edit_contract/model.dart";
import "package:wcas_frontend/models/admin/reference.dart";

/// Borrower role field.
class BorrowerRole extends StatelessWidget {
  /// Creates a borrower role field.
  const BorrowerRole({required this.viewModel, super.key});

  /// Edit contract view model.
  final EditContractViewModel viewModel;

  @override
  Widget build(BuildContext context) {
    final items = viewModel.borrowerRole;
    final selectedItem = viewModel.selectedBorrowerRole;
    return LabelWidget(
      label: "project.linkContract.borrowerRole".tr(),
      isRequired: true,
      child: CustomDropdown<Reference>(
        isEnabled: false, //(viewModel.canEdit ?? false) ? true : false,
        validationMessage: "project.linkContract.pleaseSelectBorrowerRole".tr(),
        semanticLabel: "project.linkContract.borrowerRole".tr(),
        items: items,
        selectedItems: selectedItem == null ? null : [selectedItem],
        hintText: "Select Role",
        itemBuilder: (context, item, {isDisabled, isSelected}) {
          return dropdownItemBuildWidget(
            item.name,
            isSelected: isSelected ?? false,
          );
        },
        onSelected: (selectedValue) {
          viewModel.onBorrowerRoleSelected(selectedValue.first);
        },
        dropdownBuilder: (context, item) =>
            dropdownBuilderWidget(text: item?.name),
      ),
    );
  }
}
