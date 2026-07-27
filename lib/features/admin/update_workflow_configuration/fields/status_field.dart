import "package:easy_localization/easy_localization.dart";
import "package:flutter/material.dart";
import "package:wcas_frontend/core/components/dropdown/dropdown.dart";
import "package:wcas_frontend/core/components/label.dart";
import "package:wcas_frontend/core/constants/_server_constants.dart";
import "package:wcas_frontend/features/admin/update_workflow_configuration/model.dart";

/// Displays the workflow status selection dropdown.
class WorkflowStatusField extends StatelessWidget {
  /// Creates a [WorkflowStatusField].
  const WorkflowStatusField({required this.viewModel, super.key});

  /// View model containing workflow configuration data.
  final UpdateWorkflowConfigViewModel viewModel;

  @override
  Widget build(BuildContext context) {
    return LabelWidget(
      isRequired: true,
      label: "admin.workflowConfig.dialog.status".tr(),
      child: CustomDropdown<String>(
        items: ServerConstants.statusOptions,
        semanticLabel: "admin.workflowConfig.dialog.status".tr(),
        itemBuilder: (context, item, {isDisabled, isSelected}) {
          return dropdownItemBuildWidget(
            item,
            isSelected: isSelected ?? false,
          );
        },
        onSelected: (selectedValue) {
          // FIX point 2: onSelected sets _draft.isActive via handler
          viewModel.onStatusChanged(selectedValue.first);
        },
        dropdownBuilder: (context, item) => Text(item ?? ""),
        selectedItems: [viewModel.selectedStatus],
      ),
    );
  }
}
