import "package:flutter/material.dart";
import "package:wcas_frontend/core/components/dropdown/dropdown.dart";
import "package:wcas_frontend/core/components/dropdown/model.dart";
import "package:wcas_frontend/core/components/dynamic_form/models/field.dart";
import "package:wcas_frontend/core/components/label.dart";

/// Dynamic country dropdown field.
class DynamicFormCountryDropdown extends StatefulWidget {
  /// Creates a [DynamicFormCountryDropdown].
  const DynamicFormCountryDropdown({
    required this.fieldData,
    required this.selectedOption,
    super.key,
    this.document,
    this.showLabel = true,
  });

  /// Field configuration data.
  final DynamicField fieldData;

  /// Form document data.
  final Map<String, dynamic>? document;

  /// Whether to display the field label.
  final bool showLabel;

  /// Callback invoked when a country is selected.
  final Function(CustomDropdownItem) selectedOption;

  @override
  State<DynamicFormCountryDropdown> createState() =>
      _DynamicFormCountryDropdownState();
}

class _DynamicFormCountryDropdownState
    extends State<DynamicFormCountryDropdown> {
  Option? _selectedOption;

  void _syncSelectedOptionFromDocument() {
    if (widget.document == null) {
      _selectedOption = null;
      return;
    }

    final storedValue = widget.document![widget.fieldData.key];
    if (storedValue != null && widget.fieldData.dependentList != null) {
      try {
        _selectedOption = widget.fieldData.dependentList!.firstWhere(
          (option) =>
              option.pairValue == storedValue.toString() ||
              option.key == storedValue.toString(),
          orElse: () => throw StateError("Not found"),
        );
      } on Object {
        _selectedOption = null;
      }
    } else {
      // If storedValue is null, clear the selection
      _selectedOption = null;
    }
  }

  @override
  Widget build(BuildContext context) {
    // CRITICAL: Always sync with document before building
    // This ensures clearSelection works correctly
    _syncSelectedOptionFromDocument();

    return LabelWidget(
      showLabel: widget.showLabel,
      label: widget.fieldData.label,
      isRequired: widget.fieldData.isRequired,
      exponent: widget.fieldData.isCMOUpdate ? "#" : null,
      child: CustomDropdown<Option>(
        validationMessage: widget.fieldData.isRequired
            ? (widget.fieldData.message ??
                "${widget.fieldData.label} is required")
            : null,
        isEnabled: !widget.fieldData.isDisable,
        isSearchable: true,
        items: widget.fieldData.dependentList ?? [],
        selectedItems: _selectedOption != null ? [_selectedOption] : null,
        onSelected: (value) {
          setState(() => _selectedOption = value.first);
          widget.selectedOption(value.first);
        },
        itemBuilder: (context, item, {isDisabled, isSelected}) {
          return dropdownItemBuildWidget(
            item.pairValue,
            isSelected: isSelected ?? false,
          );
        },
        dropdownBuilder: (context, data) {
          return Text(
            data?.pairValue ?? "",
            style: const TextStyle(fontSize: 13),
          );
        },
      ),
    );
  }
}
