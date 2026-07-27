import "package:easy_localization/easy_localization.dart";
import "package:flutter/material.dart";
import "package:wcas_frontend/core/components/label.dart";
import "package:wcas_frontend/core/components/textfield.dart";
import "package:wcas_frontend/features/request/projects/edit_contract/model.dart";

/// Project name field.
class ProjectName extends StatelessWidget {
  /// Creates a project name field.
  const ProjectName({required this.viewModel, super.key});

  /// Edit contract view model.
  final EditContractViewModel viewModel;

  @override
  Widget build(BuildContext context) {
    return LabelWidget(
      label: "project.viewEditContractDetails.projectName".tr(),
      child: CustomTextField(
        semanticLabel: "project.viewEditContractDetails.projectName".tr(),
        initialValue: viewModel.project.projectName,
        readOnly: true,
        filled: true,
      ),
    );
  }
}
