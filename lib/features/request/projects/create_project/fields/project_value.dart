import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:wcas_frontend/core/components/label.dart';
import 'package:wcas_frontend/core/components/textfield.dart';
import 'package:wcas_frontend/features/request/projects/create_project/model.dart';

class ProjectValue extends StatelessWidget {
  final CreateProjectViewModel viewModel;
  const ProjectValue(this.viewModel, {super.key});

  @override
  Widget build(BuildContext context) {
    return LabelWidget(
      label: "project.createNewProject.projectValue".tr(),
      isRequired: false,
      child: CustomTextField(
        semanticLabel: "project.createNewProject.projectValue".tr(),
        initialValue: viewModel.isCreateProject
            ? null
            : viewModel.project.projectValue.toString(),
        inputFormatters: [
          FilteringTextInputFormatter.allow(RegExp(r'^\d{0,21}(\.\d{0,6})?$'))
        ],
                maxLength: 15,
        counterText: "",

        onSaved: (String? value) {
          viewModel.project.projectValue = double.tryParse(value.toString());
        },
      ),
    );
  }
}
