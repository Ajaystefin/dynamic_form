import "package:easy_localization/easy_localization.dart";
import "package:flutter/material.dart";
import "package:wcas_frontend/core/components/label.dart";
import "package:wcas_frontend/core/components/textarea.dart";
import "package:wcas_frontend/core/components/tooltip.dart";
import "package:wcas_frontend/core/utils/validators.dart";
import "package:wcas_frontend/features/request/projects/create_project/model.dart";

/// Summary field.
class Summary extends StatelessWidget {
  /// Creates a summary field.
  const Summary(this.viewModel, {super.key});

  /// Create project view model.
  final CreateProjectViewModel viewModel;

  @override
  Widget build(BuildContext context) {
    return LabelWidget(
      label: "project.createNewProject.summary".tr(),
      isRequired: true,
      child: CustomTooltip(
        message: !viewModel.isCreateProject
            ? (viewModel.project.projectSummary ?? "")
            : "",
        child: CustomTextArea(
          controller: viewModel.projectSummaryController,
          key: const ValueKey("Summary"),
          filled: !viewModel.canEdit,
          showMaximumLengthIndicator: false,
          readOnly: !viewModel.canEdit,
          semanticLabel: "project.createNewProject.summary".tr(),
          initialValue: !viewModel.isCreateProject
              ? viewModel.project.projectSummary
              : null,
          validator: CustomValidator.requiredField,
          counterText: "",
          maxLength: 1000,
          onSaved: (value) {
            viewModel.project.projectSummary = value;
          },
        ),
      ),
    );
  }
}
