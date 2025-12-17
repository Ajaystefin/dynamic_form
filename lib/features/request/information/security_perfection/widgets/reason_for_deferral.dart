import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:wcas_frontend/core/components/label.dart';
import 'package:wcas_frontend/core/components/textarea.dart';
import 'package:wcas_frontend/core/utils/validators.dart';
import 'package:wcas_frontend/features/request/information/security_perfection/model.dart';

class ReasonForDeferral extends StatelessWidget {
  final SecurityPerfectionViewModel viewModel;
  const ReasonForDeferral({super.key, required this.viewModel});

  @override
  Widget build(BuildContext context) {
    final String initialValue = viewModel.comments?[0].strategyComment ?? "";
    // final bool isValueEmpty = initialValue.trim().isEmpty;

    return LabelWidget(
      isRequired: true,
      label: "requestInformation.securityPerfection.reasonForDeferral".tr(),
      child: CustomTextArea(
        initialValue: initialValue,
        filled: !viewModel.canEdit,
        readOnly: !viewModel.canEdit,
        validator: CustomValidator.requiredField,
        onSaved: (String? value) {
          viewModel.comment?.strategyComment = value;
        },
      ),
    );
  }
}
