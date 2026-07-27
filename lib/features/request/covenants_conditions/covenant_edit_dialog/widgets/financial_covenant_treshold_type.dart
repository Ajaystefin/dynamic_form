import "package:easy_localization/easy_localization.dart";
import "package:flutter/material.dart";
import "package:wcas_frontend/core/components/dropdown/dropdown.dart";
import "package:wcas_frontend/core/components/label.dart";
import "package:wcas_frontend/core/constants/_reference_data_keys.dart";
import "package:wcas_frontend/features/request/covenants_conditions/covenant_edit_dialog/model.dart";
import "package:wcas_frontend/models/admin/reference.dart";
import "package:wcas_frontend/models/request/covenant_condtion/covenant.dart";

/// Financial covenant threshold type field for the covenant edit dialog.
class FinancialCovenantTresholdType extends StatelessWidget {
  /// Creates a financial covenant threshold type field.
  const FinancialCovenantTresholdType({
    required this.viewModel,
    super.key,
    this.row,
    this.isEnabled = false,
    this.selectedItem,
    this.forceEmptySelection = false,
  });

  /// Covenant edit dialog view model.
  final CovenantEditDialogViewModel viewModel;

  /// Covenant row data.
  final Covenant? row;

  /// Whether the threshold type dropdown is enabled.
  final bool isEnabled;

  /// Selected threshold type item.
  final Reference? selectedItem;

  /// Whether to force empty selection.
  final bool forceEmptySelection;

  @override
  Widget build(BuildContext context) {
    final Reference? rowSelectedRef =
        (row != null) ? viewModel.findThresholdById(row!.thresholdType) : null;

    final bool shouldRequire = row != null
        ? viewModel.shouldRequireRowThresholdType(row!)
        : viewModel.shouldRequireMainThresholdType;
    return LabelWidget(
      label: "covenantsConditions.covenantEditDialog.thresholdType".tr(),
      isRequired: shouldRequire,
      child: CustomDropdown<Reference>(
        hintText: "common.selectValue".tr(),
        isEnabled: isEnabled && !viewModel.isReadOnly,
        semanticLabel:
            "covenantsConditions.covenantEditDialog.thresholdType".tr(),
        validationMessage:
            shouldRequire ? "common.validation.emptyField".tr() : null,
        items: viewModel.referenceData[ReferenceDataKeys.thresholdType] ?? [],
        onSelected: (selectedValue) {
          if (selectedValue.isEmpty) {
            return;
          }
          if (row != null) {
            row!.thresholdType = selectedValue.first.id;
          } else {
            viewModel.selectedThreshold = selectedValue.first;
            viewModel.covenant?.thresholdType = viewModel.selectedThreshold?.id;
          }
        },
        dropdownBuilder: (context, item) =>
            dropdownBuilderWidget(text: item?.name),
        itemBuilder: (context, item, {isDisabled, isSelected}) {
          return dropdownItemBuildWidget(
            item.name,
            isSelected: isSelected ?? false,
          );
        },
        selectedItems: row != null
            ? (rowSelectedRef != null ? [rowSelectedRef] : const [])
            : viewModel.getSelectedThreshold(
                selectedItem,
                forceEmpty: forceEmptySelection,
              ),
      ),
    );
  }
}
