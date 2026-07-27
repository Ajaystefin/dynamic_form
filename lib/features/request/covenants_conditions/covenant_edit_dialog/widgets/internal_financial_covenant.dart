import "package:easy_localization/easy_localization.dart";
import "package:flutter/material.dart";
import "package:wcas_frontend/core/components/label.dart";
import "package:wcas_frontend/core/components/radiobutton.dart";
import "package:wcas_frontend/core/constants/constants.dart";
import "package:wcas_frontend/core/utils/text_utils.dart";
import "package:wcas_frontend/core/utils/validators.dart";
import "package:wcas_frontend/features/request/covenants_conditions/covenant_edit_dialog/model.dart";

/// Internal financial covenant field for the covenant edit dialog.
class InternalFinancialCevenant extends StatelessWidget {
  /// Creates an internal financial covenant field.
  const InternalFinancialCevenant({
    required this.viewModel,
    super.key,
    this.selectedValueOverride,
    this.onChangedOverride,
    this.isEnabledOverride,
  });

  /// Covenant edit dialog view model.
  final CovenantEditDialogViewModel viewModel;

  // NEW (optional)

  /// Optional selected internal financial covenant value override.
  final InternalFinancialCovenantType? selectedValueOverride;

  /// Optional change callback override.
  final ValueChanged<InternalFinancialCovenantType?>? onChangedOverride;

  /// Optional enabled state override.
  final bool? isEnabledOverride;

  @override
  Widget build(BuildContext context) {
    final bool isEnabled = (isEnabledOverride ?? true) && !viewModel.isReadOnly;

    return LabelWidget(
      isRequired: viewModel.isRequiredBusinessSegment,
      label: "covenantsConditions.covenantEditDialog.internalFinancialCovenant"
          .tr(),
      infoContent:
          "covenantsConditions.covenantEditDialog.internalFinancialCovenantInfo"
              .tr(),
      labelStyle: AppStyle.tableHeaderStyle,
      child: CustomRadioButton<InternalFinancialCovenantType?>(
        isEnabled: isEnabled,
        options: const [
          InternalFinancialCovenantType.yes,
          InternalFinancialCovenantType.no,
        ],
        selectedValue:
            selectedValueOverride ?? viewModel.selectedInternalFinancialType,
        onChanged: (value) {
          if (onChangedOverride != null) {
            onChangedOverride!(value);
          } else {
            viewModel.onInternalFinancialCovenantChanged(value);
          }
        },
        itemBuilder: (context, option, {bool? isSelected, bool? isEnabled}) =>
            Text(option?.name.capitalizeFirstLetter() ?? ""),
        validator: (value) => CustomValidator.requiredField(value?.name ?? ""),
        isRequired: true,
        scrollDirection: Axis.horizontal,
        textStyle: const TextStyle(fontSize: 12),
      ),
    );
  }
}
