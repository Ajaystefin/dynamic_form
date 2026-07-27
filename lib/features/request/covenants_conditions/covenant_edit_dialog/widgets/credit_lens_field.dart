import "package:easy_localization/easy_localization.dart";
import "package:flutter/material.dart";
import "package:flutter/services.dart";
import "package:wcas_frontend/core/components/label.dart";
import "package:wcas_frontend/core/components/textfield.dart";
import "package:wcas_frontend/features/request/covenants_conditions/covenant_edit_dialog/model.dart";

/// Credit Lens ID field for the covenant edit dialog.
class CreditLensField extends StatelessWidget {
  /// Creates a Credit Lens ID field.
  const CreditLensField({
    required this.initialValue,
    required this.viewModel,
    required this.isRequired,
    super.key,
    this.isEnabled,
  });

  /// Initial Credit Lens ID value.
  final String? initialValue;

  /// Whether the field is required.
  final bool isRequired;

  /// Covenant edit dialog view model.
  final CovenantEditDialogViewModel viewModel;

  /// Whether the field is enabled.
  final bool? isEnabled;

  @override
  Widget build(BuildContext context) {
    return LabelWidget(
      label: "covenantsConditions.covenantEditDialog.creditLensId".tr(),
      isRequired: viewModel.isRequiredBusinessSegment,
      child: CustomTextField(
        controller: viewModel.creditLensController,
        readOnly: !isEnabled!,
        filled: !isEnabled!,
        semanticLabel:
            "covenantsConditions.covenantEditDialog.creditLensId".tr(),
        initialValue: viewModel.covenant?.creditLensId,
        onSaved: (value) => viewModel.covenant?.creditLensId = value,
        onChanged: (value) => viewModel.covenant?.creditLensId = value,
        maxLength: 17,
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
