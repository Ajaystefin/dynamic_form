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

  const DynamicFormTextAreaField({
    super.key,
    required this.fieldData,
    this.document,
    required this.onSubmit,
    this.inputFormatters,
    this.showLabel = true,
    this.maxLines = 5,
    this.minLines = 2,
  });

  @override
  State<DynamicFormTextAreaField> createState() =>
      _DynamicFormTextAreaFieldState();
}

class _DynamicFormTextAreaFieldState extends State<DynamicFormTextAreaField> {
  late TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController();
    _initializeFromDocument();
  }

  void _initializeFromDocument() {
    if (widget.document == null) return;

    final initialValue = widget.document![widget.fieldData.key];
    if (initialValue != null) {
      _controller.text = initialValue.toString();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return LabelWidget(
      showLabel: widget.showLabel,
      label: widget.fieldData.label,
      isRequired: widget.fieldData.required,
      exponent: widget.fieldData.isCMOUpdate ? "#" : null,
      child: CustomTextArea(
        width: 280.w,
        maxLines: widget.maxLines,
        minLines: widget.minLines,
        hintText: widget.fieldData.defaultValue,
        maxLength: widget.fieldData.maxLength,
        errorText: widget.fieldData.message,
        readOnly: widget.fieldData.isDisable,
        onSaved: (value) => widget.onSubmit(_controller.text),
      ),
    );
  }
}
