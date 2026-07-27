import "package:flutter/foundation.dart";
import "package:flutter/material.dart";
import "package:flutter/services.dart";
import "package:wcas_frontend/core/components/button.dart";
import "package:wcas_frontend/core/components/label.dart";
import "package:wcas_frontend/core/components/textfield.dart";
import "package:wcas_frontend/features/request/projects/search_project/model.dart";

/// Text field widget with an attached action button.
class TextfieldWithButton extends StatelessWidget {
  /// Creates a text field with an optional action button.
  const TextfieldWithButton({
    required this.viewModel,
    required this.label,
    required this.buttonLabel,
    required this.buttonOnPressed,
    super.key,
    this.value,
    this.onSubmit,
    this.onChanged,
    this.filled = false,
    this.readOnly = false,
    this.isLoading = false,
    this.inputFormatters,
    this.validator,
    this.onSaved,
    this.isRequired = false,
    this.showLabel = true,
    this.showbuttonLabel = true,
    this.hintText,
    this.controller,
    this.maxLength,
  });

  /// Initial value of the text field
  final String? value;

  /// View model used for project search
  final SearchProjectViewModel viewModel;

  /// Label displayed above text field
  final String label;

  /// Called when text changes
  final ValueChanged<String>? onChanged;

  /// Called when user submits input
  final ValueChanged<String>? onSubmit;

  /// Validation logic for input
  final String? Function(String?)? validator;

  /// Button label
  final String buttonLabel;

  /// Makes field read-only
  final bool readOnly;

  /// Enables filled style
  final bool filled;

  /// Input formatters
  final List<TextInputFormatter>? inputFormatters;

  /// Loading state for button
  final bool isLoading;

  /// Save callback
  final ValueChanged<String?>? onSaved;

  /// Shows required indicator (* or +)
  final bool isRequired;

  /// Show/hide label
  final bool showLabel;

  /// Show/hide button
  final bool showbuttonLabel;

  /// Hint text
  final String? hintText;

  /// Controller for text field
  final TextEditingController? controller;

  /// Max character length
  final int? maxLength;

  /// Button action
  final VoidCallback buttonOnPressed;

  @override
  Widget build(BuildContext context) {
    return LabelWidget(
      label: label,
      isRequired: isRequired,
      showLabel: showLabel,
      child: Row(
        children: [
          Expanded(
            child: CustomTextField(
              inputFormatters: inputFormatters,
              readOnly: readOnly,
              validator: validator,
              hintText: hintText,
              initialValue: value,
              onChanged: onChanged,
              onSubmitted: onSubmit,
              controller: controller,
              maxLength: maxLength,
              onSaved: onSaved,
              filled: filled,
            ),
          ),
          if (showbuttonLabel)
            CustomButton(
              isLoading: isLoading,
              onPressed: buttonOnPressed,
              label: buttonLabel,
            ),
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
      ..add(FlagProperty("filled", value: filled))
      ..add(FlagProperty("isLoading", value: isLoading))
      ..add(FlagProperty("isRequired", value: isRequired))
      ..add(FlagProperty("showLabel", value: showLabel))
      ..add(FlagProperty("showbuttonLabel", value: showbuttonLabel))
      ..add(IntProperty("maxLength", maxLength));
  }
}
