import "package:easy_localization/easy_localization.dart";
import "package:flutter/material.dart";
import "package:wcas_frontend/core/components/label.dart";
import "package:wcas_frontend/core/components/textarea.dart";
import "package:wcas_frontend/features/request/profitability_account_conduct/business_volume/model.dart";

/// Business volume comments field.
class BussinessVolumeCommentsField extends StatelessWidget {
  /// Creates a business volume comments field.
  const BussinessVolumeCommentsField({required this.viewModel, super.key});

  /// Business volume view model.
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
