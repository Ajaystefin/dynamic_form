import "package:easy_localization/easy_localization.dart";
import "package:flutter/material.dart";
import "package:wcas_frontend/core/components/dropdown/dropdown.dart";
import "package:wcas_frontend/core/components/label.dart";
import "package:wcas_frontend/core/constants/constants.dart";
import "package:wcas_frontend/features/request/covenants_conditions/covenant_edit_dialog/model.dart";
import "package:wcas_frontend/models/admin/reference.dart";
import "package:wcas_frontend/models/request/covenant_condtion/covenant.dart";

/// Financial subtype dropdown row for the covenant edit dialog.
class FinancialSubtypeDropdownRow extends StatelessWidget {
  /// Creates a financial subtype dropdown row.
  const FinancialSubtypeDropdownRow({
    required this.viewModel,
    required this.row,
    super.key,
    this.isEnabled = true,
  });

  /// Covenant edit dialog view model.
  final CovenantEditDialogViewModel viewModel;

  /// Covenant row data.
  final Covenant row;

  /// Whether the dropdown is enabled.
  final bool isEnabled;

  @override
  Widget build(BuildContext context) {
    final Reference? selectedRef =
        viewModel.findFinancialSubtypeById(row.covenantSubType);

    return LabelWidget(
      isRequired: viewModel.isRequiredBusinessSegment,
      label: "covenantsConditions.covenantEditDialog.covenantSubtype".tr(),
      child: CustomDropdown<Reference>(
        // IMPORTANT: keep a stable key per row; don't include subtype in the
        // key
        key: ValueKey("row-subtype-${row.hashCode}"),
        hintText: "common.selectValue".tr(),
        isEnabled: isEnabled && !viewModel.isReadOnly,
        semanticLabel:
            "covenantsConditions.covenantEditDialog.covenantSubtype".tr(),
        validationMessage: "common.validation.emptyField".tr(),
        items: viewModel.getFilteredFinancialCovenantSubtypes(),

        // Delegate to VM (same structure as desktop)
        onSelected: (refs) =>
            viewModel.onRowFinancialCovenantSubTypeSelect(row, refs),

        dropdownBuilder: (context, item) =>
            dropdownBuilderWidget(text: item?.name),
        itemBuilder: (context, item, {isDisabled, isSelected}) => Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 12),
          color: (isSelected ?? false)
              ? AppColors.textFieldDisabledFillDarker
              : null,
          child: Text(
            item.name ?? "",
            softWrap: true,
            overflow: TextOverflow.visible,
            style: const TextStyle(fontSize: 12),
          ),
        ),

        // Only use the row's own value — never fall back to VM globals
        selectedItems: (selectedRef != null) ? [selectedRef] : const [],
      ),
    );
  }
}
