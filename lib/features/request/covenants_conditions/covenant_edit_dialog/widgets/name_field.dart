import "package:easy_localization/easy_localization.dart";
import "package:flutter/material.dart";
import "package:wcas_frontend/core/components/label.dart";
import "package:wcas_frontend/core/components/textfield.dart";
import "package:wcas_frontend/features/request/covenants_conditions/covenant_edit_dialog/model.dart";

class NameField extends StatelessWidget {
  const NameField({required this.viewModel, super.key});
  final CovenantEditDialogViewModel viewModel;
  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: LabelWidget(
        label: "covenantsConditions.covenantEditDialog.name".tr(),
        isRequired: viewModel.isRequiredBusinessSegment,
        child: CustomTextField(
          controller: viewModel.nameController,
          readOnly: viewModel.isReadOnly,
          maxLength: 100,
          semanticLabel: "covenantsConditions.covenantEditDialog.name".tr(),
          validator: (value) {
            if (value == null || value.trim().isEmpty) {
              return "common.validation.emptyField".tr();
            }
            return null;
          },
        ),
      ),
    );
  }
}
