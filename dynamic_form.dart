import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:wcas_frontend/core/components/box_layout.dart';
import 'package:wcas_frontend/core/components/dynamic_form/field.dart';
import 'package:wcas_frontend/core/components/dynamic_form/models/field.dart';
import 'package:wcas_frontend/core/components/dynamic_form/models/row_element.dart';
import 'package:wcas_frontend/core/components/dynamic_form/models/section.dart';
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
    for (Section section in widget.sections) {
      for (RowElement row in section.rows ?? []) {
        for (DynamicField field in row.fields ?? []) {
          if (_needsController(field.controlType)) {
            final initialValue = widget.document[field.key];
            String textValue = '';
            // Handle different value types
            if (initialValue != null) {
              if (field.controlType == FieldType.currency &&
                  initialValue is Map) {
                final formatter = NumberFormat('#,###');
                // For currency fields, extract the numeric value

                textValue = initialValue['fromVal'] != null
                    ? formatter.format(initialValue['fromVal'])
                    : '';
              } else {
                textValue = initialValue.toString();
              }
            }

            _controllers[field.key] = TextEditingController(text: textValue);
          }
          // else{

          //    debugPrint("found controller for ${field.key} ");
          //   final initialValue = widget.document[field.key];
          //   String textValue = '';

          //   debugPrint("initial value found ${initialValue}");

          //   // Handle different value types
          //   if (initialValue != null) {
          //     if (field.controlType == FieldType.currency &&
          //         initialValue is Map) {
          //           final formatter = NumberFormat('#,###');

          //       // For currency fields, extract the numeric value
          //       textValue = initialValue['fromVal']!=null? formatter.format(initialValue['fromVal']?.toString()) : '';
          //     } else if(field.controlType == FieldType.conditionaldropdown && initialValue is Map) {
          //       debugPrint("inside els if for conditionla dropdown field ${field.key}");
          //       textValue = initialValue["value"].toString();
          //     }
          //     else {
          //       textValue = initialValue.toString();
          //     }
          //   }
          //   //field.label = textValue.toString();

          // }
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
  /// **Supports both normal and grid fields:**
  /// - Normal fields: Pass the value directly
  /// - Grid fields: Pass a map with `{value: actualValue, index: rowIndex}`
  ///
  /// Parameters:
  /// - [fieldKey]: The key of the field to update (without @index for grid fields)
  /// - [value]: The new value to set. For grid fields, use `{value: actualValue, index: rowIndex}`
  /// - [triggerDependencies]: Whether to trigger dependent field updates (deprecated)
  ///
  /// Examples:
  /// ```dart
  /// // Normal field
  /// dynamicFormKey.currentState?.updateFieldValue('policyNumber', 'POL123');
  ///
  /// // Grid field
  /// dynamicFormKey.currentState?.updateFieldValue('customerName', {value: 'John', index: 0});
  /// ```
  void updateFieldValue(
    String fieldKey,
    dynamic value, {
    bool triggerDependencies = true,
  }) {
    // Check if this is a grid field update (value is a map with 'index' key)
    String actualKey = fieldKey;
    dynamic actualValue = value;

    if (value is Map && value.containsKey('index')) {
      // Grid field: construct flattened key
      final rowIndex = value['index'];
      actualKey = '$fieldKey@$rowIndex';
      actualValue = value['value'];
    }

    // Update document map
    widget.document[actualKey] = actualValue;

    // Update controller if this field has one
    if (_controllers.containsKey(actualKey)) {
      String textValue = '';

      // Handle different value types
      if (actualValue != null) {
        if (actualValue is Map && actualValue.containsKey('fromVal')) {
          // Currency field format
          textValue = actualValue['fromVal']?.toString() ?? '';
        } else {
          textValue = actualValue.toString();
        }
      }

      // Only update if different to avoid cursor jumping
      if (_controllers[actualKey]!.text != textValue) {
        _controllers[actualKey]!.text = textValue;
      }
    }
    debugPrint('update doc hash:${widget.document.hashCode}');
    debugPrint('set:$actualKey= $actualValue');

    // Rebuild to reflect changes
    setState(() {});
  }

  /// Shows or hides a field based on conditional logic
  ///
  /// This method updates the field's `showField` property to control visibility.
  /// Hidden fields are not rendered in the UI.
  ///
  /// **Supports both normal and grid fields:**
  /// - Normal fields: Pass fieldKey only
  /// - Grid fields (column in grid): Pass fieldKey only
  ///   - The fieldKey should be the column key within the grid
  ///   - Affects all rows in that column
  ///
  /// Parameters:
  /// - [fieldKey]: The key of the field to show/hide
  ///   - For normal fields: the field's key
  ///   - For grid columns: the column's key (not the grid's key)
  /// - [isVisible]: true to show the field, false to hide it
  /// - [index]: Optional parameter (currently ignored, reserved for future use)
  ///
  /// Examples:
  /// ```dart
  /// // Hide a normal field
  /// dynamicFormKey.currentState?.setFieldVisibility('insuranceCompany', false);
  ///
  /// // Show a normal field
  /// dynamicFormKey.currentState?.setFieldVisibility('insuranceCompany', true);
  ///
  /// // Hide a grid column (affects all rows in that column)
  /// dynamicFormKey.currentState?.setFieldVisibility('customerName', false);
  ///
  /// // Show a grid column
  /// dynamicFormKey.currentState?.setFieldVisibility('customerName', true);
  /// ```
  void setFieldVisibility(String fieldKey, bool isVisible, {int? index}) {
    bool fieldFound = false;
    debugPrint("field check of the key $fieldKey");

    // Search through all sections, rows, and fields
    for (Section section in widget.sections) {
      for (RowElement row in section.rows ?? []) {
        for (DynamicField field in row.fields ?? []) {
          // Check if this is a direct field match
          if (field.key == fieldKey) {
            field.showField = isVisible;
            fieldFound = true;
            setState(() {});
            return;
          }

          debugPrint("field check ${field.controlType} of the key $fieldKey");

          // Check if this is a grid field and search within its columns
          if (field.controlType == FieldType.grid ||
              field.controlType == FieldType.table) {
            if (field.columnInfoList != null) {
              for (var gridColumn in field.columnInfoList!) {
                if (gridColumn.dynamicField.key == fieldKey) {
                  gridColumn.dynamicField.showField = isVisible;
                  fieldFound = true;
                  setState(() {});
                  return;
                }
              }
            }
          }
        }
      }
    }

    if (!fieldFound) {
      debugPrint(
          'setFieldVisibility: Field with key "$fieldKey" not found in form');
    }
  }

  /// Makes a field mandatory or non-mandatory based on conditional logic
  ///
  /// This method updates the field's `isMandatory` property to control whether
  /// the field is required for form validation. When set, this overrides the
  /// field's original `required` property from the API configuration.
  ///
  /// **Supports both normal and grid fields:**
  /// - Normal fields: Pass fieldKey only
  /// - Grid fields (column in grid): Pass fieldKey only
  ///   - The fieldKey should be the column key within the grid
  ///   - Affects all rows in that column
  ///
  /// Parameters:
  /// - [fieldKey]: The key of the field to update
  ///   - For normal fields: the field's key
  ///   - For grid columns: the column's key (not the grid's key)
  /// - [isMandatory]: true to make the field mandatory, false to make it optional
  /// - [index]: Optional parameter (currently ignored, reserved for future use)
  ///
  /// Examples:
  /// ```dart
  /// // Make a normal field mandatory
  /// dynamicFormKey.currentState?.setFieldMandatory('insuranceCompany', true);
  ///
  /// // Make a normal field optional
  /// dynamicFormKey.currentState?.setFieldMandatory('insuranceCompany', false);
  ///
  /// // Make a grid column mandatory (affects all rows in that column)
  /// dynamicFormKey.currentState?.setFieldMandatory('customerName', true);
  ///
  /// // Make a grid column optional
  /// dynamicFormKey.currentState?.setFieldMandatory('customerName', false);
  /// ```
  void setFieldMandatory(String fieldKey, bool isMandatory, {int? index}) {
    bool fieldFound = false;

    // Search through all sections, rows, and fields
    for (Section section in widget.sections) {
      for (RowElement row in section.rows ?? []) {
        for (DynamicField field in row.fields ?? []) {
          // Check if this is a direct field match
          if (field.key == fieldKey) {
            field.isMandatory = isMandatory;
            fieldFound = true;
            setState(() {});
            return;
          }

          // Check if this is a grid field and search within its columns
          if (field.controlType == FieldType.grid ||
              field.controlType == FieldType.table) {
            if (field.columnInfoList != null) {
              for (var gridColumn in field.columnInfoList!) {
                if (gridColumn.dynamicField.key == fieldKey) {
                  gridColumn.dynamicField.isMandatory = isMandatory;
                  fieldFound = true;
                  setState(() {});
                  return;
                }
              }
            }
          }
        }
      }
    }

    if (!fieldFound) {
      debugPrint(
          'setFieldMandatory: Field with key "$fieldKey" not found in form');
    }
  }

  /// Enables or disables a field based on conditional logic
  ///
  /// This method updates the field's `isDisable` property to control whether
  /// the field is enabled or disabled. Disabled fields are rendered but cannot
  /// be edited by the user.
  ///
  /// **Supports both normal and grid fields:**
  /// - Normal fields: Pass fieldKey only
  /// - Grid fields (column in grid): Pass fieldKey and index parameter
  ///   - The fieldKey should be the column key within the grid
  ///   - The index parameter is ignored for grid columns (affects all rows)
  ///
  /// Parameters:
  /// - [fieldKey]: The key of the field to update
  ///   - For normal fields: the field's key
  ///   - For grid columns: the column's key (not the grid's key)
  /// - [isEnabled]: true to enable the field, false to disable it
  /// - [index]: Optional parameter (currently ignored, reserved for future use)
  ///
  /// Examples:
  /// ```dart
  /// // Disable a normal field
  /// dynamicFormKey.currentState?.setFieldEnabled('insuranceCompany', false);
  ///
  /// // Enable a normal field
  /// dynamicFormKey.currentState?.setFieldEnabled('insuranceCompany', true);
  ///
  /// // Disable a grid column (affects all rows in that column)
  /// dynamicFormKey.currentState?.setFieldEnabled('customerRimGrid', false);
  ///
  /// // Enable a grid column
  /// dynamicFormKey.currentState?.setFieldEnabled('customerRimGrid', true);
  /// ```
  void setFieldEnabled(String fieldKey, bool isEnabled, {int? index}) {
    bool fieldFound = false;

    // Search through all sections, rows, and fields
    for (Section section in widget.sections) {
      for (RowElement row in section.rows ?? []) {
        for (DynamicField field in row.fields ?? []) {
          // Check if this is a direct field match
          if (field.key == fieldKey) {
            field.isDisable = !isEnabled;
            fieldFound = true;
            setState(() {});
            return;
          }

          // Check if this is a grid field and search within its columns
          if (field.controlType == FieldType.grid ||
              field.controlType == FieldType.table) {
            if (field.columnInfoList != null) {
              for (var gridColumn in field.columnInfoList!) {
                if (gridColumn.dynamicField.key == fieldKey) {
                  gridColumn.dynamicField.isDisable = !isEnabled;
                  fieldFound = true;
                  setState(() {});
                  return;
                }
              }
            }
          }
        }
      }
    }

    if (!fieldFound) {
      debugPrint(
          'setFieldEnabled: Field with key "$fieldKey" not found in form');
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
    for (Section section in widget.sections) {
      if (section.rows == null) continue;
      for (RowElement row in section.rows!) {
        if (row.fields == null) continue;
        for (DynamicField field in row.fields!) {
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
          // Clear the selection using updateFieldValue to ensure proper state sync
          // This will update both the document and trigger a rebuild
          updateFieldValue(fieldKey, null, triggerDependencies: false);
          return; // updateFieldValue already calls setState
        }
      }
    }

    // Rebuild to reflect changes
    setState(() {});
  }

  /// Prefill a dropdown with a single default Option and mark it selected.
  /// - Ensures the field is a dropdown-type.
  /// - Optionally inserts the option into the field's optionList if missing.
  /// - Uses updateFieldValue to sync document (so DynamicFormDropdown picks it up).
  void setDropdownDefaultSelection(
    String fieldKey,
    Option defaultOption, {
    bool forceOverwrite =
        false, // true -> always set default, even if current is valid
    bool insertIfMissing =
        true, // true -> add defaultOption to optionList if not present
    bool onlyIfDocumentEmpty =
        false, // true -> only set if document[fieldKey] is null
  }) {
    // 1) Locate target field
    DynamicField? targetField;
    for (Section section in widget.sections) {
      if (section.rows == null) continue;
      for (RowElement row in section.rows!) {
        if (row.fields == null) continue;
        for (DynamicField field in row.fields!) {
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

    // 2) Validate dropdown-type controls
    final isDropdownField = targetField.controlType == FieldType.dropdown ||
        targetField.controlType == FieldType.conditionaldropdown ||
        targetField.controlType == FieldType.refDataDropdown ||
        targetField.controlType == FieldType.countryDropdown;

    if (!isDropdownField) {
      // Not a dropdown field
      return;
    }

    // 3) Ensure optionList exists
    targetField.optionList ??= <Option>[];

    // 4) Check if the option exists in the list; add if requested
    final hasDefaultInList =
        targetField.optionList!.any((o) => o.key == defaultOption.key);

    if (!hasDefaultInList && insertIfMissing) {
      targetField.optionList!.add(defaultOption);
    }

    // 5) Current document state
    final currentValue = widget.document[fieldKey];
    final currentKey = currentValue?.toString();

    // Is current selection valid under the field's options?
    final isCurrentValid = currentKey != null &&
        targetField.optionList!.any((o) => o.key == currentKey);

    // 6) Selection rules:
    // - If onlyIfDocumentEmpty == true, set default only when document has no value.
    // - If forceOverwrite == true, set default regardless of current validity.
    // - Else if current selection is invalid or null, set default.
    // - Otherwise, keep current selection.

    final shouldSetDefault = (onlyIfDocumentEmpty && currentKey == null) ||
        (forceOverwrite) ||
        (!isCurrentValid);

    if (shouldSetDefault) {
      // Use updateFieldValue to ensure proper state synchronization
      updateFieldValue(fieldKey, defaultOption.key, triggerDependencies: false);
      return; // updateFieldValue already calls setState
    }

    // If we keep current selection, still rebuild to reflect any option insertion
    setState(() {});
  }

  void clearDropdownSelection(
    String fieldKey,
  ) {
    // Find the field in sections
    DynamicField? targetField;
    for (Section section in widget.sections) {
      if (section.rows == null) continue;
      for (RowElement row in section.rows!) {
        if (row.fields == null) continue;
        for (DynamicField field in row.fields!) {
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

    final currentValue = widget.document[fieldKey];
    if (currentValue != null) {
      updateFieldValue(fieldKey, null, triggerDependencies: false);
      return; // updateFieldValue already calls setState
    }

    // Rebuild to reflect changes
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return BoxLayout(
      child: Form(
        key: _internalFormKey,
        child: ListView.builder(
          // separatorBuilder: (context, index) => const Gap(size: GapSize.medium),
          shrinkWrap: true,
          itemCount: widget.sections.length,
          itemBuilder: (context, index) {
            final section = widget.sections[index];
            final hasOutlineClass = section.type?.toLowerCase() == 'outline';

            final sectionContent = section.rows != null
                ? ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: section.rows!.length,
                    itemBuilder: (context, rowIndex) {
                      if (section.rows![rowIndex].fields == null) {
                        return const SizedBox.shrink();
                      }
                      DynamicField sizedDynamicField = DynamicField(
                          controlType: FieldType.sizedBox,
                          key: '',
                          label: '',
                          required: false,
                          rowData: 3,
                          enabledDefault: false,
                          isDisable: false);
                      bool containsGrid = (section.rows![rowIndex].fields ?? [])
                          .any((e) =>
                              e.controlType == FieldType.grid ||
                              e.controlType == FieldType.table);
                      if (!containsGrid &&
                          (section.rows![rowIndex].fields ?? []).length == 1) {
                        (section.rows![rowIndex].fields ?? [])
                            .add(sizedDynamicField);
                        (section.rows![rowIndex].fields ?? [])
                            .add(sizedDynamicField);
                      }
                      if (!containsGrid &&
                          (section.rows![rowIndex].fields ?? []).length == 2) {
                        (section.rows![rowIndex].fields ?? [])
                            .add(sizedDynamicField);
                      }
                      return Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: List.generate(
                          (section.rows![rowIndex].fields ?? []).length,
                          (fieldIndex) {
                            return Expanded(
                                child: Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: AppStyle.spacing,
                                vertical: AppStyle.spacingSmall,
                              ),
                              child: DynamicFormField(
                                field:
                                    section.rows![rowIndex].fields![fieldIndex],
                                document: widget.document,
                                onFieldChange: widget.onFieldChange,
                                controller: _controllers[section
                                    .rows![rowIndex].fields![fieldIndex].key],
                                onControllerCreated: (key, controller) {
                                  // Register grid controllers in DynamicForm's _controllers map
                                  _controllers[key] = controller;
                                },
                              ),
                            ));
                          },
                        ),
                      );
                    },
                  )
                : const SizedBox.shrink();

            // Wrap in Container with grey background if sectionClass is "outline"
            if (hasOutlineClass) {
              return BoxLayout(
                child: sectionContent,
              );
            }

            return sectionContent;
          },
        ),
      ),
    );
  }
}
