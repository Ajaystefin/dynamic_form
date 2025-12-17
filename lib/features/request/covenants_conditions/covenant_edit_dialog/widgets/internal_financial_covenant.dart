import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:wcas_frontend/core/components/label.dart';
import 'package:wcas_frontend/core/components/radiobutton.dart';
import 'package:wcas_frontend/core/constants/constants.dart';
import 'package:wcas_frontend/core/utils/text_utils.dart';
import 'package:wcas_frontend/core/utils/validators.dart';
import 'package:wcas_frontend/features/request/covenants_conditions/covenant_edit_dialog/model.dart';

class InternalFinancialCevenant extends StatelessWidget {
  const InternalFinancialCevenant({super.key, required this.viewModel});
  final CovenantEditDialogViewModel viewModel;
  @override
  Widget build(BuildContext context) {
    return LabelWidget(
        isRequired: viewModel.isRequiredBusinessSegment,
        label:
            "covenantsConditions.covenantEditDialog.internalFinancialCovenant"
                .tr(),
        labelStyle: AppStyle.tableHeaderStyle,
        child: CustomRadioButton<InternalFinancialCovenantType?>(
          isEnabled:  !viewModel.isReadOnly,
          options: const [
            InternalFinancialCovenantType.yes,
            InternalFinancialCovenantType.no
          ],
          selectedValue: viewModel.selectedInternalFinancialType,
          onChanged: (value) {
            viewModel.onInternalFinancialCovenantChanged(value);
          },
          itemBuilder: (context, option, isSelected, isEnabled) =>
              Text(option?.name.capitalizeFirstLetter() ?? ""),
          validator: (value) =>
              CustomValidator.requiredField(value?.name ?? ""),
          isRequired: true,
          scrollDirection: Axis.horizontal,
          textStyle: const TextStyle(fontSize: 12),
        ));
  }
}
