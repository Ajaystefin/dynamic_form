import "package:easy_localization/easy_localization.dart";
import "package:flutter/material.dart";
import "package:wcas_frontend/core/components/dropdown/dropdown.dart"
    show CustomDropdown;
import "package:wcas_frontend/core/components/label.dart";
import "package:wcas_frontend/core/constants/_reference_data_keys.dart";
import "package:wcas_frontend/core/utils/utils.dart";
import "package:wcas_frontend/features/request/covenants_conditions/condition_edit_dialog/model.dart";
import "package:wcas_frontend/models/admin/reference.dart";

class FrequencyField extends StatelessWidget {
  const FrequencyField({required this.viewModel, super.key});
  final ConditionEditDialogViewModel viewModel;
  @override
  Widget build(BuildContext context) {
    return LabelWidget(
      isEnabled: viewModel.canEdit,
      isRequired:
          Utils.checkBusinessSegment(BusinessSegment.financialInstitution)
              ? false
              : true,
      label: "covenantsConditions.covenantEditDialog.frequency".tr(),
      child: CustomDropdown<Reference>(
        semanticLabel: "covenantsConditions.covenantEditDialog.frequency".tr(),
        validationMessage: "common.validation.emptyField".tr(),
        items:
            viewModel.referenceData[ReferenceDataKeys.conditionFrequency] ?? [],
        onSelected: (selectedValue) {
          viewModel.onFrequencyChange(selectedValue.first);
        },
        dropdownBuilder: (context, item) => Text(item?.name ?? ""),
        itemBuilder: (context, item, isDisabled, isSelected) => ListTile(
          dense: true,
          title: Text(
            item.name ?? "",
          ),
        ),
        selectedItems: viewModel.selectedFrequency != null
            ? [viewModel.selectedFrequency]
            : null,
      ),
    );
  }
}
