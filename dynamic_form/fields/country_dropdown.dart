import 'package:flutter/material.dart';
import 'package:wcas_frontend/core/components/dropdown/model.dart';
import 'package:wcas_frontend/core/components/dropdown/dropdown.dart';
import 'package:wcas_frontend/core/components/dynamic_form/models/field.dart';
import 'package:wcas_frontend/core/components/label.dart';

class DynamicFormCountryDropdown extends StatefulWidget {
  final DynamicField fieldData;
  final Map<String, dynamic>? document;
  final bool showLabel;
  final Function(CustomDropdownItem) selectedOption;

  const DynamicFormCountryDropdown({
    super.key,
    required this.fieldData,
    this.document,
    this.showLabel = true,
    required this.selectedOption,
  });

  @override
  State<DynamicFormCountryDropdown> createState() =>
      _DynamicFormCountryDropdownState();
}

class _DynamicFormCountryDropdownState
    extends State<DynamicFormCountryDropdown> {
  Option? _selectedOption;

  @override
  void initState() {
    super.initState();
    _initializeFromDocument();
  }

  void _initializeFromDocument() {
    if (widget.document == null) return;

    final storedValue = widget.document![widget.fieldData.key];
    if (storedValue != null && widget.fieldData.dependentList != null) {
      try {
        _selectedOption = widget.fieldData.dependentList!.firstWhere(
          (option) =>
              option.pairValue == storedValue.toString() ||
              option.key == storedValue.toString(),
          orElse: () => widget.fieldData.dependentList!.first,
        );
      } catch (e) {
        _selectedOption = null;
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return LabelWidget(
      showLabel: widget.showLabel,
      label: widget.fieldData.label,
      isRequired: widget.fieldData.required,
      child: CustomDropdown<Option>(
        validationMessage: widget.fieldData.message,
        isEnabled: !widget.fieldData.isDisable,
        isSearchable: true,
        items: widget.fieldData.dependentList ?? [],
        selectedItems: _selectedOption != null ? [_selectedOption] : null,
        onSelected: (value) {
          setState(() => _selectedOption = value.first);
          widget.selectedOption(value.first);
        },
        itemBuilder: (context, item, isDisabled, isSelected) {
          return dropdownItemBuildWidget(item.pairValue,
              isListTile: true, isSelected: isSelected);
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
