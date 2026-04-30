import "package:easy_localization/easy_localization.dart";
import "package:flutter/material.dart";
import "package:wcas_frontend/core/components/checkbox.dart";
import "package:wcas_frontend/core/components/label.dart";
import "package:wcas_frontend/features/request/covenants_conditions/condition_edit_dialog/model.dart";

class IncludeInTermField extends StatelessWidget {
  const IncludeInTermField({required this.viewModel, super.key});
  final ConditionEditDialogViewModel viewModel;
  @override
  Widget build(BuildContext context) {
    return LabelWidget(
      isEnabled: viewModel.canEdit,
      label: "",
      child: CustomCheckbox(
        onChange: (value) {
          viewModel.onIncludeTermChange(value);
        },
        onSaved: (value) {
          viewModel.onIncludeTermChange(value);
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
