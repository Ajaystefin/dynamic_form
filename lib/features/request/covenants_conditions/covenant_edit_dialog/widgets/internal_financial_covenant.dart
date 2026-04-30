import "package:easy_localization/easy_localization.dart";
import "package:flutter/material.dart";
import "package:wcas_frontend/core/components/label.dart";
import "package:wcas_frontend/core/components/radiobutton.dart";
import "package:wcas_frontend/core/constants/constants.dart";
import "package:wcas_frontend/core/utils/text_utils.dart";
import "package:wcas_frontend/core/utils/validators.dart";
import "package:wcas_frontend/features/request/covenants_conditions/covenant_edit_dialog/model.dart";

class InternalFinancialCevenant extends StatelessWidget {
  const InternalFinancialCevenant({
    required this.viewModel,
    super.key,
    this.selectedValueOverride,
    this.onChangedOverride,
    this.isEnabledOverride,
  });

  final CovenantEditDialogViewModel viewModel;

  // NEW (optional)
  final InternalFinancialCovenantType? selectedValueOverride;
  final ValueChanged<InternalFinancialCovenantType?>? onChangedOverride;
  final bool? isEnabledOverride;

  @override
  Widget build(BuildContext context) {
    final bool isEnabled = (isEnabledOverride ?? true) && !viewModel.isReadOnly;

    return LabelWidget(
      isRequired: viewModel.isRequiredBusinessSegment,
      label: "covenantsConditions.covenantEditDialog.internalFinancialCovenant"
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
        itemBuilder: (context, option, isSelected, isEnabled) =>
            Text(option?.name.capitalizeFirstLetter() ?? ""),
        validator: (value) => CustomValidator.requiredField(value?.name ?? ""),
        isRequired: true,
        scrollDirection: Axis.horizontal,
        textStyle: const TextStyle(fontSize: 12),
      ),
    );
  }
}
