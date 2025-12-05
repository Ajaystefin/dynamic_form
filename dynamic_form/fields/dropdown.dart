import 'package:flutter/material.dart';
import 'package:wcas_frontend/core/components/dropdown/dropdown.dart';
import 'package:wcas_frontend/core/components/dynamic_form/models/field.dart';
import 'package:wcas_frontend/core/components/label.dart';

class DynamicFormDropdown extends StatefulWidget {
  final DynamicField fieldData;
  final Map<String, dynamic>? document;
  final bool showLabel;
  final Function(Option) selectedOption;

  const DynamicFormDropdown({
    super.key,
    required this.fieldData,
    this.document,
    this.showLabel = true,
    required this.selectedOption,
  });

  @override
  State<DynamicFormDropdown> createState() => _DynamicFormDropdownState();
}

class _DynamicFormDropdownState extends State<DynamicFormDropdown> {
  Option? _selectedOption;

  @override
  void initState() {
    super.initState();
    _initializeFromDocument();
  }

  void _initializeFromDocument() {
    if (widget.document == null) return;

    final storedKey = widget.document![widget.fieldData.key];
    if (storedKey != null && widget.fieldData.optionList != null) {
      try {
        _selectedOption = widget.fieldData.optionList!.firstWhere(
          (option) => option.key == storedKey.toString(),
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
      child: CustomDropdown<Option>(
        validationMessage: widget.fieldData.message,
        isEnabled: !widget.fieldData.isDisable,
        isSearchable: true,
        items: widget.fieldData.optionList ?? [],
        selectedItems: _selectedOption != null ? [_selectedOption] : null,
        onSelected: (value) {
          setState(() => _selectedOption = value.first);
          widget.selectedOption(value.first);
        },
        itemBuilder: (context, item, isDisabled, isSelected) {
          return ListTile(
            title: Text(item.value ?? ""),
          );
        },
        dropdownBuilder: (context, data) {
          return Text(
            data?.value ?? "",
            style: const TextStyle(fontSize: 13),
          );
        },
      ),
    );
  }
}
