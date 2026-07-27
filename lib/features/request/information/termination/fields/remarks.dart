import "package:easy_localization/easy_localization.dart";
import "package:flutter/material.dart";
import "package:wcas_frontend/core/components/label.dart";
import "package:wcas_frontend/core/components/textarea.dart";
import "package:wcas_frontend/core/utils/validators.dart";
import "package:wcas_frontend/features/request/information/termination/model.dart";

/// Displays the Remarks field on the Termination screen.
///
/// Allows users to enter, view, or update remarks related
/// to the termination request.
class Remarks extends StatelessWidget {
  /// Creates a [Remarks].
  const Remarks({
    required this.viewModel,
    super.key,
  });

  /// View model that provides termination data and
  /// manages remarks-related operations.
  final TerminationViewModel viewModel;

  @override
  Widget build(BuildContext context) {
    return LabelWidget(
      label: "requestInformation.terminateWithdrawal.remarks".tr(),
      isRequired: true,
      child: CustomTextArea(
        maxLength: 2000,
        readOnly: !viewModel.canEdit,
        filled: !viewModel.canEdit,
        hintText: "requestInformation.terminateWithdrawal.typeHere".tr(),
        validator:
            viewModel.comment == null ? null : CustomValidator.requiredField,
        initialValue:
            viewModel.comment != null ? viewModel.comment?.comment : "",
        onSaved: (String? value) {
          viewModel.comment?.comment = value;
        },
      ),
    );
  }
}
