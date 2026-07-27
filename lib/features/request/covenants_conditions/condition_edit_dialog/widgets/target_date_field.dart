import "package:easy_localization/easy_localization.dart";
import "package:flutter/material.dart";
import "package:wcas_frontend/core/components/datepicker.dart";
import "package:wcas_frontend/core/components/label.dart";
import "package:wcas_frontend/features/request/covenants_conditions/condition_edit_dialog/model.dart";

/// Target date field for the condition edit dialog.
class TargetDateField extends StatelessWidget {
  /// Creates a target date field.
  const TargetDateField({required this.viewModel, super.key});

  /// Condition edit dialog view model.
  final ConditionEditDialogViewModel viewModel;

  @override
  Widget build(BuildContext context) {
    final String? rawDate = viewModel.isUpdateCondition
        ? viewModel.conditionData?.targetDate
        : viewModel.selectedTargetDate;

    final DateTime initial = viewModel.parseTargetDate(rawDate);

    return LabelWidget(
      isEnabled: viewModel.canEdit,
      label: "covenantsConditions.conditionsEditDialog.targetDate".tr(),
      child: CustomDatePicker(
        semanticLabel:
            "covenantsConditions.conditionsEditDialog.targetDate".tr(),
        isEnabled: !viewModel.isUpdateCondition,
        initialDateTime: viewModel.selectedTargetDate == null ? null : initial,
        labelText: viewModel.isUpdateCondition ? (rawDate ?? "") : null,
        onSubmit2: (selectedDate) {
          viewModel.onTargetDateChanged(selectedDate);
        },
      ),
    );
  }
}
