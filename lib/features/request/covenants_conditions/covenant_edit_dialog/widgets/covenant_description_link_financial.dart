import "package:easy_localization/easy_localization.dart";
import "package:flutter/material.dart";
import "package:wcas_frontend/core/components/label.dart";
import "package:wcas_frontend/core/components/radiobutton.dart";
import "package:wcas_frontend/core/utils/validators.dart";
import "package:wcas_frontend/features/request/covenants_conditions/covenant_edit_dialog/model.dart";

/// Covenant description field for linked financial covenants.
class CovenantDescriptionLinkFinancial extends StatelessWidget {
  /// Creates a covenant description linked financial field.
  const CovenantDescriptionLinkFinancial({
    required this.viewModel,
    super.key,
    this.selectedValueOverride,
    this.onChangedOverride,
    this.isEnabledOverride,
  });

  /// Covenant edit dialog view model.
  final CovenantEditDialogViewModel viewModel;

  /// Optional selected value override.
  final String? selectedValueOverride;

  /// Optional change callback override.
  final ValueChanged<String?>? onChangedOverride;

  /// Optional enabled state override.
  final bool? isEnabledOverride;

  @override
  Widget build(BuildContext context) {
    // Preserve existing behavior for callers that don't override
    if (selectedValueOverride == null) {
      viewModel.initializeFinancialSelectedDescriptionType();
    }

    final bool isEnabled = (isEnabledOverride ?? true) && !viewModel.isReadOnly;
    final String? selected =
        selectedValueOverride ?? viewModel.selectedFinancialDescriptionType;

    return LabelWidget(
      isRequired: viewModel.isRequiredBusinessSegment,
      infoContent:
          "covenantsConditions.covenantEditDialog.customDescriptionToolTip"
              .tr(),
      label: "covenantsConditions.covenantEditDialog.covenantDescription".tr(),
      child: CustomRadioButton(
        isEnabled: isEnabled,
        options: viewModel.descriptionTypes.map((ref) => ref.name).toList(),
        selectedValue: selected,
        onChanged: (value) {
          if (onChangedOverride != null) {
            onChangedOverride!(value);
          } else {
            viewModel.onFinancialDescriptionTypeChange(value);
          }
        },
        validator: (value) => CustomValidator.requiredField(value ?? ""),
        isRequired: true,
        scrollDirection: Axis.horizontal,
        textStyle: const TextStyle(fontSize: 12),
      ),
    );
  }
}
