import "package:easy_localization/easy_localization.dart";
import "package:flutter/material.dart";
import "package:wcas_frontend/core/components/button.dart";
import "package:wcas_frontend/features/request/ccsys/approval/model.dart";

class SaveButton extends StatelessWidget {
  const SaveButton({required this.viewModel, super.key});
  final CcsysApprovalViewModel viewModel;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        CustomButton(
          label: "common.save".tr(),
          onPressed: (!viewModel.canEdit)
              ? null
              : () async {
                  await viewModel.onSavePress(context, "saveAndContinue");
                },
        ),
      ],
    );
  }
}
