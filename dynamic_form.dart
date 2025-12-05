import 'package:flutter/material.dart';
import 'package:wcas_frontend/core/components/box_layout.dart';
import 'package:wcas_frontend/core/components/dynamic_form/field.dart';
import 'package:wcas_frontend/core/components/dynamic_form/field_dependencies.dart';
import 'package:wcas_frontend/core/components/dynamic_form/models/section.dart';
import 'package:wcas_frontend/core/constants/constants.dart';

class DynamicForm extends StatefulWidget {
  final List<Section> sections;
  final Map<String, dynamic> document;
  final GlobalKey formKey;
  final FieldDependencies? dependencies;

  const DynamicForm({
    super.key,
    required this.sections,
    required this.document,
    required this.formKey,
    this.dependencies,
  });

  @override
  State<DynamicForm> createState() => DynamicFormState();
}

class DynamicFormState extends State<DynamicForm> {
  final Map<String, TextEditingController> dependentControllers = {};

  /// Updates the value of a specific field identified by its key.
  ///
  /// This method works for ALL field types in the dynamic form:
  /// - Text fields (textField, percentage, amount, customerSearch)
  /// - Dropdowns (dropdown, refDataDropdown, countryDropdown, conditionalDropdown)
  /// - Currency fields (currency)
  /// - Date fields (datePicker)
  /// - Checkboxes (singleCheckBox)
  /// - Multi-select fields (multiSelect)
  /// - Text areas (textArea)
  /// - Radio buttons (radioButton)
  /// - Grids and tables (grid, table)
  /// - Other field types (tenorControl, conditionalTextbox)
  ///
  /// Parameters:
  /// - [fieldKey]: The unique key of the field to update
  /// - [value]: The new value to set. Type depends on field type:
  ///   - String for text fields, dropdowns, text areas
  ///   - Map<String, dynamic> for currency fields (e.g., {'currency': 'USD', 'value': '1000'})
  ///   - Map<String, dynamic> for date fields (with date, jsdate, formatted, epoc)
  ///   - bool for checkboxes
  ///   - List for multi-select fields
  ///
  /// Returns true if the field was found and updated, false otherwise.
  bool updateFieldValue(String fieldKey, dynamic value) {
    // Update the document map - this works for ALL field types
    widget.document[fieldKey] = value;

    // Update controller if it exists (for text-based and currency fields)
    if (dependentControllers.containsKey(fieldKey)) {
      final controller = dependentControllers[fieldKey];
      if (controller != null) {
        // Handle different value types
        if (value is Map<String, dynamic>) {
          // For currency fields, extract the value part
          if (value.containsKey('value')) {
            controller.text = value['value']?.toString() ?? '';
          }
        } else if (value != null) {
          controller.text = value.toString();
        } else {
          controller.text = '';
        }
      }
    }

    // Trigger dependent field updates if dependencies exist
    if (widget.dependencies != null) {
      final dependencies =
          widget.dependencies!.getDependenciesForSource(fieldKey);
      for (var dependency in dependencies) {
        final newValue = dependency.calculator(widget.document);
        updateFieldValue(dependency.dependentFieldKey, newValue);
      }
    }

    // Refresh UI - this ensures dropdowns, checkboxes, and other
    // non-controller fields update immediately
    setState(() {});
    return true;
  }

  /// Retrieves the current value of a field by its key.
  ///
  /// Parameters:
  /// - [fieldKey]: The unique key of the field
  ///
  /// Returns the field value from the document map, or null if not found.
  dynamic getFieldValue(String fieldKey) {
    return widget.document[fieldKey];
  }

  /// Resets a specific field to null/empty.
  ///
  /// Parameters:
  /// - [fieldKey]: The unique key of the field to reset
  ///
  /// Returns true if the field was found and reset, false otherwise.
  bool resetField(String fieldKey) {
    widget.document[fieldKey] = null;

    // Clear controller if it exists
    if (dependentControllers.containsKey(fieldKey)) {
      dependentControllers[fieldKey]?.clear();
    }

    // Refresh UI
    setState(() {});
    return true;
  }

  /// Updates multiple fields at once in a batch operation.
  ///
  /// This is more efficient than calling updateFieldValue multiple times
  /// as it only triggers a single UI refresh.
  ///
  /// Works for all field types: text, dropdown, currency, date, checkbox, etc.
  ///
  /// Parameters:
  /// - [updates]: Map of field keys to their new values
  ///
  /// Example:
  /// ```dart
  /// updateMultipleFields({
  ///   'facilityTitle': 'New Title',
  ///   'sector': '356',
  ///   'proposedLimit': {'currency': 'USD', 'value': '1000'},
  ///   'isCommitted': true,
  ///   'limitAvailabilityDate': {...},
  /// });
  /// ```
  void updateMultipleFields(Map<String, dynamic> updates) {
    for (var entry in updates.entries) {
      final fieldKey = entry.key;
      final value = entry.value;

      // Update document map - works for ALL field types
      widget.document[fieldKey] = value;

      // Update controller if it exists (for text-based and currency fields)
      if (dependentControllers.containsKey(fieldKey)) {
        final controller = dependentControllers[fieldKey];
        if (controller != null) {
          if (value is Map<String, dynamic>) {
            // For currency fields, extract the value part
            if (value.containsKey('value')) {
              controller.text = value['value']?.toString() ?? '';
            }
          } else if (value != null) {
            controller.text = value.toString();
          } else {
            controller.text = '';
          }
        }
      }
    }

    // Trigger dependent field updates for all updated fields
    if (widget.dependencies != null) {
      for (var fieldKey in updates.keys) {
        final dependencies =
            widget.dependencies!.getDependenciesForSource(fieldKey);
        for (var dependency in dependencies) {
          final newValue = dependency.calculator(widget.document);
          widget.document[dependency.dependentFieldKey] = newValue;

          if (dependentControllers.containsKey(dependency.dependentFieldKey)) {
            dependentControllers[dependency.dependentFieldKey]?.text = newValue;
          }
        }
      }
    }

    // Single UI refresh for all updates - ensures all field types update
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return BoxLayout(
      child: Form(
        key: widget.formKey,
        child: ListView.builder(
          shrinkWrap: true,
          itemCount: widget.sections.length,
          itemBuilder: (context, index) => widget.sections[index].rows != null
              ? ListView.builder(
                  shrinkWrap: true,
                  itemCount: widget.sections[index].rows!.length,
                  itemBuilder: (context, rowIndex) {
                    if (widget.sections[index].rows![rowIndex].fields == null) {
                      return const SizedBox();
                    }
                    return Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: List.generate(
                        (widget.sections[index].rows![rowIndex].fields ?? [])
                            .length,
                        (fieldIndex) => Expanded(
                            child: Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: AppStyle.spacing,
                            vertical: AppStyle.spacingSmall,
                          ),
                          child: DynamicFormField(
                            field: widget.sections[index].rows![rowIndex]
                                .fields![fieldIndex],
                            document: widget.document,
                            dependencies: widget.dependencies,
                            dependentControllers: dependentControllers,
                          ),
                        )),
                      ),
                    );
                  },
                )
              : Container(),
        ),
      ),
    );
  }
}
