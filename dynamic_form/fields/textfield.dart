import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:wcas_frontend/core/components/label.dart';
import 'package:wcas_frontend/core/components/textfield.dart';
import 'package:wcas_frontend/core/utils/scale.dart';
import 'package:wcas_frontend/core/utils/logger.dart';

import '../models/field.dart';

class DynamicFormTextField extends StatefulWidget {
  final DynamicField fieldData;
  final Map<String, dynamic>? document;
  final Function(String?) onSubmit;
  final Function(String?)? onChanged;
  final List<TextInputFormatter>? inputFormatters;
  final bool showLabel;
  final TextEditingController? controller;

  const DynamicFormTextField({
    super.key,
    required this.fieldData,
    this.document,
    required this.onSubmit,
    this.onChanged,
    this.inputFormatters,
    this.showLabel = true,
    this.controller,
  });

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
    if (widget.document == null) return;

    final initialValue = widget.document![widget.fieldData.key];
    if (initialValue != null && _controller.text.isEmpty) {
      _controller.text = initialValue.toString();
    }
  }

  @override
  void didUpdateWidget(DynamicFormTextField oldWidget) {
    super.didUpdateWidget(oldWidget);

    // Update controller if document value changed externally (e.g., via updateFieldValue)
    if (widget.document != null) {
      final newValue = widget.document![widget.fieldData.key];
      final newValueStr = newValue?.toString() ?? '';

      // Only update if the value actually changed to avoid cursor jumping
      if (_controller.text != newValueStr) {
        _controller.text = newValueStr;
      }
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
      isRequired: widget.fieldData.required,
      exponent: widget.fieldData.isCMOUpdate ? "#" : null,
      child: CustomTextField(
        width: 230.w,
        controller: _controller,

        validator: widget.fieldData.required
            ? (value) {
                // Use controller's text as the source of truth
                final actualValue = _controller.text;

                // ignore: avoid_print
                print('=== Validation Debug for ${widget.fieldData.key} ===');
                logger.f('Controller text: "$actualValue"');
                logger.f('FormField value: "$value"');
                logger.f('Required: ${widget.fieldData.required}');

                // First check if field is required and empty
                if (actualValue.isEmpty) {
                  logger.f('Validation FAILED: Field is empty');
                  return widget.fieldData.message;
                }

                // Then check validation pattern if provided
                if (widget.fieldData.validationPattern != null) {
                  logger.f(
                      'Validation pattern: ${widget.fieldData.validationPattern}');
                  final pattern = RegExp(widget.fieldData.validationPattern!);
                  final matches = pattern.hasMatch(actualValue);
                  logger.f('Pattern matches: $matches');

                  if (!matches) {
                    logger.f('Validation FAILED: Pattern mismatch');
                    return widget.fieldData.message;
                  }
                }

                logger.f('Validation PASSED');
                return null;
              }
            : null,
        inputFormatters: widget.inputFormatters,
        hintText: widget.fieldData.defaultValue,
        maxLength: widget.fieldData.maxLength,
        // errorText: widget.fieldData.required ? widget.fieldData.message : null,
        readOnly: widget.fieldData.isDisable,
        onSaved: (value) => widget.onSubmit(_controller.text),
        onChanged: widget.onChanged != null
            ? (value) => widget.onChanged!(_controller.text)
            : null,
      ),
    );
  }
}
