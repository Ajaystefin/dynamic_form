import "package:flutter/material.dart";
import "package:wcas_frontend/core/components/textfield.dart";
import "package:wcas_frontend/core/utils/validators.dart";
import "package:wcas_frontend/features/request/covenants_conditions/covenant_edit_dialog/model.dart";

/// Financial covenant description field for the covenant edit dialog.
class FinancialCovenantDescriptionField extends StatelessWidget {
  /// Creates a financial covenant description field.
  const FinancialCovenantDescriptionField({
    required this.viewModel,
    required this.width,
    super.key,
    this.readOnly = false,
    this.filled = false,
  });

  /// Covenant edit dialog view model.
  final CovenantEditDialogViewModel viewModel;

  /// Width of the description field.
  final double width;

  /// Whether the description field is read-only.
  final bool readOnly;

  /// Whether the description field is filled.
  final bool filled;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      child: CustomTextField(
        maxLines: 9,
        minLines: 3,
        readOnly: viewModel.isReadOnly && viewModel.isDescriptionReadOnly,
        width: width,
        validator: CustomValidator.requiredField,
        initialValue: viewModel.isLinkFinancialView
            ? ""
            : (!viewModel.isNewCovenant
                ? (viewModel.covenant?.description ?? "")
                : ""),
        controller: viewModel.financialDescriptionController,
        filled: filled,
        onChanged: (value) {
          viewModel.onFinancialDescriptionChanged(value);
          viewModel.covenant?.description =
              viewModel.financialDescriptionController.text;
        },
      ),
    );
  }
}
