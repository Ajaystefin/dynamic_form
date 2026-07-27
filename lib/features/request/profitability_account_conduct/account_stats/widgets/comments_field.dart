import "package:easy_localization/easy_localization.dart";
import "package:flutter/material.dart";
import "package:wcas_frontend/core/components/label.dart";
import "package:wcas_frontend/core/components/textarea.dart";
import "package:wcas_frontend/features/request/profitability_account_conduct/account_stats/model.dart";

/// Account stats comments field.
class AccountStatsCommentsField extends StatelessWidget {
  /// Creates an account stats comments field.
  const AccountStatsCommentsField({required this.viewModel, super.key});

  /// Account stats view model.
  final AccountStatsViewModel viewModel;

  @override
  Widget build(BuildContext context) {
    return LabelWidget(
      label: "profitabilityAccountConduct.accountStats.rmComments".tr(),
      child: CustomTextArea(
        readOnly: !viewModel.canEdit,
        maxLength: 5000,
        initialValue: viewModel.comment,
        onChanged: (value) {
          viewModel.comment = value;
        },
      ),
    );
  }
}
