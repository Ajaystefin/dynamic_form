import "package:easy_localization/easy_localization.dart";
import "package:flutter/material.dart";
import "package:wcas_frontend/core/components/button.dart";
import "package:wcas_frontend/features/request/group_information/add_cbrb_dialog/model.dart";

/// Action buttons widget for CBRB operations.
class ActionButton extends StatelessWidget {
  /// Creates an [ActionButton] widget.
  const ActionButton({required this.viewModel, super.key});

  /// View model used by the widget.
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
