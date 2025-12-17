import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:wcas_frontend/core/components/label.dart';
import 'package:wcas_frontend/core/components/textfield.dart';
import 'package:wcas_frontend/features/request/projects/create_project/model.dart';

class ProjectCode extends StatelessWidget {
  final CreateProjectViewModel viewModel;
  const ProjectCode(this.viewModel, {super.key});

  @override
  Widget build(BuildContext context) {
    return LabelWidget(
      label: "project.createNewProject.projectCode".tr(),
      child: CustomTextField(
        semanticLabel: "project.createNewProject.projectCode".tr(),
        readOnly: true,
        filled: true,
        maxLength: 16,
        counterText: "",
        initialValue: viewModel.project.code ?? '',
      ),
    );
  }
}
