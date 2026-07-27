import "package:easy_localization/easy_localization.dart";
import "package:flutter/material.dart";
import "package:wcas_frontend/core/components/label.dart";
import "package:wcas_frontend/core/components/textarea.dart";
import "package:wcas_frontend/core/utils/validators.dart";
import "package:wcas_frontend/features/request/information/present_request/model.dart";

/// Displays the comments section for the Present Request screen.
///
/// Presents existing request comments and supports comment-related
/// interactions using data provided by the view model.
class PresentComments extends StatelessWidget {
  /// Creates a [PresentComments].
  const PresentComments({
    required this.viewModel,
    super.key,
  });

  /// View model that supplies request data and manages
  /// comment-related operations.
  final PresentRequestViewModel viewModel;

  @override
  Widget build(BuildContext context) {
    return LabelWidget(
      label:
          "requestInformation.presentRequest.transactionApprovalRequestDetails"
              .tr(),
      child: CustomTextArea(
        initialValue: (viewModel.comments ?? []).isNotEmpty
            ? (viewModel.comments?.first.strategyComment ?? "")
            : (viewModel.comment.strategyComment ?? ""),
        validator: CustomValidator.requiredField,

        onChanged: (value) {
          // ALWAYS push current value to VM
          viewModel.comment.strategyComment = value;

          if ((viewModel.comments ?? []).isNotEmpty) {
            viewModel.comments!.first.strategyComment = value;
          }
        },

        // onSaved: (String? value) {
        //   final safeValue = value ?? "";

        //   viewModel.comment.strategyComment = safeValue;
        //   viewModel.comment.id = viewModel.comments?.first.id;

        //   if ((viewModel.comments ?? []).isNotEmpty) {
        //     viewModel.comments!.first.strategyComment = safeValue;
        //     viewModel.comments!.first.id = viewModel.comment.id;
        //   }
        // },
      ),
    );
  }
}
