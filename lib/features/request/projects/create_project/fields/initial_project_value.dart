import "package:easy_localization/easy_localization.dart";
import "package:flutter/material.dart";
import "package:wcas_frontend/core/components/label.dart";
import "package:wcas_frontend/core/components/textfield.dart";
import "package:wcas_frontend/core/utils/validators.dart";
import "package:wcas_frontend/features/request/projects/create_project/model.dart";

/// Initial project value field.
class InitialProjectValue extends StatelessWidget {
  /// Creates an initial project value field.
  const InitialProjectValue(this.viewModel, {super.key});

  /// Create project view model.
  final CreateProjectViewModel viewModel;

  @override
  Widget build(BuildContext context) {
    return LabelWidget(
      label: "project.createNewProject.initialProjectValue".tr(),
      child: CustomTextField(
        controller: viewModel.initialProjectValueController,
        key: const ValueKey("InitialProjectValue"),
        semanticLabel: "project.createNewProject.initialProjectValue".tr(),
        initialValue: viewModel.project.initialProjectValue != null ||
                viewModel.project.initialProjectValue != "null"
            ? viewModel.project.initialProjectValue.toString()
            : "Not Available",
        filled: !viewModel.canEdit || !viewModel.isCreateProject,
        inputFormatters: [
          DecimalInputFormatter(),
        ],
        readOnly: !viewModel.canEdit || !viewModel.isCreateProject,
        onSaved: (String? value) {
          viewModel.project.initialProjectValue = value ?? "0";
        },
      ),
    );
  }
}
