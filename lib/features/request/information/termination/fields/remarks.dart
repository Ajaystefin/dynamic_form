import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:wcas_frontend/core/components/label.dart';
import 'package:wcas_frontend/core/components/textarea.dart';
import 'package:wcas_frontend/core/utils/validators.dart';
import 'package:wcas_frontend/features/request/information/termination/model.dart';

class Remarks extends StatelessWidget {
  const Remarks({super.key, required this.viewModel});
  final TerminationViewModel viewModel;

  @override
  Widget build(BuildContext context) {
    final comment = viewModel.ensureFirstReviewCommentExists();

    return LabelWidget(
        label: 'requestInformation.terminateWithdrawal.remarks'.tr(),
        isRequired: true,
        child: CustomTextArea(
          maxLength: 2000,
          hintText: 'requestInformation.terminateWithdrawal.typeHere'.tr(),
          validator: (comment.comment?.isNotEmpty ?? false)
              ? null
              : CustomValidator.requiredField,
          initialValue: comment.comment ?? '',
          onSaved: (String? value) {
            comment.comment = value;
          },
        ));
  }
}
