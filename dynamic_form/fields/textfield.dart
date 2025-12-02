import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:wcas_frontend/core/components/label.dart';
import 'package:wcas_frontend/core/components/textfield.dart';
import 'package:wcas_frontend/core/utils/validators.dart';

import '../models/field.dart';

class DynamicFormTextField extends StatefulWidget {
  final DynamicField fieldData;
  final Function(String?) onSubmit;
  final Function(String?)? onChanged;
  final List<TextInputFormatter>? inputFormatters;
  final bool showLabel;
  final TextEditingController? controller;

  const DynamicFormTextField({
    super.key,
    required this.fieldData,
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
      child: CustomTextField(
        controller: _controller,
        validator: CustomValidator.requiredField,
        inputFormatters: widget.inputFormatters,
        hintText: widget.fieldData.defaultValue,
        // maxLength: widget.fieldData.maxLength,
        errorText: widget.fieldData.message,
        readOnly: widget.fieldData.isDisable,
        onSaved: widget.onSubmit,
        onChanged: widget.onChanged,
      ),
    );
  }
}
