import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:wcas_frontend/core/components/label.dart';
import 'package:wcas_frontend/core/components/textfield.dart';
import 'package:wcas_frontend/features/request/projects/create_project/model.dart';

class OwnerRim extends StatelessWidget {
  final CreateProjectViewModel viewModel;
  const OwnerRim(this.viewModel, {super.key});

  @override
  Widget build(BuildContext context) {
    return LabelWidget(
      label: "project.createNewProject.ownerRIM".tr(),
      isRequired: false,
      child: CustomTextField(
        semanticLabel: "project.createNewProject.ownerRIM".tr(),
        initialValue: viewModel.isCreateProject
            ? null
            : viewModel.project.ownerRim.toString(),
        counterText: '',
        maxLength: 15,
        inputFormatters: [
          FilteringTextInputFormatter.allow(RegExp(r'^[0-9]*$')),
        ],
        onSaved: (String? value) {
          viewModel.project.ownerRim = int.tryParse(value.toString());
        },
      ),
    );
  }
}
