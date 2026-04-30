import "package:easy_localization/easy_localization.dart";
import "package:flutter/material.dart";
import "package:flutter/services.dart";
import "package:wcas_frontend/core/components/label.dart";
import "package:wcas_frontend/core/components/textfield.dart";
import "package:wcas_frontend/features/request/covenants_conditions/covenant_edit_dialog/model.dart";

class EntityNameField extends StatelessWidget {
  const EntityNameField({
    required this.initialValue,
    required this.viewModel,
    required this.isRequired,
    super.key,
    this.isEnabled = true,
  });
  final String? initialValue;
  final bool isRequired;
  final CovenantEditDialogViewModel viewModel;
  final bool isEnabled;

  @override
  Widget build(BuildContext context) {
    return LabelWidget(
      label: "covenantsConditions.covenantEditDialog.entityName".tr(),
      showLabel: true,
      isRequired: viewModel.isRequiredBusinessSegment,
      child: CustomTextField(
        controller: viewModel.entityNameController,
        readOnly: !isEnabled,
        filled: !isEnabled,
        semanticLabel: "covenantsConditions.covenantEditDialog.entityName".tr(),
        counterText: "",
        initialValue: viewModel.covenant?.entityName,
        onChanged: viewModel.onEntityNameChanged,
        maxLength: 100,
        inputFormatters: [
          FilteringTextInputFormatter.allow(RegExp("[a-zA-Z0-9 ]")),
        ],
        validator: (value) {
          if (value == null || value.trim().isEmpty) {
            return "common.validation.emptyField".tr();
          }
          return null;
        },
      ),
    );
  }
}
