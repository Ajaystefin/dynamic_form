import "package:easy_localization/easy_localization.dart";
import "package:flutter/material.dart";
import "package:wcas_frontend/core/components/label.dart";
import "package:wcas_frontend/core/components/textfield.dart";
import "package:wcas_frontend/core/utils/logger.dart";
import "package:wcas_frontend/core/utils/validators.dart";
import "package:wcas_frontend/features/request/projects/create_project/model.dart";

class ProjectValue extends StatelessWidget {
  const ProjectValue(this.viewModel, {super.key});
  final CreateProjectViewModel viewModel;

  @override
  Widget build(BuildContext context) {
    return LabelWidget(
      label: "project.createNewProject.projectValue".tr(),
      isRequired: false,
      child: CustomTextField(
        controller: viewModel.projectValueController,
        key: const ValueKey("ProjectValue"),
        semanticLabel: "project.createNewProject.projectValue".tr(),
        initialValue: viewModel.isCreateProject
            ? ""
            : viewModel.project.projectValue != null ||
                    viewModel.project.projectValue != "null"
                ? viewModel.project.projectValue.toString()
                : "",
        inputFormatters: [
          NumericDecimalTextInputFormatter(
            maxIntegerDigits: 15, // ← your requirement
            maxDecimalDigits: 6, // ← your requirement
          ),
        ],
        keyboardType: const TextInputType.numberWithOptions(decimal: true),
        counterText: "",
        filled: (viewModel.canEdit) ? false : true,
        readOnly: (viewModel.canEdit) ? false : true,
        onChanged: (value) {
          viewModel.project.projectValue = value;
          logger.i(viewModel.project.projectValue);
        },
        onSaved: (String? value) {
          viewModel.project.projectValue = value ?? "";
        },
        // If required for validation enable this ****
        // validator: (value) {
        //   if (value == null || value.isEmpty) return null; // optional field
        //   // Enforce: up to 21 integer digits and up to 6 decimals
        //   final valid = RegExp(r'^\d{1,21}(\.\d{1,6})?$').hasMatch(value);
        //   // Also ensure there is at most one dot
        //   final dotCount = '.'.allMatches(value).length <= 1;
        //   if (!dotCount) return "Only one decimal point allowed.";
        //   if (!valid) return "Max 21 digits and up to 6 decimals.";
        //   return null;
        // },
      ),
    );
  }
}
