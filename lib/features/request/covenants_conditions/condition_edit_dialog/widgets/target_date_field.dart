import "package:easy_localization/easy_localization.dart";
import "package:flutter/material.dart";
import "package:wcas_frontend/core/components/datepicker.dart";
import "package:wcas_frontend/core/components/label.dart";
import "package:wcas_frontend/features/request/covenants_conditions/condition_edit_dialog/model.dart";

class TargetDateField extends StatelessWidget {
  const TargetDateField({required this.viewModel, super.key});
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
