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
    // Only set default value if field is not required
    // If required, leave it null so validation can catch it
    if (widget.fieldData.isRequired && widget.options.isNotEmpty) {
      selectedValue = widget.options.first;
      widget.onChange(selectedValue);
    }
  }

  @override
  Widget build(BuildContext context) {
    return LabelWidget(
        showLabel: widget.showLabel,
        label: widget.fieldData.label,
        isRequired: widget.fieldData.isRequired,
        exponent: widget.fieldData.isCMOUpdate ? "#" : null,
        child: CustomRadioButton<String?>(
          isRequired: widget.fieldData.isRequired,
          validator: widget.fieldData.isRequired
              ? (value) {
                  if (value == null) {
                    return widget.fieldData.message ??
                        '${widget.fieldData.label} is required';
                  }
                  return null;
                }
              : null,
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
