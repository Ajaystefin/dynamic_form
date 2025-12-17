import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:wcas_frontend/core/components/label.dart';
import 'package:wcas_frontend/core/components/textarea.dart';
import 'package:wcas_frontend/core/components/tooltip.dart';
import 'package:wcas_frontend/features/request/customer_information/sic_code_review/model.dart';

class AccountLevelSicCode extends StatelessWidget {
  const AccountLevelSicCode({super.key, required this.viewModel});
  final SicCodeReviewViewModel viewModel;
  @override
  Widget build(BuildContext context) {
    return LabelWidget(
      label: "customerInformation.sicCodeReview.accountLevelSICcode".tr(),
      child: CustomTooltip(
        message: "customerInformation.sicCodeReview.maxCharSicCode".tr(),
        child: CustomTextArea(
            hintText: "customerInformation.sicCodeReview.typeHere".tr(),
            autoFocus: false,
            maxLength: 1000,
            initialValue: (viewModel.comments ?? []).isNotEmpty
                ? viewModel.comments?.first.strategyComment ?? ""
                : "",
            onSaved: (value) {
              viewModel.comment.strategyComment = value;
              if ((viewModel.comments ?? []).isNotEmpty) {
                viewModel.comment.id = viewModel.comments?.first.id;
              }
            }),
      ),
    );
  }
}
