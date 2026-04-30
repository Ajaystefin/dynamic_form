import "package:easy_localization/easy_localization.dart";
import "package:flutter/material.dart";
import "package:wcas_frontend/core/components/label.dart";
import "package:wcas_frontend/core/components/textfield.dart";
import "package:wcas_frontend/features/request/projects/edit_contract/model.dart";
import "package:wcas_frontend/features/request/projects/edit_contract/utils/percentage_input_formatter.dart";

class ProjectCompletion extends StatelessWidget {
  const ProjectCompletion({required this.viewModel, super.key});
  final EditContractViewModel viewModel;

  @override
  Widget build(BuildContext context) {
    return LabelWidget(
      label: "project.viewEditContractDetails.projectCompletion".tr(),
      child: CustomTextField(
        controller: viewModel.completionPercentageController,
        semanticLabel: "project.viewEditContractDetails.projectCompletion".tr(),
        initialValue: viewModel.contract.completionPercentage.toString(),
        maxLength: 7,
        keyboardType: const TextInputType.numberWithOptions(decimal: true),
        inputFormatters: [
          PercentageInputFormatter(), //reusable
        ],
        filled: (viewModel.canEdit) ? false : true,
        readOnly: (viewModel.canEdit) ? false : true,
        onSaved: (value) {
          viewModel.contract.completionPercentage =
              double.tryParse(value.toString());
        },
      ),
    );
  }
}
