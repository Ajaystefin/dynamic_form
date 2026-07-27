import "package:easy_localization/easy_localization.dart";
import "package:flutter/material.dart";
import "package:wcas_frontend/core/components/dropdown/dropdown.dart";
import "package:wcas_frontend/core/components/label.dart";
import "package:wcas_frontend/core/constants/_reference_data_keys.dart";
import "package:wcas_frontend/features/request/covenants_conditions/covenant_edit_dialog/model.dart";
import "package:wcas_frontend/models/admin/reference.dart";

/// Period field for the covenant edit dialog.
class PeriodField extends StatelessWidget {
  /// Creates a period field.
  const PeriodField({required this.viewModel, super.key});

  /// Covenant edit dialog view model.
  final CovenantEditDialogViewModel viewModel;

  @override
  Widget build(BuildContext context) {
    return LabelWidget(
      label: "covenantsConditions.covenantEditDialog.period".tr(),
      isRequired: viewModel.isRequiredBusinessSegment,
      child: CustomDropdown<Reference>(
        isEnabled: !viewModel.isReadOnly,
        hintText: "common.selectValue".tr(),
        semanticLabel: "covenantsConditions.covenantEditDialog.period".tr(),
        validationMessage: "common.validation.emptyField".tr(),
        items: viewModel.referenceData[ReferenceDataKeys.covenantPeriod] ?? [],
        onSelected: (selectedValue) {
          viewModel.onCovenantPeriodSelect(selectedValue);
        },
        dropdownBuilder: (context, item) =>
            dropdownBuilderWidget(text: item?.name),
        itemBuilder: (context, item, {isDisabled, isSelected}) {
          return dropdownItemBuildWidget(
            item.name,
            isSelected: isSelected ?? false,
          );
        },
        selectedItems: viewModel.selectedPeriod?.id != null
            ? [viewModel.selectedPeriod]
            : [],
      ),
    );
  }
}
