import "package:easy_localization/easy_localization.dart";
import "package:flutter/material.dart";
import "package:wcas_frontend/core/components/button.dart";
import "package:wcas_frontend/core/constants/constants.dart";
import "package:wcas_frontend/core/utils/utils.dart";
import "package:wcas_frontend/features/request/information/create_request/model.dart";

class ActionWidgets extends StatelessWidget {
  const ActionWidgets({required this.viewModel, super.key});
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

            viewModel.onSubmitButtonPress(isValidate);
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
