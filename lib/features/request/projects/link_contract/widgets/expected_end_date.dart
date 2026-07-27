import "package:easy_localization/easy_localization.dart";
import "package:flutter/material.dart";
import "package:wcas_frontend/core/components/datepicker.dart";
import "package:wcas_frontend/core/components/label.dart";
import "package:wcas_frontend/core/utils/validators.dart";
import "package:wcas_frontend/features/request/projects/link_contract/model.dart";

/// Expected end date field for the link contract screen.
class ExpectedEndDate extends StatelessWidget {
  /// Creates an expected end date field.
  const ExpectedEndDate({required this.viewModel, super.key});

  /// Link contract view model.
  final LinkContractViewModel viewModel;

  @override
  Widget build(BuildContext context) {
    return LabelWidget(
      label: "project.linkContract.expectedCompletionDate".tr(),
      isRequired: true,
      child: CustomDatePicker(
        controller: viewModel.completionDateController,
        key: const ValueKey("ExpectedEndDate"),
        semanticLabel: "project.linkContract.expectedCompletionDate".tr(),
        isEnabled: viewModel.canEdit,
        //viewModel.completionDateController.text.isNotEmpty ?
        //    DateTime.tryParse(viewModel.completionDateController.text) : null,
        onSubmit2: viewModel.onCompletionDateSubmitted2,
        validator: (v) => CustomValidator.requiredFieldCustomMsg(
          v,
          "project.linkContract.pleaseSelectExpectedEndDate".tr(),
        ),
      ),
    );
  }
}
