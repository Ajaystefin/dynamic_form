import "package:easy_localization/easy_localization.dart";
import "package:flutter/material.dart";
import "package:wcas_frontend/core/components/button.dart";
import "package:wcas_frontend/core/constants/constants.dart";
import "package:wcas_frontend/features/request/projects/search_project/model.dart";

/// Back to request status button for the search project screen.
class BackToRequestStatus extends StatelessWidget {
  /// Creates a back to request status button.
  const BackToRequestStatus({required this.viewModel, super.key});

  /// Search project view model.
  final SearchProjectViewModel viewModel;

  @override
  Widget build(BuildContext context) {
    return CustomButton(
      label: "project.searchProject.backToRequestStatus".tr(),
      semanticLabel: "project.searchProject.backToRequestStatus".tr(),
      leadingIcon: const Icon(
        Icons.arrow_back,
        color: AppColors.white,
      ),
      onPressed: () async {
        await viewModel.onBackToRequestStausPressed(context);
      },
    );
  }
}
