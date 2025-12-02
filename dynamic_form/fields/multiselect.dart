import 'package:flutter/material.dart';
import 'package:wcas_frontend/core/components/dropdown/model.dart';
import 'package:wcas_frontend/core/components/dropdown/multi_select_dropdown.dart';
import 'package:wcas_frontend/core/components/dynamic_form/models/field.dart';
import 'package:wcas_frontend/core/components/label.dart';

class DynamicFormMultiSelectDropdown extends StatelessWidget {
  final DynamicField fieldData;
  final bool showLabel;
  final Function(List<CustomDropdownItem>) selectedOptions;
  const DynamicFormMultiSelectDropdown(
      {super.key,
      required this.fieldData,
      required this.selectedOptions,
      this.showLabel = true});

  @override
  Widget build(BuildContext context) {
    return LabelWidget(
      showLabel: showLabel,
      label: fieldData.label,
      isRequired: fieldData.required,
      child: CustomMultiSelectDropdown(
          isEnabled: !fieldData.isDisable,
          isSearchable: true,
          items: (fieldData.optionList ?? []).map((e) => e.value).toList(),
          onSelected: (value) => selectedOptions),
    );
  }
}
