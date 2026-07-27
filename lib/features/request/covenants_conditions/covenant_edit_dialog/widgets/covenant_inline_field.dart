import "package:flutter/material.dart";
import "package:wcas_frontend/core/components/dynamic_form_inline.dart";
import "package:wcas_frontend/core/components/textfield.dart";
import "package:wcas_frontend/features/request/covenants_conditions/covenant_edit_dialog/model.dart";

/// Covenant inline field for the covenant edit dialog.
class CovenantInlineField extends StatelessWidget {
  /// Creates a covenant inline field.
  const CovenantInlineField({required this.viewModel, super.key});

  /// Covenant edit dialog view model.
  final CovenantEditDialogViewModel viewModel;

  @override
  Widget build(BuildContext context) {
    return viewModel.isUpdateCovenant()
        ? CustomTextField(
            readOnly: viewModel.isReadOnly,
            initialValue: viewModel.selectedSubTypeValue?.reference1.toString(),
            onChanged: (value) {
              viewModel.selectedSubTypeValue?.reference1 = value;
            },
          )
        : DynamicFormInline(
            key: UniqueKey(),
            inputString:
                viewModel.selectedSubTypeValue?.reference1.toString() ?? " ",
          );
  }
}
