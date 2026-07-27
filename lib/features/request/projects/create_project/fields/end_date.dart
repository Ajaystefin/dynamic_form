import "package:easy_localization/easy_localization.dart";
import "package:flutter/material.dart";
import "package:wcas_frontend/core/components/datepicker.dart";
import "package:wcas_frontend/core/components/label.dart";
import "package:wcas_frontend/features/request/projects/create_project/model.dart";

/// Liability end date field.
class LiabilityEndDate extends StatelessWidget {
  /// Creates a liability end date field.
  const LiabilityEndDate(this.viewModel, {super.key});

  /// Create project view model.
  final CreateProjectViewModel viewModel;

  @override
  Widget build(BuildContext context) {
    return LabelWidget(
      label: "project.createNewProject.projectLiabilityEndDate".tr(),
      child: CustomDatePicker(
        key: const ValueKey("LiabilityEndDate"),
        isEnabled: viewModel.canEdit,
        semanticLabel: "project.createNewProject.projectLiabilityEndDate".tr(),
        dateFormat: "MM/yyyy",
        initialDateTime: !viewModel.isCreateProject
            ? viewModel.project.defectLiabilityEndDate
            : null,
        onSubmit2: (DateTime? date) {
          viewModel.project.defectLiabilityEndDate = date;
          viewModel.onLiabilityEndDateSelected(date);
        },
        controller: viewModel.defectLiabilityEndDateController,
        pickerViewMode: PickerMode.month,
      ),
    );
  }
}
