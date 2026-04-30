import "package:flutter/material.dart";
import "package:wcas_frontend/core/components/dropdown/dropdown.dart";
import "package:wcas_frontend/core/components/dropdown/model.dart";
import "package:wcas_frontend/core/components/dynamic_form/models/field.dart";
import "package:wcas_frontend/core/components/label.dart";

class DynamicReferenceDataDropdown extends StatefulWidget {
  const DynamicReferenceDataDropdown({
    required this.fieldData,
    required this.onSubmit,
    required this.selectedOption,
    super.key,
    this.document,
    this.showLabel = true,
  });
  final DynamicField fieldData;
  final Map<String, dynamic>? document;
  final bool showLabel;
  final Function(String?) onSubmit;
  final Function(CustomDropdownItem) selectedOption;

  @override
  State<DynamicReferenceDataDropdown> createState() =>
      _DynamicReferenceDataDropdownState();
}

class _DynamicReferenceDataDropdownState
    extends State<DynamicReferenceDataDropdown> {
  Option? _selectedOption;
  CustomDropdownItem? selectedValue;

  void _syncSelectedOptionFromDocument() {
    if (widget.document == null) {
      _selectedOption = null;
      return;
    }

    final storedValue = widget.document![widget.fieldData.key];
    if (storedValue != null && widget.fieldData.optionList != null) {
      try {
        _selectedOption = widget.fieldData.optionList!.firstWhere(
          (option) =>
              option.value == storedValue.toString() ||
              option.key == storedValue.toString(),
          orElse: () => throw StateError("Not found"),
        );
      } catch (e) {
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
        items: widget.fieldData.optionList ?? [],
        selectedItems: _selectedOption != null ? [_selectedOption] : null,
        onSelected: (value) {
          setState(() => _selectedOption = value.first);
          widget.selectedOption(value.first);
          selectedValue = value.first;
        },
        itemBuilder: (context, item, isDisabled, isSelected) {
          return dropdownItemBuildWidget(
            item.metaData?.name,
            isListTile: true,
            isSelected: isSelected,
          );
        },
        filterFn: (Option item, String search) {
          return (item.metaData?.name ?? "")
              .toLowerCase()
              .contains(search.toLowerCase());
        },
        dropdownBuilder: (context, data) {
          return Text(
            data?.metaData?.name ?? "",
            style: const TextStyle(fontSize: 13),
          );
        },
      ),
    );
  }
}
