import "package:easy_localization/easy_localization.dart";
import "package:flutter/material.dart";
import "package:wcas_frontend/core/components/dropdown/dropdown.dart";
import "package:wcas_frontend/core/components/label.dart";
import "package:wcas_frontend/core/constants/_reference_data_keys.dart";
import "package:wcas_frontend/core/constants/_server_constants.dart";
import "package:wcas_frontend/core/utils/utils.dart";
import "package:wcas_frontend/features/request/covenants_conditions/condition_edit_dialog/model.dart";
import "package:wcas_frontend/models/admin/reference.dart";

/// Status field for the condition edit dialog.
class StatusField extends StatelessWidget {
  /// Creates a status field.
  const StatusField({required this.viewModel, super.key});

  /// Condition edit dialog view model.
  final ConditionEditDialogViewModel viewModel;

  @override
  Widget build(BuildContext context) {
    return LabelWidget(
      isEnabled: viewModel.canEdit || viewModel.canEditComments,
      isRequired:
          !Utils.checkBusinessSegment(BusinessSegment.financialInstitution),
      label: "covenantsConditions.covenantEditDialog.status".tr(),
      child: CustomDropdown<Reference>(
        ignoreProvider: viewModel.canEditComments,
        semanticLabel: "covenantsConditions.covenantEditDialog.status".tr(),
        isEnabled: viewModel.canEditStatusAction || viewModel.canEditComments,
        validationMessage: viewModel.isUpdateCondition
            ? "common.validation.emptyField".tr()
            : null,
        items:
            viewModel.referenceData[ReferenceDataKeys.conditionStatus]?.where(
          (element) {
            return element.id != ServerConstants.conditionStatusNewId;
          },
        ).toList(),
        onSelected: (selectedValue) {
          viewModel.statusFieldChanged = selectedValue.first;
        },
        dropdownBuilder: (context, item) => Text(
          item?.name ?? "",
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
        ),
        itemBuilder: (context, item, {isDisabled, isSelected}) => ListTile(
          dense: true,
          title: Text(
            item.name ?? "",
          ),
        ),
        selectedItems: viewModel.selectedStatus != null
            ? [viewModel.selectedStatus]
            : null,
      ),
    );
  }
}
