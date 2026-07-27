import "package:flutter/material.dart";
import "package:flutter/services.dart";
import "package:wcas_frontend/core/components/dynamic_form/models/field.dart";
import "package:wcas_frontend/core/components/label.dart";
import "package:wcas_frontend/core/components/radiobutton.dart";

/// A dynamic radio button field for dynamic forms.
///
/// Displays a list of radio button options and allows selection
/// of a single value.
class DynamicRadioButton extends StatefulWidget {
  /// Creates a [DynamicRadioButton].
  const DynamicRadioButton({
    required this.fieldData,
    required this.onChange,
    required this.options,
    super.key,
    this.document,
    this.inputFormatters,
    this.showLabel = true,
  });

  /// Field configuration data.
  final DynamicField fieldData;

  /// Form document data.
  final Map<String, dynamic>? document;

  /// Callback invoked when the selected value changes.
  final Function(String?) onChange;

  /// Input formatters applied to the field.
  final List<TextInputFormatter>? inputFormatters;

  /// Whether to display the field label.
  final bool showLabel;

  /// Available radio button options.
  final List<String> options;

  @override
  State<DynamicRadioButton> createState() => _DynamicRadioButtonState();
}

class _DynamicRadioButtonState extends State<DynamicRadioButton> {
  String? selectedValue;

  @override
  void initState() {
    super.initState();

    // First, try to sync from document (prefill from API)
    _syncFromDocument();

    // If still null and field is required, set first option as default
    if (selectedValue == null &&
        widget.fieldData.isRequired &&
        widget.options.isNotEmpty) {
      selectedValue = widget.options.first;
      widget.onChange(selectedValue);
    }
  }

  /// Syncs the selected value from the document map for prefilling
  void _syncFromDocument() {
    if (widget.document == null) {
      return;
    }

    final storedValue = widget.document![widget.fieldData.key];
    if (storedValue != null &&
        widget.options.contains(storedValue.toString())) {
      selectedValue = storedValue.toString();
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
                      "${widget.fieldData.label} is required";
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
      ),
    );
  }
}
