import "package:easy_localization/easy_localization.dart";
import "package:flutter/material.dart";
import "package:wcas_frontend/core/components/datepicker.dart";
import "package:wcas_frontend/core/components/label.dart";
import "package:wcas_frontend/core/utils/validators.dart";
import "package:wcas_frontend/features/request/projects/link_contract/model.dart";

/// Expected start date field for the link contract screen.
class ExpectedStartDate extends StatelessWidget {
  /// Creates an expected start date field.
  const ExpectedStartDate({required this.viewModel, super.key});

  /// Link contract view model.
  final LinkContractViewModel viewModel;

  @override
  Widget build(BuildContext context) {
    return LabelWidget(
      label: "project.linkContract.expextedStartDate".tr(),
      isRequired: true,
      child: CustomDatePicker(
        controller: viewModel.startDateController,
        key: const ValueKey("ExpectedStartDate"),
        semanticLabel: "project.linkContract.expextedStartDate".tr(),
        isEnabled: viewModel.canEdit,
        validator: (v) => CustomValidator.requiredFieldCustomMsg(
          v,
          "project.linkContract.pleaseSelectExpectedStartDate".tr(),
        ),
        onSubmit2: viewModel.onStartDateSubmitted2,
      ),
    );
  }
}
