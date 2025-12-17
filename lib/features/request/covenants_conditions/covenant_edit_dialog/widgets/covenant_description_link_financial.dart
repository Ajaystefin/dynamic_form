import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:wcas_frontend/core/components/label.dart';
import 'package:wcas_frontend/core/components/radiobutton.dart';
import 'package:wcas_frontend/core/utils/validators.dart';
import 'package:wcas_frontend/features/request/covenants_conditions/covenant_edit_dialog/model.dart';

class CovenantDescriptionLinkFinancial extends StatelessWidget {
  const CovenantDescriptionLinkFinancial({super.key, required this.viewModel});
  final CovenantEditDialogViewModel viewModel;

  @override
  Widget build(BuildContext context) {
    viewModel.initializeFinancialSelectedDescriptionType();

    return LabelWidget(
      isRequired: viewModel.isRequiredBusinessSegment,
      label: "covenantsConditions.covenantEditDialog.covenantDescription".tr(),
      child: CustomRadioButton(
        isEnabled: !viewModel.isReadOnly,
        options: viewModel.descriptionTypes.map((ref) => ref.name).toList(),
        selectedValue: viewModel.selectedFinancialDescriptionType,
        onChanged: (value) {
          viewModel.onFinancialDescriptionTypeChange(value);
        },
        validator: (value) => CustomValidator.requiredField(value ?? ""),
        isRequired: true,
        scrollDirection: Axis.horizontal,
        textStyle: const TextStyle(fontSize: 12),
      ),
    );
  }
}
