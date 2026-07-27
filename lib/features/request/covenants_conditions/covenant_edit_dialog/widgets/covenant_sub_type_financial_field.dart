import "package:easy_localization/easy_localization.dart";
import "package:flutter/material.dart";
import "package:wcas_frontend/core/components/dropdown/dropdown.dart";
import "package:wcas_frontend/core/components/label.dart";
import "package:wcas_frontend/core/constants/constants.dart";
import "package:wcas_frontend/features/request/covenants_conditions/covenant_edit_dialog/model.dart";
import "package:wcas_frontend/models/admin/reference.dart";

/// Covenant subtype financial field for the covenant edit dialog.
class CovenantSubTypeFinancialField extends StatelessWidget {
  /// Creates a covenant subtype financial field.
  const CovenantSubTypeFinancialField({
    required this.viewModel,
    super.key,
    this.selectedItem,
    this.forceEmptySelection = false,
    this.overrideEnablement,
    this.onSelectedOverride,
  });

  /// Covenant edit dialog view model.
  final CovenantEditDialogViewModel viewModel;

  /// Selected covenant subtype item.
  final Reference? selectedItem;

  /// Whether to force empty selection.
  final bool forceEmptySelection;

  /// Optional enablement override.
  final bool? overrideEnablement;

  /// Optional selected callback override.
  final void Function(List<Reference>)? onSelectedOverride;

  @override
  Widget build(BuildContext context) {
    final bool isEnabled =
        overrideEnablement ?? viewModel.isFinancialSubtypeEnabled;
    return LabelWidget(
      isRequired: viewModel.isRequiredBusinessSegment,
      label: "covenantsConditions.covenantEditDialog.covenantSubtype".tr(),
      child: CustomDropdown<Reference>(
        key: ValueKey<bool>(forceEmptySelection),
        hintText: "common.selectValue".tr(),
        isEnabled: isEnabled && !viewModel.isReadOnly,
        semanticLabel:
            "covenantsConditions.covenantEditDialog.covenantSubtype".tr(),
        validationMessage: "common.validation.emptyField".tr(),
        items: viewModel.getFilteredFinancialCovenantSubtypes(),
        onSelected:
            onSelectedOverride ?? viewModel.onFinancialCovenantSubTypeSelect,
        dropdownBuilder: (context, item) => dropdownBuilderWidget(
          text: item?.name,
        ),
        itemBuilder: (context, item, {isDisabled, isSelected}) {
          return Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 12),
            color: (isSelected ?? false)
                ? AppColors.textFieldDisabledFillDarker
                : null,
            child: Text(
              item.name ?? "",
              softWrap: true,
              overflow: TextOverflow.visible,
              style: const TextStyle(fontSize: 12),
            ),
          );
        },
        selectedItems: viewModel.getSelectedFinancialSubtype(
          selectedItem,
          forceEmpty: forceEmptySelection,
        ),
      ),
    );
  }
}
