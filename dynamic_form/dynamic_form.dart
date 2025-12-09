import 'package:flutter/material.dart';
import 'package:wcas_frontend/core/components/box_layout.dart';
import 'package:wcas_frontend/core/components/dynamic_form/field.dart';
import 'package:wcas_frontend/core/components/dynamic_form/models/field.dart';
import 'package:wcas_frontend/core/components/dynamic_form/models/row_element.dart';
import 'package:wcas_frontend/core/components/dynamic_form/models/section.dart';
import 'package:wcas_frontend/core/components/gap.dart';
import 'package:wcas_frontend/core/constants/constants.dart';

class DynamicForm extends StatefulWidget {
  final List<Section> sections;
  final Map<String, dynamic> document;
  final void Function(String fieldKey, dynamic value)? onFieldChange;

  const DynamicForm({
    super.key,
    required this.sections,
    required this.document,
    this.onFieldChange,
  });

  @override
  State<DynamicForm> createState() => DynamicFormState();
}

class DynamicFormState extends State<DynamicForm> {
  final GlobalKey<FormState> _internalFormKey = GlobalKey<FormState>();

  // Centralized controller management for text-based fields
  final Map<String, TextEditingController> _controllers = {};

  @override
  void initState() {
    super.initState();
    _initializeControllers();
  }

  @override
  void dispose() {
    // Dispose all controllers
    for (var controller in _controllers.values) {
      controller.dispose();
    }
    _controllers.clear();
    super.dispose();
  }

  /// Initialize controllers for text-based fields
  void _initializeControllers() {
    for (var section in widget.sections) {
      for (var row in section.rows ?? []) {
        for (var field in row.fields ?? []) {
          if (_needsController(field.controlType)) {
            final initialValue = widget.document[field.key];
            String textValue = '';

            // Handle different value types
            if (initialValue != null) {
              if (field.controlType == FieldType.currency &&
                  initialValue is Map) {
                // For currency fields, extract the numeric value
                textValue = initialValue['fromVal']?.toString() ?? '';
              } else {
                textValue = initialValue.toString();
              }
            }

            _controllers[field.key] = TextEditingController(text: textValue);
          }
        }
      }
    }
  }

  /// Check if a field type needs a TextEditingController
  bool _needsController(FieldType type) {
    return type == FieldType.textField ||
        type == FieldType.percentage ||
        type == FieldType.amount ||
        type == FieldType.currency ||
        type == FieldType.entityIdField ||
        type == FieldType.customerSearch ||
        type == FieldType.textArea ||
        type == FieldType.conditionalTextbox;
  }

  /// Validates all form fields
  ///
  /// Returns true if all fields pass validation, false otherwise.
  ///
  /// Example:
  /// ```dart
  /// if (dynamicFormKey.currentState?.validate() ?? false) {
  ///   // All fields are valid
  /// }
  /// ```
  bool validate() {
    return _internalFormKey.currentState?.validate() ?? false;
  }

  /// Saves all form fields
  ///
  /// Calls the onSaved callback for each field.
  ///
  /// Example:
  /// ```dart
  /// dynamicFormKey.currentState?.save();
  /// ```
  void save() {
    _internalFormKey.currentState?.save();
  }

  /// Updates the value of a specific field in the form
  ///
  /// This method updates the field's value in the document and syncs
  /// the controller if the field has one (text-based fields).
  ///
  /// Parameters:
  /// - [fieldKey]: The key of the field to update
  /// - [value]: The new value to set
  /// - [triggerDependencies]: Whether to trigger dependent field updates (deprecated)
  ///
  /// Example:
  /// ```dart
  /// dynamicFormKey.currentState?.updateFieldValue('policyNumber', 'POL123');
  /// ```
  void updateFieldValue(
    String fieldKey,
    dynamic value, {
    bool triggerDependencies = true,
  }) {
    // Update document map
    widget.document[fieldKey] = value;

    // Update controller if this field has one
    if (_controllers.containsKey(fieldKey)) {
      String textValue = '';

      // Handle different value types
      if (value != null) {
        if (value is Map && value.containsKey('fromVal')) {
          // Currency field format
          textValue = value['fromVal']?.toString() ?? '';
        } else {
          textValue = value.toString();
        }
      }

      // Only update if different to avoid cursor jumping
      if (_controllers[fieldKey]!.text != textValue) {
        _controllers[fieldKey]!.text = textValue;
      }
    }

    // Rebuild to reflect changes
    setState(() {});
  }

  /// Shows or hides a field based on conditional logic
  ///
  /// This method updates the field's `isActive` property to control visibility.
  /// Hidden fields are not rendered in the UI.
  ///
  /// Parameters:
  /// - [fieldKey]: The key of the field to show/hide
  /// - [isVisible]: true to show the field, false to hide it
  ///
  /// Example:
  /// ```dart
  /// // Hide a field
  /// dynamicFormKey.currentState?.setFieldVisibility('insuranceCompany', false);
  ///
  /// // Show a field
  /// dynamicFormKey.currentState?.setFieldVisibility('insuranceCompany', true);
  /// ```
  void setFieldVisibility(String fieldKey, bool isVisible) {
    // Find and update the field's isActive property
    for (Section section in widget.sections) {
      for (RowElement row in section.rows ?? []) {
        for (DynamicField field in row.fields ?? []) {
          if (field.key == fieldKey) {
            field.showField = isVisible;
            setState(() {});
            return;
          }
        }
      }
    }
  }

