import "package:easy_localization/easy_localization.dart";
import "package:flutter/material.dart";
import "package:wcas_frontend/core/components/label.dart";
import "package:wcas_frontend/core/components/textarea.dart";
import "package:wcas_frontend/core/utils/validators.dart";
import "package:wcas_frontend/features/request/information/security_perfection/model.dart";
import "package:wcas_frontend/models/request/comment.dart";

/// Displays the reason for deferral field.
class ReasonForDeferral extends StatelessWidget {
  /// Creates a [ReasonForDeferral] widget.
  const ReasonForDeferral({required this.viewModel, super.key});

  /// View model used by the widget.
  final SecurityPerfectionViewModel viewModel;

  @override
  Widget build(BuildContext context) {
    final String initialValue =
        (viewModel.comment != null ? viewModel.comment?.comment : "") ??
            ((viewModel.comments.isNotEmpty)
                ? viewModel.comments[0].strategyComment
                : "") ??
            "";
    // final bool isValueEmpty = initialValue.trim().isEmpty;

    return LabelWidget(
      isRequired: !viewModel.isFI,
      label: "requestInformation.securityPerfection.reasonForDeferral".tr(),
      child: CustomTextArea(
        initialValue: initialValue,
        filled: !viewModel.canEdit,
        readOnly: !viewModel.canEdit,
        validator: (viewModel.isFI) ? null : CustomValidator.requiredField,
        onSaved: (String? value) {
          if (viewModel.comments.isEmpty) {
            viewModel.comments = [Comment()];
          }
          viewModel.comment?.comment = value;
          viewModel.comments[0].strategyComment = value ?? "";
          viewModel.comment?.strategyComment = value ?? "";
        },
      ),
    );
  }
}
