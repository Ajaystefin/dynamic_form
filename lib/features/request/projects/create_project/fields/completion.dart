import "package:easy_localization/easy_localization.dart";
import "package:flutter/material.dart";
import "package:wcas_frontend/core/components/label.dart";
import "package:wcas_frontend/core/components/textfield.dart";
import "package:wcas_frontend/features/request/projects/create_project/model.dart";
import "package:wcas_frontend/features/request/projects/edit_contract/utils/percentage_input_formatter.dart";

class Completion extends StatelessWidget {
  const Completion(this.viewModel, {super.key});
  final CreateProjectViewModel viewModel;

  @override
  Widget build(BuildContext context) {
    return LabelWidget(
      label: "project.createNewProject.projectCompletion".tr(),
      isRequired: false,
      child: CustomTextField(
        controller: viewModel.projectCompletionController,
        key: const ValueKey("Completion"),
        semanticLabel: "project.createNewProject.projectCompletion".tr(),
        initialValue: viewModel.isCreateProject
            ? null
            : viewModel.project.projectCompletion != null
                ? viewModel.project.projectCompletion.toString()
                : "",
        counterText: "",
        maxLength: 7,
        filled: (viewModel.canEdit) ? false : true,
        readOnly: (viewModel.canEdit) ? false : true,
        keyboardType: const TextInputType.numberWithOptions(decimal: true),
        inputFormatters: [
          PercentageInputFormatter(), //reusable
        ],
        onChanged: (value) {
          viewModel.project.projectCompletion =
              double.tryParse(value.toString());
        },
        onSaved: (String? value) {
          viewModel.project.projectCompletion = double.tryParse(value ?? "0");
        },
      ),
    );
  }
}
