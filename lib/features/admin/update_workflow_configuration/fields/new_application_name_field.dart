import "package:easy_localization/easy_localization.dart";
import "package:flutter/material.dart";
import "package:wcas_frontend/core/components/label.dart";
import "package:wcas_frontend/core/components/textfield.dart";
import "package:wcas_frontend/features/admin/update_workflow_configuration/model.dart";

/// Displays the field for entering a new application type name.
class NewApplicationNameField extends StatelessWidget {
  /// Creates a [NewApplicationNameField].
  const NewApplicationNameField({required this.viewModel, super.key});

  /// View model containing workflow configuration data.
  final UpdateWorkflowConfigViewModel viewModel;

  @override
  Widget build(BuildContext context) {
    // FIX: uses plain bool field, not getter
    if (!viewModel.showNewApplicationNameField) {
      return const SizedBox.shrink();
    }

    return LabelWidget(
      isRequired: true,
      label: "admin.workflowConfig.dialog.newApplicationTypeName".tr(),
      child: CustomTextField(
        initialValue: viewModel.newApplicationTypeName,
        hintText: "admin.workflowConfig.dialog.newApplicationTypeNameHint".tr(),
        maxLength: 100,
        // FIX point 2: onChanged sets _draft.name via handler
        onChanged: viewModel.onNewApplicationTypeNameChanged,
        validator: viewModel.validateNewApplicationTypeName,
      ),
    );
  }
}
