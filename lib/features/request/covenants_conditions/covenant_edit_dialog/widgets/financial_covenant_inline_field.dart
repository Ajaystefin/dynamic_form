import "package:flutter/material.dart";
import "package:wcas_frontend/core/components/textarea.dart";
import "package:wcas_frontend/features/request/covenants_conditions/covenant_edit_dialog/model.dart";

//this field will be always disabled not user input only selected values in
//dropdown will reflect here
class FinancialCovenantInlineField extends StatelessWidget {
  const FinancialCovenantInlineField({
    required this.viewModel,
    required this.hintText,
    required this.width,
    super.key,
    this.readOnly = false,
    this.filled = false,
  });
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
            readOnly: true,
            initialValue: "",
            filled: false,
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
