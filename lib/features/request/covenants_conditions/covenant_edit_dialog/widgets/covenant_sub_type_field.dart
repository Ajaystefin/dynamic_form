import "package:easy_localization/easy_localization.dart";
import "package:flutter/material.dart";
import "package:wcas_frontend/core/components/dropdown/dropdown.dart";
import "package:wcas_frontend/core/components/label.dart";
import "package:wcas_frontend/features/request/covenants_conditions/covenant_edit_dialog/model.dart";
import "package:wcas_frontend/models/admin/reference.dart";

/// Covenant subtype field for the covenant edit dialog.
class CovenantSubTypeField extends StatelessWidget {
  /// Creates a covenant subtype field.
  const CovenantSubTypeField({
    required this.viewModel,
    super.key,
    this.selectedItem,
  });

  /// Covenant edit dialog view model.
  final CovenantEditDialogViewModel viewModel;

  /// Selected covenant subtype item.
  final Reference? selectedItem;

  @override
  Widget build(BuildContext context) {
    return LabelWidget(
      isRequired: viewModel.isRequiredBusinessSegment,
      label: "covenantsConditions.covenantEditDialog.covenantSubtype".tr(),
      child: CustomDropdown<Reference>(
        hintText: "common.selectValue".tr(),
        isEnabled: viewModel.selectedCovenantType != null &&
            viewModel.isStandardSelected &&
            !viewModel.isReadOnly,
        semanticLabel:
            "covenantsConditions.covenantEditDialog.covenantSubtype".tr(),
        validationMessage: "common.validation.emptyField".tr(),
        items: viewModel.covenantSubTypeDropdownItems,
        onSelected: (selectedValue) {
          viewModel.onGeneralCovenantSubTypeSelect(selectedValue);
        },
        dropdownBuilder: (context, item) =>
            dropdownBuilderWidget(text: item?.name),
        itemBuilder: (context, item, {isDisabled, isSelected}) {
          final int? listId = item.id;
          final bool isListTile = !(listId == 11142 || listId == 11141);

          return dropdownItemBuildWidget(
            item.name,
            isListTile: isListTile,
            isSelected: isSelected ?? false,
          );
        },
        selectedItems: viewModel.selectedGeneralCovenantSubType?.id != null
            ? [viewModel.selectedGeneralCovenantSubType]
            : [],
      ),
    );
  }
}
