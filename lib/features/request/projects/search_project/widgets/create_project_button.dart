import "package:easy_localization/easy_localization.dart";
import "package:flutter/material.dart";
import "package:wcas_frontend/core/components/button.dart";
import "package:wcas_frontend/core/constants/constants.dart";
import "package:wcas_frontend/features/request/projects/search_project/model.dart";

/// Create project button for the search project screen.
class CreateProjectButton extends StatelessWidget {
  /// Creates a create project button.
  const CreateProjectButton({required this.viewModel, super.key});

  /// Search project view model.
  final SearchProjectViewModel viewModel;

  @override
  Widget build(BuildContext context) {
    final bool isValid = viewModel.canEdit;
    return CustomButton(
      label: "project.searchProject.createProject".tr(),
      semanticLabel: "project.searchProject.createProject".tr(),
      leadingIcon: const Icon(
        Icons.add,
        color: AppColors.white,
      ),
      onPressed: isValid
          ?
          // viewModel.viewAccessRolesCheck() ? null :
          () async {
              await viewModel.onCreateProjectPressed(context);
            }
          : null,
    );
  }
}
