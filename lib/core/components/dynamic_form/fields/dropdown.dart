import "package:flutter/material.dart";
import "package:wcas_frontend/core/components/dropdown/dropdown.dart";
import "package:wcas_frontend/core/components/dynamic_form/models/field.dart";
import "package:wcas_frontend/core/components/label.dart";
import "package:wcas_frontend/core/constants/_server_constants.dart";

class DynamicFormDropdown extends StatefulWidget {
  const DynamicFormDropdown({
    required this.fieldData,
    required this.selectedOption,
    super.key,
    this.document,
    this.showLabel = true,
  });
  final DynamicField fieldData;
  final Map<String, dynamic>? document;
  final bool showLabel;
  final Function(Option) selectedOption;

  @override
  State<DynamicFormDropdown> createState() => _DynamicFormDropdownState();
}

//Can reuse this with _syncSelectedOptionFromDocument
Option? syncSelectedOptionFromDocument({
  required Map<String, dynamic>? document,
  required DynamicField fieldData,
  required int index,
}) {
  Option? selectedOption;
  if (document == null) {
    selectedOption = null;
    return selectedOption;
  }

  // final storedKey = document['${fieldData.key}@$index'];
  // if (storedKey != null && fieldData.optionList != null) {

  final dynamic storedKeyRaw = document["${fieldData.key}@$index"];
  if (storedKeyRaw == null || fieldData.optionList == null) return null;

  //normalization only for this indexLcLGCommision field
  //updating data from facility summary this is required for dynamic form
  String storedKey = storedKeyRaw.toString().trim();
  if (fieldData.key == ServerConstants.dfIndexLcLgCommisionKey) {
    storedKey = ServerConstants.dfIndexLcLgCommisionIdToOptionKey[storedKey] ??
        storedKey;
  }

  try {
    selectedOption = fieldData.optionList!.firstWhere(
      (option) => option.key == storedKey.toString(),
      orElse: () => throw StateError("Not found"),
    );
    return selectedOption;
  } catch (e) {
    selectedOption = null;
    return selectedOption;
  }
  // } else {
  //   // If storedKey is null, clear the selection
  //   selectedOption = null;
  //   return selectedOption;
  // }
}

class _DynamicFormDropdownState extends State<DynamicFormDropdown> {
  Option? _selectedOption;

  void _syncSelectedOptionFromDocument() {
    if (widget.document == null) {
      _selectedOption = null;
      return;
    }

    final storedKey = widget.document![widget.fieldData.key];
    if (storedKey != null && widget.fieldData.optionList != null) {
      try {
        _selectedOption = widget.fieldData.optionList!.firstWhere(
          (option) => option.key == storedKey.toString(),
          orElse: () => throw StateError("Not found"),
        );
      } catch (e) {
        _selectedOption = null;
      }
    } else {
      // If storedKey is null, clear the selection
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
        onClear: (_) {
          setState(() => _selectedOption = null);
          if (widget.document != null) {
            widget.document![widget.fieldData.key] = null;
          }
        },
        onSelected: (value) {
          setState(() => _selectedOption = value.first);
          widget.selectedOption(value.first);
        },
        itemBuilder: (context, item, isDisabled, isSelected) {
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
      ),
    );
  }
}
