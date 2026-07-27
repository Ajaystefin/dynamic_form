import "package:easy_localization/easy_localization.dart";
import "package:flutter/material.dart";
import "package:wcas_frontend/core/components/dropdown/dropdown.dart";
import "package:wcas_frontend/core/components/label.dart";
import "package:wcas_frontend/core/constants/_reference_data_keys.dart";
import "package:wcas_frontend/features/request/covenants_conditions/covenant_edit_dialog/model.dart";
import "package:wcas_frontend/models/admin/reference.dart";

/// Covenant type field for the covenant edit dialog.
class CovenantTypeField extends StatelessWidget {
  /// Creates a covenant type field.
  const CovenantTypeField({
    required this.viewModel,
    super.key,
    this.isEnabled,
    this.selectedItem,
  });

  /// Covenant edit dialog view model.
  final CovenantEditDialogViewModel viewModel;

  /// Whether the covenant type dropdown is enabled.
  final bool? isEnabled;

  /// Selected covenant type item.
  final Reference? selectedItem;

  @override
  Widget build(BuildContext context) {
    return LabelWidget(
      isRequired: viewModel.isRequiredBusinessSegment,
      label: "covenantsConditions.covenantEditDialog.covenantType".tr(),
      child: CustomDropdown<Reference>(
        hintText: "common.selectValue".tr(),
        isEnabled: isEnabled! && !viewModel.isReadOnly,
        semanticLabel:
            "covenantsConditions.covenantEditDialog.covenantType".tr(),
        validationMessage: "common.validation.emptyField".tr(),
        items: viewModel.referenceData[ReferenceDataKeys.covenantType] ?? [],
        onSelected: viewModel.onCovenantTypeSelection,
        dropdownBuilder: (context, item) =>
            dropdownBuilderWidget(text: item?.name),
        itemBuilder: (context, item, {isDisabled, isSelected}) {
          return dropdownItemBuildWidget(
            item.name,
            isSelected: isSelected ?? false,
          );
        },
        selectedItems: viewModel.getSelectedCovenantType(selectedItem),
      ),
    );
  }
}
