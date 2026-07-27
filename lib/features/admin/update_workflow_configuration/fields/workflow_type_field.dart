import "package:easy_localization/easy_localization.dart";
import "package:flutter/material.dart";
import "package:wcas_frontend/core/components/dropdown/dropdown.dart";
import "package:wcas_frontend/core/components/label.dart";
import "package:wcas_frontend/features/admin/update_workflow_configuration/model.dart";

/// Displays the workflow type selection dropdown.
class WorkflowTypeField extends StatelessWidget {
  /// Creates a [WorkflowTypeField].
  const WorkflowTypeField({required this.viewModel, super.key});

  /// View model containing workflow configuration data.
  final UpdateWorkflowConfigViewModel viewModel;

  @override
  Widget build(BuildContext context) {
    return LabelWidget(
      isRequired: true,
      label: "admin.workflowConfig.dialog.workflowType".tr(),
      child: CustomDropdown<String>(
        items: viewModel.availableWorkflowTypes,
        semanticLabel: "admin.workflowConfig.dialog.workflowType".tr(),
        itemBuilder: (context, item, {isDisabled, isSelected}) {
          return dropdownItemBuildWidget(
            item,
            isSelected: isSelected ?? false,
          );
        },
        dropdownBuilder: (context, item) =>
            Text(item ?? "admin.roleRightMapping.selectValue".tr()),
        selectedItems: viewModel.selectedWorkflowType != null
            ? [viewModel.selectedWorkflowType]
            : [],
        onSelected: (selectedValue) {
          if (selectedValue.isEmpty) {
            return;
          }
          viewModel.onWorkflowTypeSelected(selectedValue.first);
        },
      ),
    );
  }
}
