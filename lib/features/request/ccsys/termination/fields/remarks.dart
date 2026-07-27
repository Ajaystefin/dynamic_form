import "package:easy_localization/easy_localization.dart";
import "package:flutter/material.dart";
import "package:wcas_frontend/core/components/label.dart";
import "package:wcas_frontend/core/components/textarea.dart";
import "package:wcas_frontend/core/utils/validators.dart";
import "package:wcas_frontend/features/request/ccsys/termination/model.dart";

/// Remarks field widget.
class Remarks extends StatelessWidget {
  /// Creates a remarks widget.
  const Remarks({required this.viewModel, super.key});

  /// Termination view model.
  final CcsysTerminationViewModel viewModel;

  @override
  Widget build(BuildContext context) {
    return LabelWidget(
      label: "requestInformation.terminateWithdrawal.remarks".tr(),
      isRequired: viewModel.canEdit,
      child: CustomTextArea(
        readOnly: !viewModel.canEdit,
        filled: !viewModel.canEdit,
        controller: viewModel.remarksController,
        maxLength: 2000,
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
