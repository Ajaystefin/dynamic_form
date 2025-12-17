import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:wcas_frontend/core/components/label.dart';
import 'package:wcas_frontend/core/components/textarea.dart';
import 'package:wcas_frontend/features/request/profitability_account_conduct/business_volume/model.dart';

class BussinessVolumeCommentsField extends StatelessWidget {
  final BusinessVolumeViewModel viewModel;
  const BussinessVolumeCommentsField({super.key, required this.viewModel});

  @override
  Widget build(BuildContext context) {
    return LabelWidget(
        label: "profitabilityAccountConduct.businessVolume.rmComments".tr(),
        child: CustomTextArea(
          semanticLabel:
              "profitabilityAccountConduct.businessVolume.rmComments".tr(),
          initialValue: viewModel.comments,
          onChanged: (value) {
            viewModel.comments = value;
          },
        ));
  }
}
