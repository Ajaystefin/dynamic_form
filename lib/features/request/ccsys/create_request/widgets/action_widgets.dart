import "package:easy_localization/easy_localization.dart";
import "package:flutter/material.dart";
import "package:wcas_frontend/core/components/button.dart";
import "package:wcas_frontend/core/constants/constants.dart";
import "package:wcas_frontend/features/request/ccsys/create_request/model.dart";

class ActionWidgets extends StatelessWidget {
  const ActionWidgets({required this.viewModel, super.key});
  final CcsysCreateRequestViewModel viewModel;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        CustomButton(
          // If submitButtonValidation() returns true when the form is valid:
          onPressed: viewModel.canEdit
              ? () {
                  viewModel.onSubmitButtonPress(context);
                }
              : null,
          label: "requestInformation.createRequest.submit".tr(),
        ),
        const SizedBox(width: AppStyle.spacingLarge),
        CustomButton(
          onPressed: viewModel.canEdit ? viewModel.onResetButtonPress : null,
          label: "requestInformation.createRequest.reset".tr(),
        ),
      ],
    );
  }
}
