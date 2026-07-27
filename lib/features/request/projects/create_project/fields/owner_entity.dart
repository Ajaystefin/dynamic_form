import "package:easy_localization/easy_localization.dart";
import "package:flutter/material.dart";
import "package:flutter/services.dart";
import "package:wcas_frontend/core/components/label.dart";
import "package:wcas_frontend/core/components/textfield.dart";
import "package:wcas_frontend/features/request/projects/create_project/model.dart";

/// Owner entity field.
class OwnerEntity extends StatelessWidget {
  /// Creates an owner entity field.
  const OwnerEntity(this.viewModel, {super.key});

  /// Create project view model.
  final CreateProjectViewModel viewModel;

  @override
  Widget build(BuildContext context) {
    return LabelWidget(
      label: "project.createNewProject.ownerEntity".tr(),
      child: CustomTextField(
        controller: viewModel.ownerEntityController,
        key: const ValueKey("OwnerEntity"),
        semanticLabel: "project.createNewProject.ownerEntity".tr(),
        initialValue: viewModel.isCreateProject
            ? null
            : viewModel.project.projectOwnerEntityName ?? "",
        filled: !viewModel.canEdit,
        readOnly: !viewModel.canEdit,
        inputFormatters: [
          FilteringTextInputFormatter.allow(RegExp("[a-zA-Z0-9 ]")),
          LengthLimitingTextInputFormatter(50),
        ],
        maxLength: 50,
        onSaved: (String? value) {
          viewModel.project.projectOwnerEntityName = value;
        },
      ),
    );
  }
}
