import "package:easy_localization/easy_localization.dart";
import "package:flutter/material.dart";
import "package:wcas_frontend/core/components/checkbox.dart";
import "package:wcas_frontend/core/components/label.dart";
import "package:wcas_frontend/features/request/covenants_conditions/condition_edit_dialog/model.dart";

/// Include in term checkbox field for the condition edit dialog.
class IncludeInTermField extends StatelessWidget {
  /// Creates an include in term field.
  const IncludeInTermField({required this.viewModel, super.key});

  /// Condition edit dialog view model.
  final ConditionEditDialogViewModel viewModel;

  @override
  Widget build(BuildContext context) {
    return LabelWidget(
      isEnabled: viewModel.canEdit,
      label: "",
      child: CustomCheckbox(
        onChange: ({value}) {
          viewModel.onIncludeTermChange(value: value);
        },
        onSaved: ({value}) {
          viewModel.onIncludeTermChange(value: value);
        },
        value: viewModel.includeInTermField,
        child: Text(
          "covenantsConditions.conditionsEditDialog.includeInTerm".tr(),
          semanticsLabel:
              "covenantsConditions.conditionsEditDialog.includeInTerm".tr(),
        ),
      ),
    );
  }
}
