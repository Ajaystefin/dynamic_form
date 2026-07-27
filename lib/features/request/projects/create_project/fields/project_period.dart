import "package:easy_localization/easy_localization.dart";
import "package:flutter/material.dart";
import "package:wcas_frontend/core/components/datepicker.dart";
import "package:wcas_frontend/core/components/label.dart";
import "package:wcas_frontend/features/request/projects/create_project/model.dart";

/// Project period field.
class ProjectPeriod extends StatelessWidget {
  /// Creates a project period field.
  const ProjectPeriod(this.viewModel, {super.key});

  /// Create project view model.
  final CreateProjectViewModel viewModel;

  @override
  Widget build(BuildContext context) {
    return LabelWidget(
      label: "project.createNewProject.projectPeriod".tr(),
      child: CustomDatePicker(
        key: const ValueKey("projectPeriod"),
        isEnabled: viewModel.canEdit,
        semanticLabel: "project.createNewProject.projectPeriod".tr(),
        dateFormat: "MM/yyyy",
        initialDateTime:
            !viewModel.isCreateProject ? viewModel.project.projectPeriod : null,
        onSubmit2: (DateTime? date) {
          viewModel.project.projectPeriod = date;
          viewModel.onProjectPeriodSelected(date);
        },
        controller: viewModel.projectPeriodController,
        pickerViewMode: PickerMode.month,
      ),
    );
  }
}
