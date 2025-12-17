import 'package:flutter/material.dart';
import 'package:wcas_frontend/core/components/textarea.dart';
import 'package:wcas_frontend/features/request/covenants_conditions/covenant_edit_dialog/model.dart';

class FinancialCovenantInlineField extends StatelessWidget {
  const FinancialCovenantInlineField(
      {super.key,
      required this.viewModel,
      required this.hintText,
      required this.width,
      this.readOnly = false,
      this.filled = false});
  final CovenantEditDialogViewModel viewModel;
  final String hintText;
  final double width;
  final bool? readOnly;
  final bool? filled;
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: width,
          child: CustomTextArea(
            readOnly: readOnly! &&  viewModel.isReadOnly,
            filled: filled!,
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
