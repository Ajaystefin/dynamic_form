import "package:easy_localization/easy_localization.dart";
import "package:flutter/material.dart";
import "package:wcas_frontend/core/components/datepicker.dart";
import "package:wcas_frontend/core/components/label.dart";
import "package:wcas_frontend/features/request/projects/create_project/model.dart";

class LiabilityEndDate extends StatelessWidget {
  const LiabilityEndDate(this.viewModel, {super.key});
  final CreateProjectViewModel viewModel;

  @override
  Widget build(BuildContext context) {
    return LabelWidget(
      label: "project.createNewProject.projectLiabilityEndDate".tr(),
      isRequired: false,
      child: CustomDatePicker(
        key: const ValueKey("LiabilityEndDate"),
        isEnabled: (viewModel.canEdit) ? true : false,
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
