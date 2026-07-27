import "package:easy_localization/easy_localization.dart";
import "package:flutter/material.dart";
import "package:wcas_frontend/core/components/label.dart";
import "package:wcas_frontend/core/components/radiobutton.dart";
import "package:wcas_frontend/core/constants/constants.dart";
import "package:wcas_frontend/core/utils/validators.dart";
import "package:wcas_frontend/features/request/covenants_conditions/covenant_edit_dialog/model.dart";

/// Covenant to be tested field for the covenant edit dialog.
class CovenanToBeTestedField extends StatelessWidget {
  /// Creates a covenant to be tested field.
  const CovenanToBeTestedField({required this.viewModel, super.key});

  /// Covenant edit dialog view model.
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
        itemBuilder: (context, option, {bool? isSelected, bool? isEnabled}) =>
            Text(
          option == CovenantTestType.rim
              ? option!.name.toUpperCase()
              : StringExtension(option!.name).capitalizeFirstLetter(),
        ),
        validator: (value) => CustomValidator.requiredField(value?.name ?? ""),
        isRequired: true,
        scrollDirection: Axis.horizontal,
      ),
    );
  }
}

/// String extension utilities.
extension StringExtension on String {
  /// Capitalizes the first letter of the string.
  String capitalizeFirstLetter() {
    if (isEmpty) {
      return this;
    }
    return this[0].toUpperCase() + substring(1);
  }
}
