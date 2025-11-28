import 'package:flutter/material.dart';
import 'package:wcas_frontend/core/components/checkbox.dart';
import 'package:wcas_frontend/core/components/dynamic_form/models/field.dart';

class DynamicFormSingleCheckBox extends StatefulWidget {
  final DynamicField fieldData;
  final Function(bool) onChanged;
  final Function(bool?) onSaved;
  final bool? value;
  final String? Function(bool?)? validation;
  const DynamicFormSingleCheckBox(
      {super.key,
      required this.fieldData,
      required this.onChanged,
      required this.onSaved,
      this.validation,
      this.value});

  @override
  State<DynamicFormSingleCheckBox> createState() =>
      _DynamicFormSingleCheckBoxState();
}

class _DynamicFormSingleCheckBoxState extends State<DynamicFormSingleCheckBox> {
  bool checkValue = false;
  @override
  Widget build(BuildContext context) {
    return CustomCheckbox(
      validation: widget.validation,
      value: widget.value ?? checkValue,
      onSaved: widget.onSaved,
      onChange: (value) {
        checkValue = value ?? false;
        widget.onChanged(value ?? false);
        setState(() {});
      },
      child: Text(
        widget.fieldData.label,
      ),
    );
  }
}
