import "package:easy_localization/easy_localization.dart";
import "package:flutter/material.dart";
import "package:wcas_frontend/core/components/dropdown/dropdown.dart";
import "package:wcas_frontend/core/components/label.dart";
import "package:wcas_frontend/features/request/covenants_conditions/covenant_edit_dialog/model.dart";
import "package:wcas_frontend/models/admin/reference.dart";

class FinancialSubtypeDropdownDesktop extends StatelessWidget {
  const FinancialSubtypeDropdownDesktop({
    required this.viewModel,
    super.key,
    this.forceEmptySelection = false,
  });

  final CovenantEditDialogViewModel viewModel;
  final bool forceEmptySelection;

  @override
  Widget build(BuildContext context) {
    final bool isEnabled =
        viewModel.isFinancialSubtypeEnabled && !viewModel.isReadOnly;

    return LabelWidget(
      isRequired: viewModel.isRequiredBusinessSegment,
      label: "covenantsConditions.covenantEditDialog.covenantSubtype".tr(),
      child: CustomDropdown<Reference>(
        key: const ValueKey("desktop-subtype"),
        hintText: "common.selectValue".tr(),
        isEnabled: isEnabled,
        semanticLabel:
            "covenantsConditions.covenantEditDialog.covenantSubtype".tr(),
        validationMessage: "common.validation.emptyField".tr(),
        items: viewModel.getFilteredFinancialCovenantSubtypes(),
        onSelected: viewModel.onFinancialCovenantSubTypeSelect,
        dropdownBuilder: (context, item) =>
            dropdownBuilderWidget(text: item?.name, showToolTip: false),
        itemBuilder: (context, item, isDisabled, isSelected) {
          return dropdownItemBuildWidget(
            item.name,
            isListTile:
                viewModel.showOnlyNonFinancialSubtypeItems ? false : true,
            isSelected: isSelected,
          );
        },
        // Preserve your existing global-selected behavior for the top block
        selectedItems: viewModel.getSelectedFinancialSubtype(
          viewModel.selectedFinancialCovenantSubType,
          forceEmptySelection,
        ),
      ),
    );
  }
}
