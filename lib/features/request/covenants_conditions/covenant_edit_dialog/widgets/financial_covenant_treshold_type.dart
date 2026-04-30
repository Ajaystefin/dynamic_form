import "package:easy_localization/easy_localization.dart";
import "package:flutter/material.dart";
import "package:wcas_frontend/core/components/dropdown/dropdown.dart";
import "package:wcas_frontend/core/components/label.dart";
import "package:wcas_frontend/core/constants/_reference_data_keys.dart";
import "package:wcas_frontend/features/request/covenants_conditions/covenant_edit_dialog/model.dart";
import "package:wcas_frontend/models/admin/reference.dart";
import "package:wcas_frontend/models/request/covenant_condtion/covenant.dart";

class FinancialCovenantTresholdType extends StatelessWidget {
  const FinancialCovenantTresholdType({
    required this.viewModel,
    super.key,
    this.row, // NEW: per-row
    this.isEnabled = false,
    this.selectedItem,
    this.forceEmptySelection = false,
  });

  final CovenantEditDialogViewModel viewModel;
  final Covenant? row; // NEW
  final bool isEnabled;
  final Reference? selectedItem;
  final bool forceEmptySelection;

  @override
  Widget build(BuildContext context) {
    final Reference? rowSelectedRef =
        (row != null) ? viewModel.findThresholdById(row!.thresholdType) : null;

    final bool isTextFieldReq = viewModel.isThresholdTypeTextFieldRequired;

    return LabelWidget(
      label: "covenantsConditions.covenantEditDialog.thresholdType".tr(),
      isRequired: isTextFieldReq ? true : false,
      child: CustomDropdown<Reference>(
        hintText: "common.selectValue".tr(),
        isEnabled: isEnabled && !viewModel.isReadOnly,
        semanticLabel:
            "covenantsConditions.covenantEditDialog.thresholdType".tr(),
        validationMessage: "common.validation.emptyField".tr(),
        items: viewModel.referenceData[ReferenceDataKeys.thresholdType] ?? [],
        onSelected: (selectedValue) {
          if (selectedValue.isEmpty) return;
          if (row != null) {
            row!.thresholdType = selectedValue.first.id;
          } else {
            viewModel.selectedThreshold = selectedValue.first;
            viewModel.covenant?.thresholdType = viewModel.selectedThreshold?.id;
          }
        },
        dropdownBuilder: (context, item) =>
            dropdownBuilderWidget(text: item?.name, showToolTip: false),
        itemBuilder: (context, item, isDisabled, isSelected) {
          return dropdownItemBuildWidget(
            item.name,
            isListTile: true,
            isSelected: isSelected,
          );
        },
        selectedItems: row != null
            ? (rowSelectedRef != null ? [rowSelectedRef] : const [])
            : viewModel.getSelectedThreshold(selectedItem, forceEmptySelection),
      ),
    );
  }
}
