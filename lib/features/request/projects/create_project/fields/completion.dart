import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:wcas_frontend/core/components/label.dart';
import 'package:wcas_frontend/core/components/textfield.dart';
import 'package:wcas_frontend/features/request/projects/create_project/model.dart';

class Completion extends StatelessWidget {
  final CreateProjectViewModel viewModel;
  const Completion(this.viewModel, {super.key});

  @override
  Widget build(BuildContext context) {
    return LabelWidget(
      label: "project.createNewProject.projectCompletion".tr(),
      isRequired: false,
      child: CustomTextField(
        semanticLabel: "project.createNewProject.projectCompletion".tr(),
        initialValue: viewModel.isCreateProject
            ? null
            : "${viewModel.project.completion}",
        counterText: "",
        inputFormatters: [
          FilteringTextInputFormatter.allow(RegExp(r'^([0-9]{1,2}|100)$')),
        ],
        onSaved: (String? value) {
          viewModel.project.completion = int.tryParse(value!);
        },
      ),
    );
  }
}
