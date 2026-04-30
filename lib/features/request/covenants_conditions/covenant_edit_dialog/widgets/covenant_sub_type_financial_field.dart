import "package:easy_localization/easy_localization.dart";
import "package:flutter/material.dart";
import "package:wcas_frontend/core/components/dropdown/dropdown.dart";
import "package:wcas_frontend/core/components/label.dart";
import "package:wcas_frontend/features/request/covenants_conditions/covenant_edit_dialog/model.dart";
import "package:wcas_frontend/models/admin/reference.dart";

class CovenantSubTypeFinancialField extends StatelessWidget {
  const CovenantSubTypeFinancialField({
    required this.viewModel,
    super.key,
    this.selectedItem,
    this.forceEmptySelection = false,
    this.overrideEnablement,
    this.onSelectedOverride,
  });

  final CovenantEditDialogViewModel viewModel;
  final Reference? selectedItem;
  final bool forceEmptySelection;
  final bool? overrideEnablement;
  final void Function(List<Reference>)? onSelectedOverride;

  @override
  Widget build(BuildContext context) {
    final bool isEnabled =
        overrideEnablement ?? viewModel.isFinancialSubtypeEnabled;
    return LabelWidget(
      isRequired: viewModel.isRequiredBusinessSegment,
      label: "covenantsConditions.covenantEditDialog.covenantSubtype".tr(),
      child: CustomDropdown<Reference>(
        showHoverColor: true,
        key: ValueKey<bool>(forceEmptySelection),
        hintText: "common.selectValue".tr(),
        isEnabled: isEnabled && !viewModel.isReadOnly,
        semanticLabel:
            "covenantsConditions.covenantEditDialog.covenantSubtype".tr(),
        validationMessage: "common.validation.emptyField".tr(),
        items: viewModel.getFilteredFinancialCovenantSubtypes(),
        onSelected:
            onSelectedOverride ?? viewModel.onFinancialCovenantSubTypeSelect,
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
        selectedItems: viewModel.getSelectedFinancialSubtype(
          selectedItem,
          forceEmptySelection,
        ),
      ),
    );
  }
}
