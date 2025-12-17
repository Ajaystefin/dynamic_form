import 'package:flutter/material.dart';
import 'package:wcas_frontend/core/components/dynamic_form_inline.dart';
import 'package:wcas_frontend/core/components/textarea.dart';
import 'package:wcas_frontend/core/utils/logger.dart';
import 'package:wcas_frontend/features/request/covenants_conditions/condition_edit_dialog/model.dart';

class ConditionInlineField extends StatelessWidget {
  const ConditionInlineField({super.key, required this.viewModel});
  final ConditionEditDialogViewModel viewModel;

  @override
  Widget build(BuildContext context) {
    logger.i(viewModel.selectedSubTypeValue?.name.toString());
    return viewModel.isInlineEditable()
        ? IgnorePointer(
            ignoring: viewModel.isViewOnlyMode,
            child: CustomTextArea(
              maxLength: 2000,
              key: ValueKey(viewModel.editedInlineValue.name),
              initialValue: viewModel.editedInlineValue.name.toString(),
              onChanged: (value) {
                viewModel.editedInlineValue.name = value;
              },
              onSaved: (value) {
                viewModel.editedInlineValue.name = value;
              },
            ),
          )
        : IgnorePointer(
            ignoring: viewModel.isViewOnlyMode,
            child: DynamicFormInline(
              splitSymbol: "[]",
              key: ValueKey(viewModel.selectedSubTypeValue),
              callBackString: (value) {
                viewModel.editedInlineValue.name = value;
              },
              inputString: (viewModel.selectedInlineValue.name.toString()),
            ),
          );
  }
}
