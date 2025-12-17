import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:wcas_frontend/core/components/label.dart';
import 'package:wcas_frontend/core/components/textarea.dart';
import 'package:wcas_frontend/core/components/tooltip.dart';
import 'package:wcas_frontend/core/utils/validators.dart';
import 'package:wcas_frontend/features/request/projects/create_project/model.dart';

class Summary extends StatelessWidget {
  final CreateProjectViewModel viewModel;
  const Summary(this.viewModel, {super.key});

  @override
  Widget build(BuildContext context) {
    return LabelWidget(
      label: "project.createNewProject.summary".tr(),
      isRequired: true,
      child: CustomTooltip(
        message:
            !viewModel.isCreateProject ? (viewModel.project.summary ?? '') : '',
        child: CustomTextArea(
          semanticLabel: "project.createNewProject.summary".tr(),
          initialValue:
              !viewModel.isCreateProject ? viewModel.project.summary : null,
          validator: CustomValidator.requiredField,
          counterText: "",
          maxLength: 1000,
          onSaved: (value) {
            viewModel.project.summary = value;
          },
        ),
      ),
    );
  }
}
