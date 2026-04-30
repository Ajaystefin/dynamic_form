import "package:easy_localization/easy_localization.dart";
import "package:flutter/material.dart";
import "package:wcas_frontend/core/components/dropdown/dropdown.dart"
    show CustomDropdown;
import "package:wcas_frontend/core/components/label.dart";
import "package:wcas_frontend/core/constants/_reference_data_keys.dart";
import "package:wcas_frontend/core/utils/utils.dart";
import "package:wcas_frontend/features/request/covenants_conditions/condition_edit_dialog/model.dart";
import "package:wcas_frontend/features/request/covenants_conditions/condition_edit_dialog/state.dart";
import "package:wcas_frontend/models/admin/reference.dart";

class ConditionTypeField extends StatelessWidget {
  const ConditionTypeField({
    required this.viewModel,
    required this.state,
    super.key,
  });
  final ConditionEditDialogViewModel viewModel;
  final ConditionEditDialogState state;
  @override
  Widget build(BuildContext context) {
    return LabelWidget(
      isEnabled: viewModel.canEdit,
      isRequired:
          Utils.checkBusinessSegment(BusinessSegment.financialInstitution)
              ? false
              : true,
      label: "covenantsConditions.conditionsEditDialog.conditionType".tr(),
      child: CustomDropdown<Reference>(
        isLoading: state.fieldStatus == LoadingStatus.loading,
        semanticLabel:
            "covenantsConditions.conditionsEditDialog.conditionType".tr(),
        validationMessage: "common.validation.emptyField".tr(),
        items:
            viewModel.referenceData[ReferenceDataKeys.covenantConditionType] ??
                [],
        onSelected: (selectedValue) {
          viewModel.onConditionTypeSelection(selectedValue.first);
        },
        dropdownBuilder: (context, item) => Text(item?.name ?? ""),
        itemBuilder: (context, item, isDisabled, isSelected) => ListTile(
          dense: true,
          title: Text(
            item.name ?? "",
          ),
        ),
        selectedItems:
            viewModel.selectedType != null ? [viewModel.selectedType] : null,
      ),
    );
  }
}
