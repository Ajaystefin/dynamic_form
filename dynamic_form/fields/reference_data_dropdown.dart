import 'package:flutter/material.dart';
import 'package:wcas_frontend/core/components/dropdown/model.dart';
import 'package:wcas_frontend/core/components/dropdown/dropdown.dart';
import 'package:wcas_frontend/core/components/dynamic_form/models/field.dart';
import 'package:wcas_frontend/core/components/label.dart';

class DynamicReferenceDataDropdown extends StatefulWidget {
  final DynamicField fieldData;
  final Map<String, dynamic>? document;
  final bool showLabel;
  final Function(CustomDropdownItem) selectedOption;

  const DynamicReferenceDataDropdown({
    super.key,
    required this.fieldData,
    this.document,
    this.showLabel = true,
    required this.selectedOption,
  });

  @override
  State<DynamicReferenceDataDropdown> createState() =>
      _DynamicReferenceDataDropdownState();
}

class _DynamicReferenceDataDropdownState
    extends State<DynamicReferenceDataDropdown> {
  Option? _selectedOption;

  @override
  void initState() {
    super.initState();
    _initializeFromDocument();
  }

  void _initializeFromDocument() {
    if (widget.document == null) return;

    final storedValue = widget.document![widget.fieldData.key];
    if (storedValue != null && widget.fieldData.optionList != null) {
      try {
        _selectedOption = widget.fieldData.optionList!.firstWhere(
          (option) =>
              option.value == storedValue.toString() ||
              option.key == storedValue.toString(),
          orElse: () => widget.fieldData.optionList!.first,
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
      exponent: widget.fieldData.isCMOUpdate ? "#" : null,
      child: CustomDropdown<Option>(
        isEnabled: !widget.fieldData.isDisable,
        isSearchable: true,
        items: widget.fieldData.optionList ?? [],
        selectedItems: _selectedOption != null ? [_selectedOption] : null,
        onSelected: (value) {
          setState(() => _selectedOption = value.first);
          widget.selectedOption(value.first);
        },
        itemBuilder: (context, item, isDisabled, isSelected) {
          return dropdownItemBuildWidget(item.metaData?.name,
              isListTile: true, isSelected: isSelected);
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
