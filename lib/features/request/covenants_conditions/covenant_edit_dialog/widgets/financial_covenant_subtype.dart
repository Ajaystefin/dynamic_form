import "package:easy_localization/easy_localization.dart";
import "package:flutter/material.dart";
import "package:wcas_frontend/core/components/dropdown/dropdown.dart";
import "package:wcas_frontend/core/components/label.dart";
import "package:wcas_frontend/features/request/covenants_conditions/covenant_edit_dialog/model.dart";
import "package:wcas_frontend/models/admin/reference.dart";

class FinancialCovenantSubtype extends StatelessWidget {
  const FinancialCovenantSubtype({required this.viewModel, super.key});
  final CovenantEditDialogViewModel viewModel;
  @override
  Widget build(BuildContext context) {
    return LabelWidget(
      isRequired: true,
      label: "covenantsConditions.covenantEditDialog.covenantSubtype".tr(),
      child: CustomDropdown<Reference>(
        isEnabled: !viewModel.isReadOnly,
        semanticLabel:
            "covenantsConditions.covenantEditDialog.covenantSubtype".tr(),
        validationMessage: "common.validation.emptyField".tr(),
        items: viewModel.getFilteredCovenantSubtypesByType(),
        onSelected: (selectedValue) {
          viewModel.onCovenantSubTypeSelect(selectedValue);
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
        selectedItems: viewModel.selectedCovenantSubType != null
            ? [viewModel.selectedCovenantSubType]
            : [
                Reference(
                  name: "common.selectValue".tr(),
                ),
              ],
      ),
    );
  }
}
