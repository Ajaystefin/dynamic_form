import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:wcas_frontend/core/components/label.dart';
import 'package:wcas_frontend/core/components/textfield.dart';
import 'package:wcas_frontend/core/utils/validators.dart';
import 'package:wcas_frontend/features/request/projects/create_project/model.dart';

class UltimateOwner extends StatelessWidget {
  final CreateProjectViewModel viewModel;
  const UltimateOwner(this.viewModel, {super.key});

  @override
  Widget build(BuildContext context) {
    return LabelWidget(
      label: "project.createNewProject.ultimateOwner".tr(),
      isRequired: viewModel.isCreateProject,
      child: CustomTextField(
        semanticLabel: "project.createNewProject.ultimateOwner".tr(),
        initialValue:  !viewModel.isCreateProject?viewModel.project.ultimateOwner:'',
        filled: !viewModel.isCreateProject,
        readOnly: !viewModel.isCreateProject,
        validator: CustomValidator.requiredField,
        maxLength: 50,
        counterText: "",
        onSaved: (String? value) {
          viewModel.project.ultimateOwner = value;
        },
      ),
    );
  }
}
