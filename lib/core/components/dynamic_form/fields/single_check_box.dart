import "package:flutter/material.dart";
import "package:wcas_frontend/core/components/checkbox.dart";
import "package:wcas_frontend/core/components/dynamic_form/models/field.dart";
import "package:wcas_frontend/core/utils/logger.dart";

/// A dynamic single checkbox field for dynamic forms.
///
/// Supports both standard form fields and grid-based checkbox fields.
class DynamicFormSingleCheckBox extends StatefulWidget {
  /// Creates a [DynamicFormSingleCheckBox].
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

  /// Field configuration data.
  final DynamicField fieldData;

  /// Form document data.
  final Map<String, dynamic>? document;

  /// Key used to retrieve the value from the document.
  ///
  /// Optional key for grid usage.
  final String? documentKey;

  /// Callback invoked when the value changes.
  final Function({bool? value}) onChanged;

  /// Callback invoked when the field value is saved.
  final Function({bool? value}) onSaved;

  /// Current checkbox value.
  final bool? value;

  /// Validation callback.
  final String? Function({bool? value})? validation;

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
      logger.i("Checkbox initState: using widget.value = ${widget.value}");
    } else if (widget.document != null) {
      final initialValue = widget.document![widget.fieldData.key];
      checkValue = initialValue is bool && initialValue;
      logger.i("Checkbox initState: using document value = $checkValue");
    } else {
      checkValue = false;
      logger.i("Checkbox initState: defaulting to false");
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
      finalValue = docValue is bool && docValue;
    } else {
      finalValue = widget.value ?? checkValue;
    }

    logger.i(
      "Checkbox build: widget.value=${widget.value}, "
      "checkValue=$checkValue, finalValue=$finalValue",
    );

    return CustomCheckbox(
      validation: widget.validation,
      value: finalValue,
      onSaved: ({value}) => widget.onSaved(value: value),
      onChange: ({value}) {
        checkValue = value ?? false;
        widget.onChanged(value: value ?? false);
        setState(() {});
      },
      child: Text(
        widget.fieldData.label,
      ),
    );
  }
}
