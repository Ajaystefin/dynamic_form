import "package:easy_localization/easy_localization.dart";
import "package:flutter/material.dart";
import "package:wcas_frontend/core/components/label.dart";
import "package:wcas_frontend/core/components/radiobutton.dart";
import "package:wcas_frontend/core/utils/validators.dart";
import "package:wcas_frontend/features/request/covenants_conditions/covenant_edit_dialog/model.dart";

class CovenantDescriptionLinkFinancial extends StatelessWidget {
  const CovenantDescriptionLinkFinancial({
    required this.viewModel,
    super.key,
    this.selectedValueOverride,
    this.onChangedOverride,
    this.isEnabledOverride,
  });

  final CovenantEditDialogViewModel viewModel;
  final String? selectedValueOverride;
  final ValueChanged<String?>? onChangedOverride;
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
