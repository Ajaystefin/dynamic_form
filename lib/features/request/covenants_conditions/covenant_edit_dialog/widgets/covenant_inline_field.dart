import "package:flutter/material.dart";
import "package:wcas_frontend/core/components/dynamic_form_inline.dart";
import "package:wcas_frontend/core/components/textfield.dart";
import "package:wcas_frontend/features/request/covenants_conditions/covenant_edit_dialog/model.dart";

class CovenantInlineField extends StatelessWidget {
  const CovenantInlineField({required this.viewModel, super.key});
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
