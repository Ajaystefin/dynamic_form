import "package:easy_localization/easy_localization.dart";
import "package:flutter/material.dart";
import "package:wcas_frontend/core/components/label.dart";
import "package:wcas_frontend/core/components/textfield.dart";
import "package:wcas_frontend/core/utils/validators.dart";
import "package:wcas_frontend/features/request/projects/create_project/model.dart";

/// Project name field.
class ProjectName extends StatelessWidget {
  /// Creates a project name field.
  const ProjectName(this.viewModel, {super.key});

  /// Create project view model.
  final CreateProjectViewModel viewModel;

  @override
  Widget build(BuildContext context) {
    return LabelWidget(
      label: "project.createNewProject.projectName".tr(),
      isRequired: viewModel.isCreateProject,
      child: CustomTextField(
        controller: viewModel.projectNameController,
        key: const ValueKey("ProjectName"),
        semanticLabel: "project.createNewProject.projectName".tr(),
        initialValue:
            !viewModel.isCreateProject ? viewModel.project.projectName : "",
        maxLength: 100,
        filled: !viewModel.canEdit || !viewModel.isCreateProject,
        readOnly: !viewModel.canEdit || !viewModel.isCreateProject,
        validator: CustomValidator.requiredField,
        onSaved: (String? value) {
          viewModel.project.projectName = value;
        },
      ),
    );
  }
}
