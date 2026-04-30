import "package:easy_localization/easy_localization.dart";
import "package:flutter/material.dart";
import "package:wcas_frontend/core/components/datepicker.dart";
import "package:wcas_frontend/core/components/label.dart";
import "package:wcas_frontend/features/request/projects/create_project/model.dart";

class ProjectPeriod extends StatelessWidget {
  const ProjectPeriod(this.viewModel, {super.key});
  final CreateProjectViewModel viewModel;

  @override
  Widget build(BuildContext context) {
    return LabelWidget(
      label: "project.createNewProject.projectPeriod".tr(),
      isRequired: false,
      child: CustomDatePicker(
        key: const ValueKey("projectPeriod"),
        isEnabled: (viewModel.canEdit) ? true : false,
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
