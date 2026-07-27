import "package:easy_localization/easy_localization.dart";
import "package:flutter/material.dart";
import "package:wcas_frontend/core/components/label.dart";
import "package:wcas_frontend/core/components/textfield.dart";
import "package:wcas_frontend/features/request/projects/create_project/model.dart";

/// Project code field.
class ProjectCode extends StatelessWidget {
  /// Creates a project code field.
  const ProjectCode(this.viewModel, {super.key});

  /// Create project view model.
  final CreateProjectViewModel viewModel;

  @override
  Widget build(BuildContext context) {
    // String projectCode = ProjectCodeGenerator.generateNext(
    //   lastSerial: null, // replace with actual last serial if you have one
    //   now: DateTime.now(),
    // );

    return LabelWidget(
      label: "project.createNewProject.projectCode".tr(),
      child: CustomTextField(
        key: const ValueKey("ProjectCode"),
        semanticLabel: "project.createNewProject.projectCode".tr(),
        readOnly: true,
        filled: true,
        maxLength: 16,
        initialValue: viewModel.project.projectCode != null
            ? viewModel.project.projectCode ?? ""
            : "",
        textInputAction: TextInputAction.none,
        keyboardType: TextInputType.text,
        onSaved: (value) {
          //viewModel.project.projectCode = value;
        },
        // validator: (p0) {
        //   projectCodeValidator(p0);
        // },
      ),
    );
  }
}
