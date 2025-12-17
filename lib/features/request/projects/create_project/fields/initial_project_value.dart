import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:wcas_frontend/core/components/label.dart';
import 'package:wcas_frontend/core/components/textfield.dart';
import 'package:wcas_frontend/features/request/projects/create_project/model.dart';

class InitialProjectValue extends StatelessWidget {
  final CreateProjectViewModel viewModel;
  const InitialProjectValue(this.viewModel, {super.key});

  @override
  Widget build(BuildContext context) {
    return LabelWidget(
      label: "project.createNewProject.initialProjectValue".tr(),
      isRequired: false,
      child: CustomTextField(
        semanticLabel: "project.createNewProject.initialProjectValue".tr(),
        initialValue: viewModel.project.initalProjectValue ?? '',
        filled: !viewModel.isCreateProject,
        readOnly: !viewModel.isCreateProject,
        onSaved: (String? value) {
          viewModel.project.initalProjectValue = value;
        },
      ),
    );
  }
}
