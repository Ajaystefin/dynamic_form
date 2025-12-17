import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:wcas_frontend/core/components/label.dart';
import 'package:wcas_frontend/core/components/textarea.dart';
import 'package:wcas_frontend/core/utils/validators.dart';
import 'package:wcas_frontend/features/request/information/present_request/model.dart';

class PresentComments extends StatelessWidget {
  final PresentRequestViewModel viewModel;
  const PresentComments({super.key, required this.viewModel});

  @override
  Widget build(BuildContext context) {
    return LabelWidget(
      label:
          "requestInformation.presentRequest.transactionApprovalRequestDetails"
              .tr(),
      child: CustomTextArea(
        initialValue: (viewModel.comments ?? []).isNotEmpty
            ? viewModel.comments?.first.strategyComment ?? ""
            : "",
        validator: CustomValidator.requiredField,
        onSaved: (String? value) {
          viewModel.comment.strategyComment = value;
          viewModel.comment.id = viewModel.comments?.first.id;
        },
      ),
    );
  }
}
