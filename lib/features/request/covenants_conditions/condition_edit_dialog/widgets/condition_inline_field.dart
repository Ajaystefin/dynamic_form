import "package:easy_localization/easy_localization.dart";
import "package:flutter/material.dart";
import "package:wcas_frontend/core/components/dynamic_form_inline.dart";
import "package:wcas_frontend/core/components/textarea.dart";
import "package:wcas_frontend/core/utils/logger.dart";
import "package:wcas_frontend/features/request/covenants_conditions/condition_edit_dialog/model.dart";

/// Condition inline field for the condition edit dialog.
class ConditionInlineField extends StatelessWidget {
  /// Creates a condition inline field.
  const ConditionInlineField({required this.viewModel, super.key});

  /// Condition edit dialog view model.
  final ConditionEditDialogViewModel viewModel;

  @override
  Widget build(BuildContext context) {
    logger.i(viewModel.selectedSubTypeValue?.name.toString());
    return viewModel.isInlineEditable()
        ? IgnorePointer(
            ignoring: !viewModel.canEdit,
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
              validator: (value) {
                // Only validate when custom text is editable
                if (!viewModel.isStandartList() &&
                    (value == null || value.trim().isEmpty)) {
                  return "covenantsConditions."
                          "conditionsEditDialog.enterDescription"
                      .tr();
                }
                return null;
              },
            ),
          )
        : IgnorePointer(
            ignoring: !viewModel.canEdit,
            child: DynamicFormInline(
              splitSymbol: "[]",
              key: ValueKey(viewModel.selectedSubTypeValue),
              callBackString: (value) {
                viewModel.editedInlineValue.name = value;
              },
              inputString: viewModel.selectedInlineValue.name.toString(),
              editedPreview: viewModel.editedInlineValue.name?.toString(),
            ),
          );
  }
}
