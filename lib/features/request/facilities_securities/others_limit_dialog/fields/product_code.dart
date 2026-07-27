import "package:flutter/material.dart";
import "package:flutter/services.dart";
import "package:wcas_frontend/core/components/label.dart";
import "package:wcas_frontend/core/components/textfield.dart";
import "package:wcas_frontend/features/request/facilities_securities/others_limit_dialog/model.dart";

/// Widget for displaying and capturing the limit code.
class ProductCode extends StatelessWidget {
  /// Creates a product code widget.
  const ProductCode({
    required this.viewModel,
    super.key,
  });

  /// View model containing others limit dialog data and actions.
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
        validator: viewModel.validateProductCode,
        onSaved: (String? value) {
          viewModel.reference.reference3 = value?.toUpperCase();
        },
      ),
    );
  }
}

/// Input formatters used to validate and format limit code values.
///
/// Allows only alphanumeric characters and automatically converts
/// entered text to uppercase.
final List<TextInputFormatter> limitCodeFormatters = <TextInputFormatter>[
  /// Allow alphabets (both cases) + numbers
  FilteringTextInputFormatter.allow(RegExp("[A-Za-z0-9]")),

  /// Auto-convert to uppercase as user types (so Shift/Caps not required)
  TextInputFormatter.withFunction((oldValue, newValue) {
    final String upper = newValue.text.toUpperCase();
    return newValue.copyWith(
      text: upper,
      selection: TextSelection.collapsed(offset: upper.length),
      composing: TextRange.empty,
    );
  }),
];
