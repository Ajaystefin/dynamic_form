import 'package:flutter/material.dart';
import 'package:wcas_frontend/core/components/textfield.dart';
import 'package:wcas_frontend/core/utils/validators.dart';
import 'package:wcas_frontend/features/request/covenants_conditions/covenant_edit_dialog/model.dart';

class FinancialCovenantDescriptionField extends StatelessWidget {
  const FinancialCovenantDescriptionField({
    super.key,
    required this.viewModel,
    required this.width,
    this.readOnly = false,
    this.filled = false,
  });

  final CovenantEditDialogViewModel viewModel;
  final double width;
  final bool readOnly;
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
          // if (viewModel.selectedFinancialCovenantSubType == null) {
          //   return;
          // }
          viewModel.onFinancialDescriptionChanged(value);

          viewModel.covenant?.description =
              viewModel.financialDescriptionController.text;
        },
      ),
    );
  }
}
