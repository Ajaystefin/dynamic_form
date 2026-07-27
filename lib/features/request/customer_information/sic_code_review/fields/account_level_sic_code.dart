import "package:easy_localization/easy_localization.dart";
import "package:flutter/material.dart";
import "package:wcas_frontend/core/components/label.dart";
import "package:wcas_frontend/core/components/textarea.dart";
import "package:wcas_frontend/core/components/tooltip.dart";
import "package:wcas_frontend/features/request/customer_information/sic_code_review/model.dart";

/// Account level SIC code field for the SIC code review screen.
class AccountLevelSicCode extends StatelessWidget {
  /// Creates an account level SIC code field.
  const AccountLevelSicCode({required this.viewModel, super.key});

  /// SIC code review view model.
  final SicCodeReviewViewModel viewModel;

  @override
  Widget build(BuildContext context) {
    return LabelWidget(
      label: "customerInformation.sicCodeReview.accountLevelSICcode".tr(),
      child: CustomTooltip(
        message: "customerInformation.sicCodeReview.maxCharSicCode".tr(),
        child: CustomTooltip(
          message: "customerInformation.sicCodeReview.maxCharSicCode".tr(),
          child: CustomTextArea(
            hintText: "customerInformation.sicCodeReview.typeHere".tr(),
            maxLength: 1000,
            controller: viewModel.controllerAccountLevelSicCode,
            // Correct initial value → load matched comment
            initialValue: viewModel.comment.strategyComment ?? "",
            readOnly:
                !(viewModel.canEdit || viewModel.otherCACCPBDPRolesCheck()),
            filled: !(viewModel.canEdit || viewModel.otherCACCPBDPRolesCheck()),
            onSaved: (value) {
              viewModel.comment.strategyComment = value;
            },
          ),
        ),
      ),
    );
  }
}
