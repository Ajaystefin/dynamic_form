import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:wcas_frontend/core/components/button.dart';
import 'package:wcas_frontend/core/constants/constants.dart';
import 'package:wcas_frontend/features/request/ccsys/create_request/model.dart';


class ActionWidgets extends StatelessWidget {
  final CcsysCreateRequestViewModel viewModel;
  const ActionWidgets({super.key, required this.viewModel});

  @override
  Widget build(BuildContext context) {
    return Row(
      spacing: AppStyle.spacingLarge,
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        CustomButton(
          onPressed:viewModel.submitButtonValidation()?
              null : viewModel.onSubmitButtonPress,
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
