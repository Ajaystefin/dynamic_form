import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:wcas_frontend/core/components/label.dart';
import 'package:wcas_frontend/core/components/textfield.dart';
import 'package:wcas_frontend/features/request/projects/create_project/model.dart';

class OwnerEntity extends StatelessWidget {
  final CreateProjectViewModel viewModel;
  const OwnerEntity(this.viewModel, {super.key});

  @override
  Widget build(BuildContext context) {
    return LabelWidget(
      label: "project.createNewProject.ownerEntity".tr(),
      isRequired: false,
      child: CustomTextField(
        semanticLabel: "project.createNewProject.ownerEntity".tr(),
        initialValue: viewModel.isCreateProject
            ? null
            : viewModel.project.ownerEntity ?? '',
        filled: false,
        readOnly: false,
        inputFormatters: [
          FilteringTextInputFormatter.allow(RegExp(r'^[a-zA-Z0-9]*$')),
        ],
        maxLength: 50,
        counterText: "",
        onSaved: (String? value) {
          viewModel.project.ownerEntity = value;
        },
      ),
    );
  }
}