  /// Updates multiple field values at once
  ///
  /// This is more efficient than calling updateFieldValue multiple times
  /// as it only triggers a single rebuild and dependency calculation pass.
  ///
  /// Parameters:
  ///   - updates: Map of field keys to their new values
  ///   - triggerDependencies: Whether to recalculate dependent fields (default: true)
  ///
  /// Example:
  /// ```dart
  /// dynamicFormKey.currentState?.updateFields({
  ///   'policyNumber': '12345',
  ///   'premiumAmount': {'fromCurrency': 'AED', 'fromVal': 50, 'aedEquivalent': 50},
  ///   'mortgagedInFavourOfCBD': true,
  /// });
  /// ```
  void updateFields(
    Map<String, dynamic> updates, {
    bool triggerDependencies = true,
  }) {
    // Update all fields
    for (var entry in updates.entries) {
      final fieldKey = entry.key;
      final value = entry.value;

      // Update document map
      widget.document[fieldKey] = value;
    }

    // Single rebuild for all changes
    setState(() {});
  }

  /// Retrieves the current value of a field by its key
  ///
  /// Returns the value from the document map, or null if the field doesn't exist.
  ///
  /// Example:
  /// ```dart
  /// final premiumAmount = dynamicFormKey.currentState?.getFieldValue('premiumAmount');
  /// if (premiumAmount is Map<String, dynamic>) {
  ///   final aedValue = premiumAmount['aedEquivalent'];
  /// }
  /// ```
  dynamic getFieldValue(String fieldKey) {
    return widget.document[fieldKey];
  }

  /// Retrieves all current field values
  ///
  /// Returns a copy of the document map to prevent external modifications.
  ///
  /// Example:
  /// ```dart
  /// final allValues = dynamicFormKey.currentState?.getAllFieldValues();
  /// print('Form data: $allValues');
  /// ```
  Map<String, dynamic> getAllFieldValues() {
    return Map<String, dynamic>.from(widget.document);
  }

  /// Updates the options list for a dropdown field
  ///
  /// This method allows programmatic updates of dropdown options, useful for
  /// implementing cascading dropdowns or conditional option filtering.
  ///
  /// Parameters:
  ///   - fieldKey: The unique key of the dropdown field to update
  ///   - newOptions: The new list of options to set
  ///   - clearSelection: Whether to clear the current selection if it's not in the new options (default: false)
  ///
  /// Example:
  /// ```dart
  /// // Update state dropdown based on selected country
  /// dynamicFormKey.currentState?.updateDropdownOptions(
  ///   'state',
  ///   stateOptions,
  ///   clearSelection: true,
  /// );
  /// ```
  void updateDropdownOptions(
    String fieldKey,
    List<Option> newOptions, {
    bool clearSelection = false,
  }) {
    // Find the field in sections
    DynamicField? targetField;
    for (var section in widget.sections) {
      if (section.rows == null) continue;
      for (var row in section.rows!) {
        if (row.fields == null) continue;
        for (var field in row.fields!) {
          if (field.key == fieldKey) {
            targetField = field;
            break;
          }
        }
        if (targetField != null) break;
      }
      if (targetField != null) break;
    }

    if (targetField == null) {
      // Field not found
      return;
    }

    // Validate that this is a dropdown field
    final isDropdownField = targetField.controlType == FieldType.dropdown ||
        targetField.controlType == FieldType.conditionaldropdown ||
        targetField.controlType == FieldType.refDataDropdown ||
        targetField.controlType == FieldType.countryDropdown;

    if (!isDropdownField) {
      // Not a dropdown field
      return;
    }

    // Update the options list
    targetField.optionList = newOptions;

    // Check if current selection is still valid
    if (clearSelection) {
      final currentValue = widget.document[fieldKey];
      if (currentValue != null) {
        final isValidSelection = newOptions.any(
          (option) => option.key == currentValue.toString(),
        );
        if (!isValidSelection) {
          // Clear the selection
          widget.document[fieldKey] = null;
        }
      }
    }

    // Rebuild to reflect changes
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return BoxLayout(
      child: Form(
        key: _internalFormKey,
        child: ListView.separated(
          separatorBuilder: (context, index) => const Gap(size: GapSize.medium),
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
                    DynamicField sizedDynamicField = DynamicField(
                        controlType: FieldType.sizedBox,
                        key: '',
                        label: '',
                        required: false,
                        rowData: 3,
                        enabledDefault: false,
                        isDisable: false);
                    bool containsGrid =
                        (widget.sections[index].rows![rowIndex].fields ?? [])
                            .any((e) =>
                                e.controlType == FieldType.grid ||
                                e.controlType == FieldType.table);
                    if (!containsGrid &&
                        (widget.sections[index].rows![rowIndex].fields ?? [])
                                .length ==
                            1) {
                      (widget.sections[index].rows![rowIndex].fields ?? [])
                          .add(sizedDynamicField);
                      (widget.sections[index].rows![rowIndex].fields ?? [])
                          .add(sizedDynamicField);
                    }
                    if (!containsGrid &&
                        (widget.sections[index].rows![rowIndex].fields ?? [])
                                .length ==
                            2) {
                      (widget.sections[index].rows![rowIndex].fields ?? [])
                          .add(sizedDynamicField);
                    }
                    return Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: List.generate(
                        (widget.sections[index].rows![rowIndex].fields ?? [])
                            .length,
                        (fieldIndex) {
                          return Expanded(
                              child: Padding(
                            padding: const EdgeInsets.symmetric(
                              horizontal: AppStyle.spacing,
                              vertical: AppStyle.spacingSmall,
                            ),
                            child: DynamicFormField(
                              field: widget.sections[index].rows![rowIndex]
                                  .fields![fieldIndex],
                              document: widget.document,
                              onFieldChange: widget.onFieldChange,
                              controller: _controllers[widget.sections[index]
                                  .rows![rowIndex].fields![fieldIndex].key],
                            ),
                          ));
                        },
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
