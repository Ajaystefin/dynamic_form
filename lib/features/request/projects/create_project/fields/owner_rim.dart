import "package:easy_localization/easy_localization.dart";
import "package:flutter/material.dart";
import "package:flutter/services.dart";
import "package:wcas_frontend/core/components/label.dart";
import "package:wcas_frontend/core/components/textfield.dart";
import "package:wcas_frontend/features/request/projects/create_project/model.dart";

class OwnerRim extends StatelessWidget {
  const OwnerRim(this.viewModel, {super.key});
  final CreateProjectViewModel viewModel;

  @override
  Widget build(BuildContext context) {
    return LabelWidget(
      label: "project.createNewProject.ownerRIM".tr(),
      isRequired: false,
      child: CustomTextField(
        controller: viewModel.ownerRimController,
        key: const ValueKey("OwnerRim"),
        maxLength: 50,
        semanticLabel: "project.createNewProject.ownerRIM".tr(),
        initialValue: viewModel.isCreateProject
            ? null
            : viewModel.project.projectOwnerRimNo != null
                ? viewModel.project.projectOwnerRimNo.toString()
                : "",
        counterText: "",
        filled: (viewModel.canEdit) ? false : true,
        readOnly: (viewModel.canEdit) ? false : true,
        inputFormatters: [
          FilteringTextInputFormatter.allow(RegExp(r"^[0-9]*$")),
        ],
        onSaved: (String? value) {
          viewModel.project.projectOwnerRimNo = int.tryParse(value.toString());
        },
      ),
    );
  }
}
