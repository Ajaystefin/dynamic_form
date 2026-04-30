import "package:easy_localization/easy_localization.dart";
import "package:flutter/material.dart";
import "package:flutter/services.dart";
import "package:wcas_frontend/core/components/label.dart";
import "package:wcas_frontend/core/components/textfield.dart";
import "package:wcas_frontend/features/request/projects/create_project/model.dart";

class EntityRim extends StatelessWidget {
  const EntityRim(this.viewModel, {super.key});
  final CreateProjectViewModel viewModel;

  @override
  Widget build(BuildContext context) {
    return LabelWidget(
      label: "project.createNewProject.ownerEntityRIM".tr(),
      isRequired: false,
      child: CustomTextField(
        controller: viewModel.entityRimController,
        key: const ValueKey("EntityRim"),
        semanticLabel: "project.createNewProject.ownerEntityRIM".tr(),
        initialValue: viewModel.isCreateProject
            ? null
            : viewModel.project.projectOwnerEntityRimNo != null
                ? viewModel.project.projectOwnerEntityRimNo.toString()
                : "",
        inputFormatters: [
          FilteringTextInputFormatter.allow(RegExp(r"^[0-9]*$")),
        ],
        maxLength: 10,
        counterText: "",
        filled: (viewModel.canEdit) ? false : true,
        readOnly: (viewModel.canEdit) ? false : true,
        onSaved: (String? value) {
          viewModel.project.projectOwnerEntityRimNo =
              int.tryParse(value.toString());
        },
      ),
    );
  }
}
