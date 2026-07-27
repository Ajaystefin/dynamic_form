import "package:easy_localization/easy_localization.dart";
import "package:flutter/material.dart";
import "package:wcas_frontend/core/components/dropdown/dropdown.dart";
import "package:wcas_frontend/core/components/label.dart";
import "package:wcas_frontend/core/constants/constants.dart";
import "package:wcas_frontend/features/request/covenants_conditions/covenant_edit_dialog/model.dart";
import "package:wcas_frontend/models/admin/reference.dart";

/// Financial subtype dropdown for the covenant edit dialog desktop view.
class FinancialSubtypeDropdownDesktop extends StatelessWidget {
  /// Creates a financial subtype dropdown for desktop.
  const FinancialSubtypeDropdownDesktop({
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
    final bool isEnabled =
        viewModel.isFinancialSubtypeEnabled && !viewModel.isReadOnly;

    return LabelWidget(
      isRequired: viewModel.isRequiredBusinessSegment,
      label: "covenantsConditions.covenantEditDialog.covenantSubtype".tr(),
      child: CustomDropdown<Reference>(
        key: const ValueKey("desktop-subtype"),
        hintText: "common.selectValue".tr(),
        isEnabled: isEnabled,
        semanticLabel:
            "covenantsConditions.covenantEditDialog.covenantSubtype".tr(),
        validationMessage: "common.validation.emptyField".tr(),
        items: viewModel.getFilteredFinancialCovenantSubtypes(),
        onSelected: viewModel.onFinancialCovenantSubTypeSelect,
        dropdownBuilder: (context, item) =>
            dropdownBuilderWidget(text: item?.name),
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
        // Preserve your existing global-selected behavior for the top block
        selectedItems: viewModel.getSelectedFinancialSubtype(
          viewModel.selectedFinancialCovenantSubType,
          forceEmpty: forceEmptySelection,
        ),
      ),
    );
  }
}
