import "package:easy_localization/easy_localization.dart";
import "package:flutter/material.dart";
import "package:wcas_frontend/core/components/dropdown/dropdown.dart";
import "package:wcas_frontend/core/components/label.dart";
import "package:wcas_frontend/features/request/covenants_conditions/covenant_edit_dialog/model.dart";
import "package:wcas_frontend/models/admin/reference.dart";

class CovenantSubTypeField extends StatelessWidget {
  const CovenantSubTypeField({
    required this.viewModel,
    super.key,
    this.selectedItem,
  });

  final CovenantEditDialogViewModel viewModel;
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
            dropdownBuilderWidget(text: item?.name, showToolTip: false),
        itemBuilder: (context, item, isDisabled, isSelected) {
          final int? listId = item.id;
          final bool isListTile = !(listId == 11142 || listId == 11141);

          return dropdownItemBuildWidget(
            item.name,
            isListTile: isListTile,
            isSelected: isSelected,
          );
        },
        selectedItems: viewModel.selectedGeneralCovenantSubType?.id != null
            ? [viewModel.selectedGeneralCovenantSubType]
            : [],
      ),
    );
  }
}
