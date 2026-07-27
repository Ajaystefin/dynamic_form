import "package:easy_localization/easy_localization.dart";
import "package:flutter/material.dart";
import "package:wcas_frontend/core/components/button.dart";
import "package:wcas_frontend/core/constants/constants.dart";
import "package:wcas_frontend/core/utils/utils.dart";
import "package:wcas_frontend/features/request/information/create_request/model.dart";

/// Displays the action controls for the Create Request screen.
///
/// Provides access to actions such as navigation, saving,
/// and progressing through the request creation workflow.
class ActionWidgets extends StatelessWidget {
  /// Creates an [ActionWidgets].
  const ActionWidgets({
    required this.viewModel,
    super.key,
  });

  /// View model that handles the Create Request screen state
  /// and action processing.
  final CreateRequestViewModel viewModel;

  @override
  Widget build(BuildContext context) {
    return Row(
      spacing: AppStyle.spacingLarge,
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        CustomButton(
          isLoading: viewModel.submitLoadingStatus == LoadingStatus.loading,
          onPressed: () {
            final bool isValidate =
                viewModel.formKey.currentState?.validate() ?? false;

            viewModel.onSubmitButtonPress(isValidated: isValidate);
          },
          label: "requestInformation.createRequest.submit".tr(),
        ),
        CustomButton(
          onPressed: () {
            viewModel.onResetButtonPress();
          },
          label: "requestInformation.createRequest.reset".tr(),
        ),
      ],
    );
  }
}
