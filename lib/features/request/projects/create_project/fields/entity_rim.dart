import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:wcas_frontend/core/components/label.dart';
import 'package:wcas_frontend/core/components/textfield.dart';
import 'package:wcas_frontend/features/request/projects/create_project/model.dart';

class EntityRim extends StatelessWidget {
  final CreateProjectViewModel viewModel;
  const EntityRim(this.viewModel, {super.key});

  @override
  Widget build(BuildContext context) {
    return LabelWidget(
      label: "project.createNewProject.ownerEntityRIM".tr(),
      isRequired: false,
      child: CustomTextField(
        semanticLabel: "project.createNewProject.ownerEntityRIM".tr(),
        initialValue: viewModel.isCreateProject
            ? null
            : viewModel.project.ownerEntityRim.toString(),
        inputFormatters: [
          FilteringTextInputFormatter.allow(RegExp(r'^[0-9]*$')),
        ],
        maxLength: 15,        counterText: "",

        onSaved: (String? value) {
          viewModel.project.ownerEntityRim = int.tryParse(value.toString());
        },
      ),
    );
  }
}
