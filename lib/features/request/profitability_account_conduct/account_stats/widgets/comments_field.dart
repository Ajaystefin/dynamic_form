import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:wcas_frontend/core/components/label.dart';
import 'package:wcas_frontend/core/components/textarea.dart';
import 'package:wcas_frontend/features/request/profitability_account_conduct/account_stats/model.dart';

class AccountStatsCommentsField extends StatelessWidget {
  final AccountStatsViewModel viewModel;
  const AccountStatsCommentsField({super.key, required this.viewModel});

  @override
  Widget build(BuildContext context) {
    return LabelWidget(
        label: "profitabilityAccountConduct.accountStats.rmComments".tr(),
        child: CustomTextArea(
          initialValue: viewModel.comment,
          onChanged: (value) {
            viewModel.comment = value;
          },
        ));
  }
}
