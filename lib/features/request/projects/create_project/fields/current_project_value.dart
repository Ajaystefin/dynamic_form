import "package:easy_localization/easy_localization.dart";
import "package:flutter/material.dart";
import "package:wcas_frontend/core/components/label.dart";
import "package:wcas_frontend/core/components/textfield.dart";
import "package:wcas_frontend/core/utils/validators.dart";
import "package:wcas_frontend/features/request/projects/create_project/model.dart";

/// Current project value field.
class CurrentProjectValue extends StatelessWidget {
  /// Creates a current project value field.
  const CurrentProjectValue(this.viewModel, {super.key});

  /// Create project view model.
  final CreateProjectViewModel viewModel;

  @override
  Widget build(BuildContext context) {
    return LabelWidget(
      label: "project.createNewProject.currentProjectValue".tr(),
      child: CustomTextField(
        controller: viewModel.projectValueCurrentController,
        key: const ValueKey("CurrentProjectValue"),
        semanticLabel: "project.createNewProject.currentProjectValue".tr(),
        initialValue: viewModel.project.projectValueCurrent != null ||
                viewModel.project.projectValueCurrent != "null"
            ? viewModel.project.projectValueCurrent.toString()
            : "",
        inputFormatters: [
          DecimalInputFormatter(),
        ],
        filled: !viewModel.canEdit || !viewModel.isCreateProject,
        readOnly: !viewModel.canEdit || !viewModel.isCreateProject,
        onSaved: (String? value) {
          viewModel.project.projectValueCurrent = value.toString();
        },
      ),
    );
  }
}
