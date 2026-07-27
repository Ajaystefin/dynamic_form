import "package:easy_localization/easy_localization.dart";
import "package:flutter/material.dart";
import "package:wcas_frontend/core/components/label.dart";
import "package:wcas_frontend/core/components/radiobutton.dart";
import "package:wcas_frontend/core/constants/_reference_data_keys.dart";
import "package:wcas_frontend/core/utils/utils.dart";
import "package:wcas_frontend/features/request/covenants_conditions/condition_edit_dialog/model.dart";
import "package:wcas_frontend/models/admin/reference.dart";

/// Condition description field for the condition edit dialog.
class ConditionDescriptionField extends StatelessWidget {
  /// Creates a condition description field.
  const ConditionDescriptionField({required this.viewModel, super.key});

  /// Condition edit dialog view model.
  final ConditionEditDialogViewModel viewModel;

  @override
  Widget build(BuildContext context) {
    return LabelWidget(
      isEnabled: viewModel.canEdit,
      isRequired:
          !Utils.checkBusinessSegment(BusinessSegment.financialInstitution),
      label: "covenantsConditions.conditionsEditDialog.description".tr(),
      child: CustomRadioButton<Reference>(
        options:
            viewModel.referenceData[ReferenceDataKeys.conditionStandard] ?? [],
        selectedValue: viewModel.selectedDescriptionType ?? Reference(),
        onChanged: (value) {
          viewModel.onDescriptionTypeChanged(value);
        },
        itemBuilder: (context, item, {bool? isSelected, bool? isEnabled}) =>
            Text(
          item.name ?? "",
          style: const TextStyle(fontSize: 12),
        ),
        isRequired:
            !Utils.checkBusinessSegment(BusinessSegment.financialInstitution),
        scrollDirection: Axis.horizontal,
        textStyle: const TextStyle(fontSize: 10),
      ),
    );
  }
}
