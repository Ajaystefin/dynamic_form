import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:wcas_frontend/core/components/label.dart';
import 'package:wcas_frontend/core/components/textfield.dart';
import 'package:wcas_frontend/core/utils/validators.dart';
import 'package:wcas_frontend/features/request/projects/create_project/model.dart';

class ProjectName extends StatelessWidget {
  final CreateProjectViewModel viewModel;
  const ProjectName(this.viewModel, {super.key});

  @override
  Widget build(BuildContext context) {
    return LabelWidget(
      label: "project.createNewProject.projectName".tr(),
      isRequired: viewModel.isCreateProject,
      child: CustomTextField(
        semanticLabel: "project.createNewProject.projectName".tr(),
        initialValue: !viewModel.isCreateProject?viewModel.project.name:"",
        maxLength: 100,
        filled: !viewModel.isCreateProject,
        readOnly: !viewModel.isCreateProject,
        counterText: '',
        validator: CustomValidator.requiredField,
        onSaved: (String? value) {
          viewModel.project.name = value;
        },
      ),
    );
  }
}
