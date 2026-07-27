import "package:flutter/foundation.dart";
import "package:flutter/material.dart";
import "package:flutter/services.dart";
import "package:wcas_frontend/core/components/button.dart";
import "package:wcas_frontend/core/components/gap.dart";
import "package:wcas_frontend/core/components/label.dart";
import "package:wcas_frontend/core/components/textfield.dart";
import "package:wcas_frontend/features/request/information/create_request/model.dart";

/// Widget that combines a text field and an action button.
///
/// Commonly used for searchable or selectable fields where the
/// value can be entered manually or populated through a dialog.
class TextfieldWithButton extends StatelessWidget {
  /// Creates a [TextfieldWithButton].
  const TextfieldWithButton({
    required this.viewModel,
    required this.label,
    required this.buttonLabel,
    required this.buttonOnPressed,
    super.key,
    this.value,
    this.onSubmit,
    this.onChanged,
    this.readOnly = false,
    this.isLoading = false,
    this.isRequired = false,
    this.inputFormatters,
    this.validator,
    this.focusNode,
    this.semanticLabel,
    this.isFromDialogue = false,
    this.maxLength,
  });

  /// Initial value displayed in the text field.
  final String? value;

  /// View model used to manage field state and validation behavior.
  final CreateRequestViewModel viewModel;

  /// Label displayed for the field.
  final String label;

  /// Callback invoked when the field value changes.
  final Function(String)? onChanged;

  /// Callback invoked when the user submits the field value.
  final Function(String)? onSubmit;

  /// Validation logic applied to the field value.
  final String? Function(String?)? validator;

  /// Label displayed on the action button.
  final String buttonLabel;

  /// Indicates whether the text field and button are read-only.
  final bool readOnly;

  /// Input formatters applied to the text field.
  final List<TextInputFormatter>? inputFormatters;

  /// Indicates whether a loading state should be shown on the button.
  final bool isLoading;

  /// Indicates whether the field is mandatory.
  final bool isRequired;

  /// Indicates whether the widget is rendered within a dialog.
  final bool isFromDialogue;

  /// Semantic label used for accessibility and screen readers.
  final String? semanticLabel;

  /// Maximum number of characters allowed in the text field.
  final int? maxLength;

  /// Callback invoked when the action button is pressed.
  final VoidCallback? buttonOnPressed;

  /// Focus node used to manage keyboard focus for the text field.
  final FocusNode? focusNode;

  @override
  Widget build(BuildContext context) {
    return LabelWidget(
      label: label,
      labelStyle: const TextStyle(fontWeight: FontWeight.bold),
      isRequired: isRequired,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: CustomTextField(
              key: ValueKey(viewModel.isFieldsFilled()),
              semanticLabel: semanticLabel ?? label,
              filled: viewModel.isFieldsFilled() || readOnly,
              inputFormatters: inputFormatters,
              readOnly: readOnly,
              validator: viewModel.showError ? validator : null,
              initialValue: value,
              hintText: value,
              onChanged: onChanged,
              onSubmitted: onSubmit,
              maxLength: maxLength,
            ),
          ),
          const Gap(
            direction: Axis.horizontal,
          ),
          CustomButton(
            isLoading: isLoading,
            onPressed: readOnly ? null : buttonOnPressed,
            label: buttonLabel,
          ),
          const Gap(customValue: 40),
        ],
      ),
    );
  }

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties
      ..add(StringProperty("value", value))
      ..add(StringProperty("label", label))
      ..add(StringProperty("buttonLabel", buttonLabel))
      ..add(FlagProperty("readOnly", value: readOnly))
      ..add(FlagProperty("isLoading", value: isLoading))
      ..add(FlagProperty("isRequired", value: isRequired))
      ..add(FlagProperty("isFromDialogue", value: isFromDialogue))
      ..add(StringProperty("semanticLabel", semanticLabel))
      ..add(IntProperty("maxLength", maxLength));
  }
}
