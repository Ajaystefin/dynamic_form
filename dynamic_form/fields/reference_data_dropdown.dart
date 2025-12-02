import 'package:flutter/material.dart';
import 'package:wcas_frontend/core/components/dropdown/model.dart';
import 'package:wcas_frontend/core/components/dropdown/dropdown.dart';
import 'package:wcas_frontend/core/components/dynamic_form/models/field.dart';
import 'package:wcas_frontend/core/components/label.dart';

class DynamicReferenceDataDropdown extends StatelessWidget {
  final DynamicField fieldData;
  final bool showLabel;
  final Function(CustomDropdownItem) selectedOption;
  const DynamicReferenceDataDropdown({
    super.key,
    required this.fieldData,
    this.showLabel = true,
    required this.selectedOption,
  });

  @override
  Widget build(BuildContext context) {
    return LabelWidget(
      showLabel: showLabel,
      label: fieldData.label,
      isRequired: fieldData.required,
      child: CustomDropdown<Option>(
        isEnabled: !fieldData.isDisable,
        isSearchable: true,
        items: fieldData.optionList ?? [],
        onSelected: (value) => selectedOption(value.first),
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
