import "package:easy_localization/easy_localization.dart";
import "package:flutter/material.dart";
import "package:wcas_frontend/core/components/button.dart";
import "package:wcas_frontend/features/request/group_information/add_cbrb_dialog/model.dart";

class ActionButton extends StatelessWidget {
  const ActionButton({required this.viewModel, super.key});
  final AddCbrbDialogViewModel viewModel;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.end,
      mainAxisAlignment: MainAxisAlignment.end,
      spacing: 10,
      children: [
        CustomButton(
          label: "groupInformation.facilitiesWithOtherBanks.save".tr(),
          semanticLabel: "groupInformation.facilitiesWithOtherBanks.save".tr(),
          onPressed: () {
            viewModel.onSaveButtonPressedCBRB(context);
          },
        ),
        CustomButton(
          label: "groupInformation.facilitiesWithOtherBanks.cancel".tr(),
          semanticLabel:
              "groupInformation.facilitiesWithOtherBanks.cancel".tr(),
          onPressed: () {
            viewModel.onCancelButtonPressedCBRB(context);
          },
        ),
      ],
    );
  }
}
