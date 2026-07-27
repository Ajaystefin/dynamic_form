import "package:easy_localization/easy_localization.dart";
import "package:flutter/material.dart";
import "package:wcas_frontend/core/components/dropdown/dropdown.dart";
import "package:wcas_frontend/core/components/label.dart";
import "package:wcas_frontend/core/constants/_reference_data_keys.dart";
import "package:wcas_frontend/core/constants/_server_constants.dart";
import "package:wcas_frontend/features/request/covenants_conditions/covenant_edit_dialog/model.dart";
import "package:wcas_frontend/models/admin/reference.dart";

/// Action field for the covenant edit dialog.
class ActionField extends StatelessWidget {
  /// Creates an action field.
  const ActionField({
    required this.viewModel,
    super.key,
    this.forceEmptySelection = false,
  });

  /// Covenant edit dialog view model.
  final CovenantEditDialogViewModel viewModel;

  /// Whether to force empty selection.
  final bool forceEmptySelection;

  @override
  Widget build(BuildContext context) {
    return LabelWidget(
      label: "covenantsConditions.covenantEditDialog.action".tr(),
      isRequired: viewModel.isRequiredBusinessSegment,
      child: CustomDropdown<Reference>(
        ignoreProvider: viewModel.canEditComments,
        hintText: "common.selectValue".tr(),
        isEnabled: viewModel.canEditStatusAction || viewModel.canEditComments,
        validationMessage: "common.validation.emptyField".tr(),
        semanticLabel: "covenantsConditions.covenantEditDialog.action".tr(),
        items: (viewModel
                    .referenceData[ReferenceDataKeys.covenantConditionAction] ??
                const <Reference>[])
            .where(
              (ref) => !((viewModel.canEditStatusAction ||
                      viewModel.canEditComments) &&
                  ref.id == ServerConstants.covenantCreateActionId),
            )
            .toList(),
        onSelected: (selectedValue) =>
            viewModel.setSelectedAction(selectedValue.first),
        dropdownBuilder: (context, item) =>
            dropdownBuilderWidget(text: item?.name),
        itemBuilder: (context, item, {isDisabled, isSelected}) {
          return dropdownItemBuildWidget(
            item.name,
            isSelected: isSelected ?? false,
          );
        },
        selectedItems: viewModel.getSelectedActionItems(
          forceEmptySelection: forceEmptySelection,
        ),
      ),
    );
  }
}
