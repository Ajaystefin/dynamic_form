import "package:flutter/material.dart";
import "package:flutter/services.dart";
import "package:wcas_frontend/core/components/dropdown_textbox.dart";
import "package:wcas_frontend/core/components/dynamic_form/models/field.dart";
import "package:wcas_frontend/core/components/label.dart";

class DynamicFormDropdownTextfield extends StatefulWidget {
  const DynamicFormDropdownTextfield({
    required this.fieldData,
    required this.document,
    required this.onSubmit,
    super.key,
    this.showLabel = false,
    this.inputFormatters,
    this.controller,
  });
  final DynamicField fieldData;
  final Map<String, dynamic> document;
  final Function(Map<String, dynamic>) onSubmit;
  final bool showLabel;
  final List<TextInputFormatter>? inputFormatters;
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

    setFormatter("(${_selectedUnit ?? ""})");

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

  void setFormatter(String value) {
    if (value != years || value != months || value != days) {
      return;
    }
    if (value == years) {
      limiterFormatter = [
        FilteringTextInputFormatter.allow(RegExp(r"^[01]$")),
      ];
      setState(() {});
    } else if (value == months) {
      limiterFormatter = [
        FilteringTextInputFormatter.allow(RegExp(r"^([0-9]|1[0-2])$")),
      ];
      setState(() {});
    } else if (value == days) {
      limiterFormatter = [
        FilteringTextInputFormatter.allow(
          RegExp(r"^([0-9]|[1-9][0-9]|[1-2][0-9]{2}|3[0-5][0-9]|36[0-5])$"),
        ),
      ];
      setState(() {});
    }
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
      maxLength: widget.fieldData.maxLength,
      inputFormatters:
          (widget.fieldData.key == "maximumTenor" && limiterFormatter != null)
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
          if (value.keys.toString() == years) {
            limiterFormatter = [
              FilteringTextInputFormatter.allow(RegExp(r"^[01]$")),
            ];
            setState(() {});
          } else if (value.keys.toString() == months) {
            limiterFormatter = [
              FilteringTextInputFormatter.allow(RegExp(r"^([0-9]|1[0-2])$")),
            ];
            setState(() {});
          } else if (value.keys.toString() == days) {
            limiterFormatter = [
              FilteringTextInputFormatter.allow(
                RegExp(
                  r"^([0-9]|[1-9][0-9]|[1-2][0-9]{2}|3[0-5][0-9]|36[0-5])$",
                ),
              ),
            ];
            setState(() {});
          }

          final entry = value.entries.first;
          _selectedUnit = entry.key;

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
