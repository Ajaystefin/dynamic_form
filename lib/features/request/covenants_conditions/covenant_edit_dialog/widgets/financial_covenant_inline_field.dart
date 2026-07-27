import "package:flutter/material.dart";
import "package:wcas_frontend/core/components/textarea.dart";
import "package:wcas_frontend/features/request/covenants_conditions/covenant_edit_dialog/model.dart";

//this field will be always disabled not user input only selected values in
//dropdown will reflect here

/// Financial covenant inline field for the covenant edit dialog.
class FinancialCovenantInlineField extends StatelessWidget {
  /// Creates a financial covenant inline field.
  const FinancialCovenantInlineField({
    required this.viewModel,
    required this.hintText,
    required this.width,
    super.key,
    this.readOnly = false,
    this.filled = false,
  });

  /// Covenant edit dialog view model.
  final CovenantEditDialogViewModel viewModel;

  /// Hint text displayed in the inline field.
  final String hintText;

  /// Width of the inline field.
  final double width;

  /// Whether the inline field is read-only.
  final bool? readOnly;

  /// Whether the inline field is filled.
  final bool? filled;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: width,
          child: CustomTextArea(
            readOnly: true,
            initialValue: "",
            hintText: hintText,
            onChanged: (value) {
              viewModel.selectedSubTypeValue?.reference1 = value;
            },
          ),
        ),
      ],
    );
  }
}
