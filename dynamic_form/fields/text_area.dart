import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:wcas_frontend/core/components/label.dart';
import 'package:wcas_frontend/core/components/textarea.dart';
import 'package:wcas_frontend/core/utils/scale.dart';

import '../models/field.dart';

class DynamicFormTextAreaField extends StatefulWidget {
  final DynamicField fieldData;
  final Map<String, dynamic>? document;
  final Function(String?) onSubmit;
  final List<TextInputFormatter>? inputFormatters;
  final bool showLabel;
  final int maxLines;
  final int minLines;
  final TextEditingController? controller;

  const DynamicFormTextAreaField({
    super.key,
    required this.fieldData,
    this.document,
    required this.onSubmit,
    this.inputFormatters,
    this.showLabel = true,
    this.maxLines = 5,
    this.minLines = 2,
    this.controller,
  });

  @override
  State<DynamicFormTextAreaField> createState() =>
      _DynamicFormTextAreaFieldState();
}

class _DynamicFormTextAreaFieldState extends State<DynamicFormTextAreaField> {
  late TextEditingController _controller;
  bool _isInternalController = false;

  @override
  void initState() {
    super.initState();
    // Use external controller if provided, otherwise create internal one
    if (widget.controller != null) {
      _controller = widget.controller!;
      _isInternalController = false;
    } else {
      _controller = TextEditingController();
      _isInternalController = true;
      _initializeFromDocument();
    }
  }

  void _initializeFromDocument() {
    if (widget.document == null) return;

    final initialValue = widget.document![widget.fieldData.key];
    if (initialValue != null) {
      _controller.text = initialValue.toString();
    }
  }

  @override
  void didUpdateWidget(DynamicFormTextAreaField oldWidget) {
    super.didUpdateWidget(oldWidget);

    // If using external controller and document value changed, sync it
    if (!_isInternalController && widget.document != null) {
      final docValue = widget.document![widget.fieldData.key];
      final newText = docValue?.toString() ?? '';

      // Only update if different to avoid cursor jumping
      if (_controller.text != newText) {
        _controller.text = newText;
      }
    }
  }

  @override
  void dispose() {
    // Only dispose if we created the controller
    if (_isInternalController) {
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
      child: CustomTextArea(
        initialValue: _controller.text,
        width: 280.w,
        maxLines: widget.maxLines,
        minLines: widget.minLines,
        hintText: widget.fieldData.defaultValue,
        maxLength: widget.fieldData.maxLength,
        // errorText: widget.fieldData.message,
        readOnly: widget.fieldData.isDisable,
        filled: widget.fieldData.isDisable,
        validator: widget.fieldData.isRequired
            ? (value) {
                if (value == null || value.isEmpty) {
                  return widget.fieldData.message ??
                      '${widget.fieldData.label} is required';
                }
                return null;
              }
            : null,
        onSaved: (value) => widget.onSubmit(value),
      ),
    );
  }
}
