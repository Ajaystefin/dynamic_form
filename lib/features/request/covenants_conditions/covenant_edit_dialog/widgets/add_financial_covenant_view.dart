import "package:easy_localization/easy_localization.dart";
import "package:flutter/material.dart";
import "package:wcas_frontend/core/components/dropdown/dropdown.dart";
import "package:wcas_frontend/core/components/label.dart";
import "package:wcas_frontend/features/request/covenants_conditions/covenant_edit_dialog/model.dart";
import "package:wcas_frontend/models/admin/reference.dart";
import "package:wcas_frontend/models/request/covenant_condtion/covenant.dart";

class FinancialSubtypeDropdownRow extends StatelessWidget {
  const FinancialSubtypeDropdownRow({
    required this.viewModel,
    required this.row,
    super.key,
    this.isEnabled = true,
  });

  final CovenantEditDialogViewModel viewModel;
  final Covenant row;
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
            dropdownBuilderWidget(text: item?.name, showToolTip: false),
        itemBuilder: (context, item, isDisabled, isSelected) =>
            dropdownItemBuildWidget(
          item.name,
          isListTile: viewModel.showOnlyNonFinancialSubtypeItems ? false : true,
          isSelected: isSelected,
        ),

        // Only use the row's own value — never fall back to VM globals
        selectedItems: (selectedRef != null) ? [selectedRef] : const [],
      ),
    );
  }
}
