import "package:easy_localization/easy_localization.dart";
import "package:flutter/material.dart";
import "package:wcas_frontend/core/components/label.dart";
import "package:wcas_frontend/core/components/radiobutton.dart";
import "package:wcas_frontend/core/utils/validators.dart";
import "package:wcas_frontend/features/request/covenants_conditions/covenant_edit_dialog/model.dart";

/// Covenant description field for the covenant edit dialog.
class CovenantDescriptionField extends StatelessWidget {
  /// Creates a covenant description field.
  const CovenantDescriptionField({required this.viewModel, super.key});

  /// Covenant edit dialog view model.
  final CovenantEditDialogViewModel viewModel;

  @override
  Widget build(BuildContext context) {
    viewModel.initializeSelectedDescriptionType();

    return LabelWidget(
      isRequired: viewModel.isRequiredBusinessSegment,
      label: "covenantsConditions.covenantEditDialog.covenantDescription".tr(),
      child: CustomRadioButton(
        isEnabled: !viewModel.isReadOnly,
        options: viewModel.descriptionTypes.map((ref) => ref.name).toList(),
        selectedValue: viewModel.selectedDescriptionType,
        onChanged: (value) {
          viewModel.onDescriptionTypeChange(value);
        },
        validator: (value) => CustomValidator.requiredField(value ?? ""),
        isRequired: true,
        scrollDirection: Axis.horizontal,
        textStyle: const TextStyle(fontSize: 12),
      ),
    );
  }
}
