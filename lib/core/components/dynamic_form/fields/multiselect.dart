import "package:flutter/material.dart";
import "package:wcas_frontend/core/components/dropdown/multi_select_dropdown.dart";
import "package:wcas_frontend/core/components/dynamic_form/models/field.dart";
import "package:wcas_frontend/core/components/label.dart";

class DynamicFormMultiSelectDropdown extends StatelessWidget {
  DynamicFormMultiSelectDropdown({
    required this.fieldData,
    required this.selectedOptions,
    required this.document,
    super.key,
    this.showLabel = true,
  });
  final DynamicField fieldData;
  final bool showLabel;
  final Function(List<dynamic>) selectedOptions;
  final Map<String, dynamic> document;
  final ScrollController _scrollController = ScrollController();

  @override
  Widget build(BuildContext context) {
    // Extract selected items from document
    List<String> selectedItems = [];
    final currentValue = document[fieldData.key];

    if (currentValue is List) {
      // Filter to only include values that exist in optionList
      final availableValues =
          (fieldData.optionList ?? []).map((e) => e.value).toSet();

      debugPrint("Available values from optionList: $availableValues");

      selectedItems = currentValue
          .where((item) => availableValues.contains(item.toString()))
          .map((item) => item.toString())
          .toList();

      debugPrint("Filtered selectedItems: $selectedItems");
    } else {}
    debugPrint("===================");

    return LabelWidget(
      showLabel: showLabel,
      label: fieldData.label,
      isRequired: fieldData.isRequired,
      exponent: fieldData.isCMOUpdate ? "#" : null,
      child: CustomMultiSelectDropdown<String>(
        key: ValueKey(selectedItems.length),
        semanticLabel: fieldData.label,
        validationMessage: fieldData.isRequired
            ? (fieldData.message ?? "${fieldData.label} is required")
            : null,
        isEnabled: !fieldData.isDisable,
        isSearchable: true,
        items: (fieldData.optionList ?? [])
            .map((e) => e.value)
            .toList()
            .cast<String>(),
        selectedItems: selectedItems,
        onSelected: (value) {
          // value is List<dynamic> containing the selected string values
          selectedOptions(value.cast<dynamic>());
        },
        itemBuilder: (context, item, isDisabled, isSelected) {
          return dropdownMultiItemBuildWidget(
            item,
            isListTile: true,
            isSelected: isSelected,
          );
        },
        dropdownBuilder: (context, data) {
          return multiSelectDropDownBuilderWidget(
            data: data!,
            controller: _scrollController,
            key: ValueKey(selectedItems.length),
            itemBuilder: (index) {
              final String item = data[index];
              return Container(
                margin:
                    const EdgeInsets.only(left: 5, top: 5, bottom: 5, right: 5),
                child: buildMultiSelectChip(
                  label: buildItemText(
                    item,
                    FontSizeHelper(size: FontSize.small),
                  ),
                  onDeleted: () {
                    // Remove the item at the specified index and update
                    selectedOptions(List<String>.from(data)..removeAt(index));
                  },
                ),
              );
            },
          );
        },
      ),
    );
  }
}
