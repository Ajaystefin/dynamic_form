import "package:flutter/material.dart";
import "package:wcas_frontend/core/components/dropdown/dropdown.dart";
import "package:wcas_frontend/core/components/dynamic_form/models/field.dart";
import "package:wcas_frontend/core/components/label.dart";
import "package:wcas_frontend/core/utils/scale.dart";

/// Dynamic editable dropdown form field.
class DynamicFormEditableDropdown extends StatefulWidget {
  /// Creates a [DynamicFormEditableDropdown].
  const DynamicFormEditableDropdown({
    required this.fieldData,
    required this.onValueChange,
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

  /// Callback invoked when the value changes.
  final Function(String?) onValueChange;
  
  @override
  State<DynamicFormEditableDropdown> createState() =>
      _DynamicFormEditableDropdownState();
}

class _DynamicFormEditableDropdownState
    extends State<DynamicFormEditableDropdown> {
  Option? _selectedOption;
  final TextEditingController _editController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _syncFromDocument();
  }

  @override
  void didUpdateWidget(DynamicFormEditableDropdown oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Re-sync if the value for this field changed in the document
    final oldValue = oldWidget.document?[widget.fieldData.key];
    final newValue = widget.document?[widget.fieldData.key];
    if (oldValue != newValue) {
      _syncFromDocument();
    }
  }

  /// Syncs the widget state from the document
  /// Tries to match against optionList first, otherwise enters edit mode
  void _syncFromDocument() {
    if (widget.document == null) {
      _selectedOption = null;
      _editController.clear();
      return;
    }

    final storedValue = widget.document![widget.fieldData.key];
    if (storedValue == null) {
      _selectedOption = null;
      _editController.clear();
      return;
    }

    // Try to find matching option
    if (widget.fieldData.optionList != null) {
      try {
        _selectedOption = widget.fieldData.optionList!.firstWhere(
          (option) => option.key == storedValue.toString(),
          orElse: () => throw StateError("Not found"),
        );
        _editController.clear();
        return;
      } on Object {
        // No matching option found, treat as custom text
        _selectedOption = null;
        _editController.text = storedValue.toString();
      }
    } else {
      // No option list, treat as custom text
      _selectedOption = null;
      _editController.text = storedValue.toString();
    }
  }

  void _onDropdownSelected(Option option) {
    setState(() {
      _selectedOption = option;
      _editController.clear();
    });
    widget.onValueChange(option.key);
  }

  void _onEditModeActivated() {
    // CustomDropdown handles pre-filling the edit controller
    // We just need to update state if needed
  }

  void _onTextChanged(String text) {
    // Update document on every keystroke to ensure value is saved
    // when form.save() is called
    widget.onValueChange(text.isEmpty ? null : text);
  }

  void _onEditComplete(String text) {
    // Store the final custom text when user finishes editing
    widget.onValueChange(text.isEmpty ? null : text);
  }

  @override
  void dispose() {
    _editController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return LabelWidget(
      showLabel: widget.showLabel,
      label: widget.fieldData.label,
      isRequired: widget.fieldData.isRequired,
      exponent: widget.fieldData.isCMOUpdate ? "#" : null,
      child: CustomDropdown<Option>(
        width: 230.w,
        validationMessage: widget.fieldData.isRequired
            ? (widget.fieldData.message ??
                "${widget.fieldData.label} is required")
            : null,
        isEnabled: !widget.fieldData.isDisable,
        isSearchable: true,
        items: widget.fieldData.optionList ?? [],
        selectedItems: _selectedOption != null ? [_selectedOption] : null,
        onSelected: (value) {
          _onDropdownSelected(value.first);
        },
        itemBuilder: (context, item, {isDisabled, isSelected}) {
          return ListTile(
            title: Text(item.value ?? ""),
          );
        },
        filterFn: (item, search) {
          return (item.value ?? "")
              .toLowerCase()
              .contains(search.toLowerCase());
        },
        dropdownBuilder: (context, data) {
          return Text(
            data?.value ?? "",
            style: const TextStyle(fontSize: 13),
          );
        },
        // Enable edit mode
        showEditIcon: true,
        onEditModeActivated: _onEditModeActivated,
        onTextChanged: _onTextChanged,
        onEditComplete: _onEditComplete,
        editController: _editController,
        // editHintText: 'Enter custom value',
      ),
    );
  }
}
