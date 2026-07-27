import "package:easy_localization/easy_localization.dart";
import "package:flutter/material.dart";
import "package:wcas_frontend/core/components/label.dart";
import "package:wcas_frontend/core/components/textfield.dart";
import "package:wcas_frontend/core/utils/validators.dart";
import "package:wcas_frontend/features/admin/update_reference_dialog/model.dart";

/// Displays the description input field.
class Description extends StatelessWidget {
  /// Creates a [Description].
  const Description({required this.viewModel, super.key});

  /// View model containing the reference data.
  final UpdateReferenceDialogViewModel viewModel;

  @override
  Widget build(BuildContext context) {
    return LabelWidget(
      label: "admin.referenceDataManagement.referenceDataDescription".tr(),
      isRequired: true,
      child: CustomTextField(
        inputFormatters: viewModel.descriptionFormatters,
        controller: viewModel.descriptionController,
        onChanged: (value) {
          viewModel.reference.description = value;
          viewModel.onFieldChanged();
        },
        semanticLabel:
            "admin.referenceDataManagement.referenceDataDescription".tr(),
        validator: CustomValidator.requiredField,
        // onSaved: (String? value) {
        //   viewModel.reference.description = value;
        // },
      ),
    );
  }
}
