import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:wcas_frontend/core/components/datepicker.dart';
import 'package:wcas_frontend/core/components/label.dart';
import 'package:wcas_frontend/features/request/projects/create_project/model.dart';

class ProjectPeriod extends StatelessWidget {
  final CreateProjectViewModel viewModel;
  const ProjectPeriod(this.viewModel, {super.key});

  @override
  Widget build(BuildContext context) {
    return LabelWidget(
      label: "project.createNewProject.projectPeriod".tr(),
      isRequired: false,
      child: CustomDatePicker(
        semanticLabel: "project.createNewProject.projectPeriod".tr(),
        dateFormat: 'MM-yyyy',
        initialDateTime:!viewModel.isCreateProject? viewModel.project.period:null,
        onSubmit2: (DateTime? date) {
          viewModel.project.period = date;
        },
        pickerViewMode: PickerMode.month,
      ),
    );
  }
}
