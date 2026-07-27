import "package:easy_localization/easy_localization.dart";
import "package:flutter/material.dart";
import "package:wcas_frontend/core/components/label.dart";
import "package:wcas_frontend/core/components/textfield.dart";
import "package:wcas_frontend/core/utils/validators.dart";
import "package:wcas_frontend/features/request/projects/create_project/model.dart";

/// Owner RIM field.
class OwnerRim extends StatelessWidget {
  /// Creates an owner RIM field.
  const OwnerRim(this.viewModel, {super.key});

  /// Create project view model.
  final CreateProjectViewModel viewModel;

  @override
  Widget build(BuildContext context) {
    return LabelWidget(
      label: "project.createNewProject.ownerRIM".tr(),
      child: CustomTextField(
        controller: viewModel.ownerRimController,
        key: const ValueKey("OwnerRim"),
        maxLength: 15,
        semanticLabel: "project.createNewProject.ownerRIM".tr(),
        initialValue: viewModel.isCreateProject
            ? null
            : viewModel.project.projectOwnerRimNo != null
                ? viewModel.project.projectOwnerRimNo.toString()
                : "",
        filled: !viewModel.canEdit,
        readOnly: !viewModel.canEdit,
        keyboardType: TextInputType.number,
        inputFormatters: [
          NumericDecimalTextInputFormatter(
            maxIntegerDigits: 15, // ← your requirement
            maxDecimalDigits: 6, // ← your requirement
          ),
        ],
        onSaved: (String? value) {
          viewModel.project.projectOwnerRimNo = int.tryParse(value.toString());
        },
      ),
    );
  }
}
