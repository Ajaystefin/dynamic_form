import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:wcas_frontend/core/components/datepicker.dart';
import 'package:wcas_frontend/core/components/label.dart';
import 'package:wcas_frontend/features/request/projects/create_project/model.dart';

class LiabilityEndDate extends StatelessWidget {
  final CreateProjectViewModel viewModel;
  const LiabilityEndDate(this.viewModel, {super.key});

  @override
  Widget build(BuildContext context) {
    return LabelWidget(
      label: "project.createNewProject.projectLiabilityEndDate".tr(),
      isRequired: false,
      child: CustomDatePicker(
        semanticLabel: "project.createNewProject.projectLiabilityEndDate".tr(),
        dateFormat: 'MM-yyyy',
        initialDateTime:!viewModel.isCreateProject? viewModel.project.liabilityEndDate:null,
        onSubmit2: (DateTime? date) {
          viewModel.project.liabilityEndDate = date;
        },
        pickerViewMode: PickerMode.month,
      ),
    );
  }
}
