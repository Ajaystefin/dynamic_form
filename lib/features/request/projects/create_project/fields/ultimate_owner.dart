import "package:easy_localization/easy_localization.dart";
import "package:flutter/material.dart";
import "package:flutter/services.dart";
import "package:wcas_frontend/core/components/label.dart";
import "package:wcas_frontend/core/components/textfield.dart";
import "package:wcas_frontend/core/utils/validators.dart";
import "package:wcas_frontend/features/request/projects/create_project/model.dart";

/// Ultimate owner field.
class UltimateOwner extends StatelessWidget {
  /// Creates an ultimate owner field.
  const UltimateOwner(this.viewModel, {super.key});

  /// Create project view model.
  final CreateProjectViewModel viewModel;

  @override
  Widget build(BuildContext context) {
    return LabelWidget(
      label: "project.createNewProject.ultimateOwner".tr(),
      isRequired: viewModel.isCreateProject,
      child: CustomTextField(
        controller: viewModel.ultimateOwnerController,
        key: const ValueKey("UltimateOwner"),
        semanticLabel: "project.createNewProject.ultimateOwner".tr(),
        initialValue: !viewModel.isCreateProject
            ? viewModel.project.projectUltimateOwnerName
            : "",
        filled: !viewModel.canEdit || !viewModel.isCreateProject,
        readOnly: !viewModel.canEdit || !viewModel.isCreateProject,
        validator: CustomValidator.requiredField,
        inputFormatters: [
          FilteringTextInputFormatter.allow(
            RegExp("[a-zA-Z0-9 ]"), // letters, numbers, spaces
          ),
        ],
        maxLength: 50,
        onSaved: (String? value) {
          viewModel.project.projectUltimateOwnerName = value;
        },
      ),
    );
  }
}
