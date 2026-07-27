import "package:easy_localization/easy_localization.dart";
import "package:flutter/material.dart";
import "package:wcas_frontend/core/components/dropdown/dropdown.dart"
    show CustomDropdown;
import "package:wcas_frontend/core/components/label.dart";
import "package:wcas_frontend/core/constants/_reference_data_keys.dart";
import "package:wcas_frontend/core/utils/utils.dart";
import "package:wcas_frontend/features/request/covenants_conditions/condition_edit_dialog/model.dart";
import "package:wcas_frontend/models/admin/reference.dart";

/// Frequency field for the condition edit dialog.
class FrequencyField extends StatelessWidget {
  /// Creates a frequency field.
  const FrequencyField({required this.viewModel, super.key});

  /// Condition edit dialog view model.
  final ConditionEditDialogViewModel viewModel;

  @override
  Widget build(BuildContext context) {
    return LabelWidget(
      isEnabled: viewModel.canEdit,
      isRequired:
          !Utils.checkBusinessSegment(BusinessSegment.financialInstitution),
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
        itemBuilder: (context, item, {isDisabled, isSelected}) => ListTile(
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
