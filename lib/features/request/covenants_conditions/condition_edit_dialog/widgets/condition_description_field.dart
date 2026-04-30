import "package:easy_localization/easy_localization.dart";
import "package:flutter/material.dart";
import "package:wcas_frontend/core/components/label.dart";
import "package:wcas_frontend/core/components/radiobutton.dart";
import "package:wcas_frontend/core/constants/_reference_data_keys.dart";
import "package:wcas_frontend/core/utils/utils.dart";
import "package:wcas_frontend/features/request/covenants_conditions/condition_edit_dialog/model.dart";
import "package:wcas_frontend/models/admin/reference.dart";

class ConditionDescriptionField extends StatelessWidget {
  const ConditionDescriptionField({required this.viewModel, super.key});
  final ConditionEditDialogViewModel viewModel;
  @override
  Widget build(BuildContext context) {
    return LabelWidget(
      isEnabled: viewModel.canEdit,
      isRequired:
          Utils.checkBusinessSegment(BusinessSegment.financialInstitution)
              ? false
              : true,
      label: "covenantsConditions.conditionsEditDialog.description".tr(),
      child: CustomRadioButton<Reference>(
        options:
            viewModel.referenceData[ReferenceDataKeys.conditionStandard] ?? [],
        selectedValue: viewModel.selectedDescriptionType ?? Reference(),
        onChanged: (value) {
          viewModel.onDescriptionTypeChanged(value);
        },
        itemBuilder: (context, item, isSelected, isEnabled) => Text(
          item.name ?? "",
          style: const TextStyle(fontSize: 12),
        ),
        isRequired:
            Utils.checkBusinessSegment(BusinessSegment.financialInstitution)
                ? false
                : true,
        scrollDirection: Axis.horizontal,
        textStyle: const TextStyle(fontSize: 10),
      ),
    );
  }
}
