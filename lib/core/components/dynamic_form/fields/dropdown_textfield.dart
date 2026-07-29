import "package:flutter/material.dart";
import "package:flutter/services.dart";
import "package:wcas_frontend/core/components/dropdown_textbox.dart";
import "package:wcas_frontend/core/components/dynamic_form/models/field.dart";
import "package:wcas_frontend/core/components/label.dart";
import "package:wcas_frontend/core/constants/_server_constants.dart";

/// Dynamic dropdown and text field form field.
class DynamicFormDropdownTextfield extends StatefulWidget {
  /// Creates a [DynamicFormDropdownTextfield].
  const DynamicFormDropdownTextfield({
    required this.fieldData,
    required this.document,
    required this.onSubmit,
    super.key,
    this.showLabel = false,
    this.inputFormatters,
    this.controller,
  });

  /// Field configuration data.
  final DynamicField fieldData;

  /// Form document data.
  final Map<String, dynamic> document;

  /// Callback invoked when the value changes.
  final Function(Map<String, dynamic>) onSubmit;

  /// Whether to display the field label.
  final bool showLabel;

  /// Input formatters for the text field.
  final List<TextInputFormatter>? inputFormatters;

  /// Controller for the text field.
  final TextEditingController? controller;

  @override
  State<DynamicFormDropdownTextfield> createState() =>
      _DynamicFormDropdownTextfieldState();
}

class _DynamicFormDropdownTextfieldState
    extends State<DynamicFormDropdownTextfield> {
  late TextEditingController _textController;
  String? _selectedUnit;
  String years = "(Years)";
  String months = "(Months)";
  String days = "(Days)";

  @override
  void initState() {
    super.initState();

    // Initialize text controller
    _textController = widget.controller ?? TextEditingController();

    // Extract initial values from document
    final dynamic storedValue = widget.document[widget.fieldData.key];
    bool hadStored = false;
    String? initialUnit;
    String? initialValue;

    if (storedValue is Map<String, dynamic>) {
      // Read from document: {"tenorUnit": "Days", "tenorValue": "30"}
      initialUnit = storedValue["tenorUnit"]?.toString();
      initialValue = storedValue["tenorValue"]?.toString();
      hadStored = true;
    }

    // Fallback to defaultValue if no stored value
    if (initialUnit == null || initialUnit.isEmpty) {
      if (widget.fieldData.defaultValue != null &&
          widget.fieldData.defaultValue.toString().isNotEmpty) {
        initialUnit = widget.fieldData.defaultValue;
      } else if (widget.fieldData.optionList != null &&
          widget.fieldData.optionList!.isNotEmpty) {
        initialUnit = widget.fieldData.optionList!.first.value;
      }
    }

    // Set initial values
    _selectedUnit = initialUnit;
    if (initialValue != null && initialValue.isNotEmpty) {
      _textController.text = initialValue;
    }

    _applyFormatterForUnit("(${_selectedUnit ?? ""})");

    // Auto-submit initial values if they exist
    if (hadStored) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _submitValue();
      });
    }
  }

  @override
  void dispose() {
    // Only dispose if we created the controller
    if (widget.controller == null) {
      _textController.dispose();
    }
    super.dispose();
  }

  List<TextInputFormatter>? _formatterForUnit(String unit) {
    if (unit == years) {
      return [FilteringTextInputFormatter.allow(RegExp(r"^[01]$"))];
    } else if (unit == months) {
      return [FilteringTextInputFormatter.allow(RegExp(r"^([0-9]|1[0-2])$"))];
    } else if (unit == days) {
      return [
        FilteringTextInputFormatter.allow(
          RegExp(r"^([0-9]|[1-9][0-9]|[1-2][0-9]{2}|3[0-5][0-9]|36[0-5])$"),
        ),
      ];
    }
    return null;
  }

  void _applyFormatterForUnit(String unit) {
    if (!widget.fieldData.enableLimiterValidation) {
      return;
    }
    final List<TextInputFormatter>? fmt = _formatterForUnit(unit);
    if (fmt == null) {
      return;
    }
    limiterFormatter = fmt;
    setState(() {});
  }

  void _submitValue() {
    widget.onSubmit({
      "tenorUnit": _selectedUnit ?? "",
      "tenorValue": _textController.text,
    });
  }

  List<TextInputFormatter>? limiterFormatter;
  @override
  Widget build(BuildContext context) {
    final Widget child = CustomDropdownTextbox(
      controller: _textController,
      options: widget.fieldData.optionList ?? [],
      initialOption: _selectedUnit,
      textReadOnly: _selectedUnit == ServerConstants.tenorOnDemandUnit,
      maxLength: widget.fieldData.maxLength,
      inputFormatters:
          (widget.fieldData.enableLimiterValidation && limiterFormatter != null)
              ? limiterFormatter
              : widget.inputFormatters,
      validator: (value) {
        if (widget.fieldData.isRequired) {
          if (value == null || value.isEmpty) {
            return widget.fieldData.message ?? "$years is required";
          }
        }
        return null;
      },
      onChanged: (value) {
        // value is a Map with {selectedOption: textValue}
        // Extract the selected unit (key) and text value
        limiterFormatter = null;
        //
        if (value.isNotEmpty) {
          final entry = value.entries.first;
          _selectedUnit = entry.key;

          if (widget.fieldData.enableLimiterValidation) {
            final List<TextInputFormatter>? fmt =
                _formatterForUnit("(${entry.key})");
            limiterFormatter = fmt;
            setState(() {});
          }

          // Submit in new format
          _submitValue();
        }
      },
    );

    return widget.showLabel
        ? LabelWidget(
            showLabel: widget.showLabel,
            label: widget.fieldData.label,
            isRequired: widget.fieldData.isRequired,
            exponent: widget.fieldData.isCMOUpdate ? "#" : null,
            child: child,
          )
        : child;
  }
}
