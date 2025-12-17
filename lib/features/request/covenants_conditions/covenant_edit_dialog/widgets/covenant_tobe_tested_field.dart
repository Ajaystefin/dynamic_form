import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:wcas_frontend/core/components/label.dart';
import 'package:wcas_frontend/core/components/radiobutton.dart';
import 'package:wcas_frontend/core/constants/constants.dart';
import 'package:wcas_frontend/core/utils/validators.dart';
import 'package:wcas_frontend/features/request/covenants_conditions/covenant_edit_dialog/model.dart';

class CovenanToBeTestedField extends StatelessWidget {
  const CovenanToBeTestedField({super.key, required this.viewModel});
  final CovenantEditDialogViewModel viewModel;
  @override
  Widget build(BuildContext context) {
    return LabelWidget(
        isRequired: viewModel.isRequiredBusinessSegment,
        label:
            "covenantsConditions.covenantEditDialog.covenantsToBeTestedOn".tr(),
        labelStyle: AppStyle.tableHeaderStyle,
        child: CustomRadioButton<CovenantTestType?>(
            isEnabled: !viewModel.isReadOnly,
            options: const [CovenantTestType.rim, CovenantTestType.name],
            selectedValue: viewModel.selectedTestType,
            onChanged: (value) {
              viewModel.onCovenantTestChanged(value);
            },
            itemBuilder: (context, option, isSelected, isEnabled) => Text(
                  option == CovenantTestType.rim
                      ? option!.name.toUpperCase()
                      : StringExtension(option!.name).capitalizeFirstLetter(),
                ),
            validator: (value) =>
                CustomValidator.requiredField(value?.name ?? ""),
            isRequired: true,
            scrollDirection: Axis.horizontal));
  }
}

extension StringExtension on String {
  String capitalizeFirstLetter() {
    if (isEmpty) return this;
    return this[0].toUpperCase() + substring(1);
  }
}
