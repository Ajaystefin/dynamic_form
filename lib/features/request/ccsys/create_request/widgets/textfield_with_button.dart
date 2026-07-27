import "package:flutter/foundation.dart";
import "package:flutter/material.dart";
import "package:flutter/services.dart";
import "package:wcas_frontend/core/components/button.dart";
import "package:wcas_frontend/core/components/gap.dart";
import "package:wcas_frontend/core/components/label.dart";
import "package:wcas_frontend/core/components/textfield.dart";
import "package:wcas_frontend/features/request/ccsys/create_request/model.dart";

/// Widget for text field with button
class TextfieldWithButton extends StatelessWidget {
  /// Creates a text field with an attached action button.
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
  });

  /// value
  final String? value;

  /// CcsysCreateRequest ViewModel
  final CcsysCreateRequestViewModel viewModel;

  /// Label
  final String label;

  /// onChange function
  final Function(String)? onChanged;

  /// onSubmit function
  final Function(String)? onSubmit;

  /// Validator function
  final String? Function(String?)? validator;

  /// Label for button
  final String buttonLabel;

  /// Read only
  final bool readOnly;

  /// List of TextInputFormatter
  final List<TextInputFormatter>? inputFormatters;

  /// is loading condition
  final bool isLoading;

  /// is required or not
  final bool isRequired;

  /// is from dialogue
  final bool isFromDialogue;

  /// semantic label
  final String? semanticLabel;

  /// on press call-back function
  final VoidCallback? buttonOnPressed;

  /// Focus Node
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
              onChanged: onChanged,
              onSubmitted: onSubmit,
            ),
          ),
          const Gap(
            direction: Axis.horizontal,
          ),
          CustomButton(
            isLoading: isLoading,
            onPressed: buttonOnPressed,
            label: buttonLabel,
          ),
          const SizedBox(
            width: 40,
          ),
        ],
      ),
    );
  }

  /// Adds diagnostic properties for debugging this widget.
  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties
      ..add(StringProperty("value", value))
      ..add(StringProperty("label", label))
      ..add(StringProperty("buttonLabel", buttonLabel))
      ..add(StringProperty("semanticLabel", semanticLabel))
      ..add(FlagProperty("readOnly", value: readOnly))
      ..add(FlagProperty("isLoading", value: isLoading))
      ..add(FlagProperty("isRequired", value: isRequired))
      ..add(FlagProperty("isFromDialogue", value: isFromDialogue))
      ..add(
        IterableProperty<TextInputFormatter>(
          "inputFormatters",
          inputFormatters,
        ),
      )
      ..add(DiagnosticsProperty<FocusNode>("focusNode", focusNode))
      ..add(
        ObjectFlagProperty<VoidCallback?>.has(
          "buttonOnPressed",
          buttonOnPressed,
        ),
      );
  }
}
