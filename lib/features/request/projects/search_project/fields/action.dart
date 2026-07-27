import "package:easy_localization/easy_localization.dart";
import "package:flutter/material.dart";
import "package:wcas_frontend/core/components/button.dart";
import "package:wcas_frontend/features/request/projects/search_project/model.dart";

/// Action buttons for the search project screen.
class ActionButton extends StatelessWidget {
  /// Creates action buttons for search project submit and reset actions.
  const ActionButton({required this.viewModel, super.key});

  /// Search project view model.
  final SearchProjectViewModel viewModel;

  @override
  Widget build(BuildContext context) {
    // final bool isValid = viewModel.canEdit;
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      spacing: 4,
      children: [
        CustomButton(
          label: "project.searchProject.submit".tr(), //Submit
          semanticLabel: "project.searchProject.submit".tr(),
          onPressed:
              // isValid
              //     ? viewModel.viewAccessRolesCheck()
              //         ? null
              //         :
              () async {
            await viewModel.onSubmitPressed(context);
          },
          // : null
        ),
        CustomButton(
          label: "project.searchProject.reset".tr(), // reset
          semanticLabel: "project.searchProject.reset".tr(),
          onPressed:
              // isValid
              //     ? viewModel.viewAccessRolesCheck()
              //         ? null
              //         :
              () async {
            viewModel.onResetPressed(context);
          },
          // : null
        ),
      ],
    );
  }
}
