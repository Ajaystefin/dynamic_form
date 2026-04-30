import "package:easy_localization/easy_localization.dart";
import "package:flutter/material.dart";
import "package:wcas_frontend/core/components/label.dart";
import "package:wcas_frontend/core/components/textarea.dart";
import "package:wcas_frontend/features/request/profitability_account_conduct/business_volume/model.dart";

class BussinessVolumeCommentsField extends StatelessWidget {
  const BussinessVolumeCommentsField({required this.viewModel, super.key});
  final BusinessVolumeViewModel viewModel;

  @override
  Widget build(BuildContext context) {
    return LabelWidget(
      label: "profitabilityAccountConduct.businessVolume.rmComments".tr(),
      child: CustomTextArea(
        readOnly: !viewModel.canEdit,
        maxLength: 5000,
        semanticLabel:
            "profitabilityAccountConduct.businessVolume.rmComments".tr(),
        initialValue: viewModel.comments,
        onChanged: (value) {
          viewModel.comments = value;
        },
      ),
    );
  }
}
