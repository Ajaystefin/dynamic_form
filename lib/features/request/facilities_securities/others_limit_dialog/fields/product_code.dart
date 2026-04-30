import "package:flutter/material.dart";
import "package:flutter/services.dart";
import "package:wcas_frontend/core/components/label.dart";
import "package:wcas_frontend/core/components/textfield.dart";
import "package:wcas_frontend/core/utils/validators.dart";
import "package:wcas_frontend/features/request/facilities_securities/others_limit_dialog/model.dart";

class ProductCode extends StatelessWidget {
  const ProductCode({required this.viewModel, super.key});
  final OthersLimitDialogViewModel viewModel;

  @override
  Widget build(BuildContext context) {
    return LabelWidget(
      isRequired: true,
      label: "Limit Code",
      child: CustomTextField(
        maxLength: 4,
        onChanged: (value) {
          viewModel.reference.reference3 = value.toUpperCase();
        },
        inputFormatters: limitCodeFormatters,
        validator: (value) => CustomValidator.requiredField(value ?? ""),
        onSaved: (String? value) {
          viewModel.reference.reference3 = value?.toUpperCase();
        },
      ),
    );
  }
}

final List<TextInputFormatter> limitCodeFormatters = <TextInputFormatter>[
  // Allow alphabets (both cases) + numbers
  FilteringTextInputFormatter.allow(RegExp("[A-Za-z0-9]")),

  // Auto-convert to uppercase as user types (so Shift/Caps not required)
  TextInputFormatter.withFunction((oldValue, newValue) {
    final String upper = newValue.text.toUpperCase();
    return newValue.copyWith(
      text: upper,
      selection: TextSelection.collapsed(offset: upper.length),
      composing: TextRange.empty,
    );
  }),
];
