import "package:easy_localization/easy_localization.dart";
import "package:flutter/material.dart";
import "package:wcas_frontend/core/components/dropdown/dropdown.dart";
import "package:wcas_frontend/core/components/label.dart";
import "package:wcas_frontend/features/admin/update_workflow_configuration/model.dart";

class ApplicationTypeField extends StatelessWidget {
  const ApplicationTypeField({required this.viewModel, super.key});
  final UpdateWorkflowConfigViewModel viewModel;

  @override
  Widget build(BuildContext context) {
    // FIX: uses plain bool field, not getter
    if (!viewModel.showApplicationTypeDropdown) return const SizedBox.shrink();

    return LabelWidget(
      isRequired: true,
      label: "admin.workflowConfig.dialog.applicationTypeName".tr(),
      child: CustomDropdown<String>(
        items: viewModel.availableApplicationTypes,
        semanticLabel: "admin.workflowConfig.dialog.applicationTypeName".tr(),
        itemBuilder: (context, item, isDisabled, isSelected) {
          return dropdownItemBuildWidget(
            item,
            isListTile: true,
            isSelected: isSelected,
          );
        },
        onSelected: (selectedValue) {
          viewModel.onApplicationTypeSelected(selectedValue.first);
        },
        dropdownBuilder: (context, item) =>
            Text(item ?? "admin.roleRightMapping.selectValue".tr()),
        selectedItems: viewModel.selectedApplicationType != null
            ? [viewModel.selectedApplicationType]
            : [],
      ),
    );
  }
}
