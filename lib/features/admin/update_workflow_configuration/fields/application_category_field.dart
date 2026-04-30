import "package:easy_localization/easy_localization.dart";
import "package:flutter/material.dart";
import "package:wcas_frontend/core/components/dropdown/dropdown.dart";
import "package:wcas_frontend/core/components/label.dart";
import "package:wcas_frontend/features/admin/update_workflow_configuration/model.dart";

class ApplicationCategoryField extends StatelessWidget {
  const ApplicationCategoryField({required this.viewModel, super.key});
  final UpdateWorkflowConfigViewModel viewModel;

  @override
  Widget build(BuildContext context) {
    // FIX: uses plain list field, not getter
    if (!viewModel.showCategorySelection) return const SizedBox.shrink();

    return LabelWidget(
      isRequired: true,
      label: "admin.workflowConfig.dialog.requestType".tr(),
      child: CustomDropdown<String>(
        items: viewModel.availableCategoryOptions,
        semanticLabel: "admin.workflowConfig.dialog.requestType".tr(),
        itemBuilder: (context, item, isDisabled, isSelected) {
          return dropdownItemBuildWidget(
            item,
            isListTile: true,
            isSelected: isSelected,
          );
        },
        onSelected: (selectedValue) {
          viewModel.onCategorySelected(selectedValue.first);
        },
        dropdownBuilder: (context, item) =>
            Text(item ?? "admin.workflowConfig.selectValue".tr()),
        selectedItems: viewModel.selectedCategory != null
            ? [viewModel.selectedCategory]
            : [],
      ),
    );
  }
}
