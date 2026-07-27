import "package:easy_localization/easy_localization.dart";
import "package:flutter/material.dart";
import "package:wcas_frontend/core/components/dropdown/dropdown.dart"
    show CustomDropdown;
import "package:wcas_frontend/core/components/label.dart";
import "package:wcas_frontend/core/utils/utils.dart";
import "package:wcas_frontend/features/request/covenants_conditions/condition_edit_dialog/model.dart";
import "package:wcas_frontend/features/request/covenants_conditions/condition_edit_dialog/state.dart";
import "package:wcas_frontend/models/admin/reference.dart";

/// Condition subtype field for the condition edit dialog.
class ConditionSubTypeField extends StatelessWidget {
  /// Creates a condition subtype field.
  const ConditionSubTypeField({
    required this.viewModel,
    required this.state,
    super.key,
  });

  /// Condition edit dialog view model.
  final ConditionEditDialogViewModel viewModel;

  /// Condition edit dialog state.
  final ConditionEditDialogState state;

  @override
  Widget build(BuildContext context) {
    return LabelWidget(
      isEnabled: viewModel.canEdit,
      isRequired: true,
      // key: ValueKey(viewModel.selectedSubTypeValue?.name),
      label: "covenantsConditions.conditionsEditDialog.standardList".tr(),
      child: CustomDropdown<Reference>(
        isLoading: state.fieldStatus == LoadingStatus.loading,
        isEnabled: viewModel.isStandartList() && viewModel.selectedType != null,
        items: viewModel.getDescritionSubTypes(),
        showClearIcon: false,
        validationMessage: "common.validation.emptyField".tr(),
        onSelected: (selectedValue) {
          viewModel.onSubtypeSelection(selectedValue.first);
        },
        dropdownBuilder: (context, item) => Text(
          item?.name ?? "",
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
        ),
        itemBuilder: (context, item, {isDisabled, isSelected}) => ListTile(
          dense: true,
          title: Text(
            item.name ?? "",
          ),
        ),
        selectedItems: viewModel.selectedSubTypeValue != null
            ? [viewModel.selectedSubTypeValue]
            : null,
      ),
    );
  }
}
