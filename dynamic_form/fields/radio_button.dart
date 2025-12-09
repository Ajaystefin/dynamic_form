import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:wcas_frontend/core/components/label.dart';
import 'package:wcas_frontend/core/components/radiobutton.dart';

import '../models/field.dart';

class DynamicRadioButton extends StatefulWidget {
  final DynamicField fieldData;
  final Function(String?) onChange;
  final List<TextInputFormatter>? inputFormatters;
  final bool showLabel;
  final List<String> options;
  const DynamicRadioButton(
      {super.key,
      required this.fieldData,
      required this.onChange,
      this.inputFormatters,
      this.showLabel = true,
      required this.options});

  @override
  State<DynamicRadioButton> createState() => _DynamicRadioButtonState();
}

class _DynamicRadioButtonState extends State<DynamicRadioButton> {
  String? selectedValue;

  @override
  void initState() {
    super.initState();
    // Set the first option as selected by default
    selectedValue = widget.options.isNotEmpty ? widget.options.first : "";
    // Also notify parent about the initial selection
    widget.onChange(selectedValue);
  }

  @override
  Widget build(BuildContext context) {
    return LabelWidget(
        showLabel: widget.showLabel,
        label: widget.fieldData.label,
        isRequired: widget.fieldData.required,
        exponent: widget.fieldData.isCMOUpdate ? "#" : null,
        child: CustomRadioButton(
          onChanged: (value) {
            widget.onChange(value);
            selectedValue = value;
            setState(() {});
          },
          options: widget.options,
          selectedValue: selectedValue,
        ));
  }
}
