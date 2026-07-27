import "package:easy_localization/easy_localization.dart";
import "package:flutter/material.dart";
import "package:wcas_frontend/core/components/dropdown/dropdown.dart"
    show CustomDropdown;
import "package:wcas_frontend/core/components/label.dart";
import "package:wcas_frontend/core/utils/utils.dart";
import "package:wcas_frontend/features/request/covenants_conditions/condition_edit_dialog/model.dart";
import "package:wcas_frontend/models/admin/reference.dart";

/// Action dropdown field for the condition edit dialog.
class ActionField extends StatelessWidget {
  /// Creates an action field.
  const ActionField({required this.viewModel, super.key});

  /// Condition edit dialog view model.
  final ConditionEditDialogViewModel viewModel;

  @override
  Widget build(BuildContext context) {
    return LabelWidget(
      isEnabled: viewModel.isActionEditable || viewModel.canEditComments,
      label: "covenantsConditions.covenantEditDialog.action".tr(),
      isRequired:
          !Utils.checkBusinessSegment(BusinessSegment.financialInstitution),
      child: CustomDropdown<Reference>(
        ignoreProvider: viewModel.canEditComments,
        isEnabled: viewModel.canEditStatusAction || viewModel.canEditComments,
        semanticLabel: "covenantsConditions.covenantEditDialog.action".tr(),
        validationMessage: "common.validation.emptyField".tr(),
        items: viewModel.getActionvalues(),
        onSelected: (selectedValue) {
          viewModel.onActionFieldChange(selectedValue.first);
        },
        dropdownBuilder: (context, item) => Text(item?.name ?? ""),
        itemBuilder: (context, item, {isDisabled, isSelected}) => ListTile(
          dense: true,
          title: Text(
            item.name ?? "",
          ),
        ),
        selectedItems: viewModel.selectedAction != null
            ? [viewModel.selectedAction]
            : null,
      ),
    );
  }
}
