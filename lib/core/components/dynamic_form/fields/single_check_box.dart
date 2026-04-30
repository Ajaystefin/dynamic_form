import "package:flutter/material.dart";
import "package:wcas_frontend/core/components/checkbox.dart";
import "package:wcas_frontend/core/components/dynamic_form/models/field.dart";

class DynamicFormSingleCheckBox extends StatefulWidget {
  const DynamicFormSingleCheckBox({
    required this.fieldData,
    required this.onChanged,
    required this.onSaved,
    super.key,
    this.document,
    this.documentKey, // Optional key for grid usage
    this.validation,
    this.value,
  });
  final DynamicField fieldData;
  final Map<String, dynamic>? document;
  final String? documentKey; // Key to read current value from document
  final Function(bool) onChanged;
  final Function(bool?) onSaved;
  final bool? value;
  final String? Function(bool?)? validation;

  @override
  State<DynamicFormSingleCheckBox> createState() =>
      _DynamicFormSingleCheckBoxState();
}

class _DynamicFormSingleCheckBoxState extends State<DynamicFormSingleCheckBox> {
  late bool checkValue;

  @override
  void initState() {
    super.initState();
    // Initialize from widget.value if provided, otherwise from document
    if (widget.value != null) {
      checkValue = widget.value!;
      debugPrint("Checkbox initState: using widget.value = ${widget.value}");
    } else if (widget.document != null) {
      final initialValue = widget.document![widget.fieldData.key];
      checkValue = initialValue is bool ? initialValue : false;
      debugPrint("Checkbox initState: using document value = $checkValue");
    } else {
      checkValue = false;
      debugPrint("Checkbox initState: defaulting to false");
    }
  }

  @override
  void didUpdateWidget(DynamicFormSingleCheckBox oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Update internal state when value prop changes (for grid usage)
    if (widget.value != null && widget.value != oldWidget.value) {
      checkValue = widget.value!;
    }
  }

  @override
  Widget build(BuildContext context) {
    // Read from document if documentKey provided (for grid usage)
    // Otherwise use widget.value or checkValue
    final bool finalValue;
    if (widget.documentKey != null && widget.document != null) {
      final docValue = widget.document![widget.documentKey!];
      finalValue = (docValue is bool) ? docValue : false;
    } else {
      finalValue = widget.value ?? checkValue;
    }

    debugPrint(
      "Checkbox build: widget.value=${widget.value}, "
      "checkValue=$checkValue, finalValue=$finalValue",
    );

    return CustomCheckbox(
      validation: widget.validation,
      value: finalValue,
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
