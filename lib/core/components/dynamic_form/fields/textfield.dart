import "package:flutter/material.dart";
import "package:flutter/services.dart";
import "package:wcas_frontend/core/components/dynamic_form/models/field.dart";
import "package:wcas_frontend/core/components/label.dart";
import "package:wcas_frontend/core/components/textfield.dart";
import "package:wcas_frontend/core/utils/logger.dart";
import "package:wcas_frontend/core/utils/scale.dart";
import "package:wcas_frontend/core/utils/validators.dart";

/// A dynamic text input field for dynamic forms.
///
/// Supports validation, formatting, and optional change notifications.
class DynamicFormTextField extends StatefulWidget {
  /// Creates a [DynamicFormTextField].
  const DynamicFormTextField({
    required this.fieldData,
    required this.onSubmit,
    super.key,
    this.document,
    this.onChanged,
    this.inputFormatters,
    this.showLabel = true,
    this.controller,
  });

  /// Field configuration data.
  final DynamicField fieldData;

  /// Form document data.
  final Map<String, dynamic>? document;

  /// Callback invoked when the value is submitted.
  final Function(String?) onSubmit;

  /// Callback invoked when the value changes.
  final Function(String?)? onChanged;

  /// Input formatters applied to the field.
  final List<TextInputFormatter>? inputFormatters;

  /// Whether to display the field label.
  final bool showLabel;

  /// Controller for the text field.
  final TextEditingController? controller;

  @override
  State<DynamicFormTextField> createState() => _DynamicFormTextFieldState();
}

class _DynamicFormTextFieldState extends State<DynamicFormTextField> {
  late TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = widget.controller ?? TextEditingController();

    // Initialize from document if available
    _initializeFromDocument();
  }

  void _initializeFromDocument() {
    if (widget.document == null) {
      return;
    }

    final initialValue = widget.document![widget.fieldData.key];
    if (initialValue != null && _controller.text.isEmpty) {
      _controller.text = initialValue.toString();
    }
  }

  @override
  void dispose() {
    // Only dispose if we created it internally
    if (widget.controller == null) {
      _controller.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return LabelWidget(
      showLabel: widget.showLabel,
      label: widget.fieldData.label,
      isRequired: widget.fieldData.isRequired,
      exponent: widget.fieldData.isCMOUpdate ? "#" : null,
      child: CustomTextField(
        width: 230.w,
        controller: _controller,

        validator: widget.fieldData.isRequired
            ? (value) {
                // Use controller's text as the source of truth
                final actualValue = _controller.text;

                // First check if field is required and empty
                if (actualValue.isEmpty) {
                  logger.i("Validation FAILED: Field is empty");
                  return widget.fieldData.message;
                }

                // Then check validation pattern if provided
                if (widget.fieldData.validationPattern != null) {
                  logger.i(
                    "Validation pattern: ${widget.fieldData.validationPattern}",
                  );
                  final pattern = RegExp(widget.fieldData.validationPattern!);
                  final matches = pattern.hasMatch(actualValue);
                  logger.i("Pattern matches: $matches");

                  if (!matches) {
                    logger.i("Validation FAILED: Pattern mismatch");
                    return widget.fieldData.message;
                  }
                }

                logger.i("Validation PASSED");
                return null;
              }
            : null,
        inputFormatters: [
          ...?widget.inputFormatters,
          if (widget.fieldData.inputFormatterPattern != null)
            RegexInputFormatter(widget.fieldData.inputFormatterPattern!),
        ],
        // hintText: widget.fieldData.defaultValue,
        maxLength: widget.fieldData.maxLength,
        // errorText: widget.fieldData.isRequired ? widget.fieldData.message :
        // null,
        readOnly: widget.fieldData.isDisable,
        filled: widget.fieldData.isDisable,
        onSaved: (value) => widget.onSubmit(_controller.text),
        onChanged: widget.onChanged != null
            ? (value) => widget.onChanged!(_controller.text)
            : null,
      ),
    );
  }
}
