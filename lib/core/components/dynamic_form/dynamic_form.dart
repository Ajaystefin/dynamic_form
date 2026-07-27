import "package:easy_localization/easy_localization.dart";
import "package:flutter/material.dart";
import "package:wcas_frontend/core/components/box_layout.dart";
import "package:wcas_frontend/core/components/dynamic_form/field.dart";
import "package:wcas_frontend/core/components/dynamic_form/models/field.dart";
import "package:wcas_frontend/core/components/dynamic_form/models/row_element.dart";
import "package:wcas_frontend/core/components/dynamic_form/models/section.dart";
import "package:wcas_frontend/core/constants/constants.dart";
import "package:wcas_frontend/core/utils/form_access_provider.dart";
import "package:wcas_frontend/core/utils/logger.dart";

/// Dynamic form widget that renders sections and fields from configuration.
class DynamicForm extends StatefulWidget {
  /// Creates a [DynamicForm].
  const DynamicForm({
    required this.sections,
    required this.document,
    super.key,
    this.onFieldChange,
    this.disableAllExceptCMOUpdate = false,
    this.readOnly = false,
  });

  /// Form sections.
  final List<Section> sections;

  /// Form document values.
  final Map<String, dynamic> document;

  /// Field change callback.
  final void Function(String fieldKey, Object? value)? onFieldChange;

  /// When true, all fields will be disabled except fields where
  /// [DynamicField.isCMOUpdate] is true.
  final bool disableAllExceptCMOUpdate;

  /// When true, the entire form is read-only — all fields are disabled
  /// regardless
  /// of [disableAllExceptCMOUpdate] or [DynamicField.isCMOUpdate].
  /// Takes priority over [disableAllExceptCMOUpdate].
  final bool readOnly;

  @override
  State<DynamicForm> createState() => DynamicFormState();
}

/// State for [DynamicForm].
class DynamicFormState extends State<DynamicForm> {
  final GlobalKey<FormState> _internalFormKey = GlobalKey<FormState>();

  // Centralized controller management for text-based fields
  final Map<String, TextEditingController> _controllers = {};

  // Track disabled state for individual grid cells (using flattened keys:
  // fieldKey@index)
  final Set<String> _disabledGridCells = {};

  // Track enabled state for individual grid cells (to override JSON isDisabled:
  // true)
  final Set<String> _enabledGridCells = {};

  @override
  void initState() {
    super.initState();
    _initializeDefaultValues();
    _initializeControllers();
  }

  @override
  void dispose() {
    // Dispose all controllers
    for (final controller in _controllers.values) {
      controller.dispose();
    }
    _controllers.clear();
    super.dispose();
  }

  /// Initialize controllers for text-based fields
  void _initializeControllers() {
    for (final Section section in widget.sections) {
      for (final RowElement row in section.rows ?? []) {
        for (final DynamicField field in row.fields ?? []) {
          if (_needsController(field.controlType)) {
            final initialValue = widget.document[field.key];
            String textValue = "";
            // Handle different value types
            if (initialValue != null) {
              if (field.controlType == FieldType.currency &&
                  initialValue is Map) {
                final formatter = NumberFormat("#,###");
                // For currency fields, extract the numeric value

                textValue = initialValue["fromVal"] != null
                    ? formatter.format(initialValue["fromVal"])
                    : "";
              } else {
                textValue = initialValue.toString();
              }
            }

            _controllers[field.key] = TextEditingController(text: textValue);
          }
          // else{

          //    logger.i("found controller for ${field.key} ");
          //   final initialValue = widget.document[field.key];
          //   String textValue = '';

          //   logger.i("initial value found ${initialValue}");

          //   // Handle different value types
          //   if (initialValue != null) {
          //     if (field.controlType == FieldType.currency &&
          //         initialValue is Map) {
          //           final formatter = NumberFormat('#,###');

          //       // For currency fields, extract the numeric value
          //       textValue = initialValue['fromVal']!=null?
          // formatter.format(initialValue['fromVal']?.toString()) : '';
          //     } else if(field.controlType == FieldType.conditionaldropdown &&
          // initialValue is Map) {
          //       logger.i("inside els if for conditionla dropdown field
          // ${field.key}");
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

  /// Initializes document with defaultValue from field configurations
  /// Only sets defaults for fields that don't already have a value
  void _initializeDefaultValues() {
    for (final Section section in widget.sections) {
      for (final RowElement row in section.rows ?? []) {
        for (final DynamicField field in row.fields ?? []) {
          // Only set default if:
          // 1. Field has a defaultValue in JSON (getDynamicForm API)
          // 2. Document doesn't already have a value for this key
          if (field.defaultValue != null &&
              field.defaultValue!.isNotEmpty &&
              !widget.document.containsKey(field.key)) {
            // Handle different field types appropriately
            switch (field.controlType) {
              case FieldType.singleCheckBox:
                // Parse boolean from string
                widget.document[field.key] =
                    field.defaultValue!.toLowerCase() == "true";

              case FieldType.percentage:
              case FieldType.textField:
              case FieldType.accountNo:
              case FieldType.amount:
              case FieldType.textArea:
                // Store as string
                widget.document[field.key] = field.defaultValue;

              // Add other field types as needed
              default:
                // For unknown types, store as-is
                widget.document[field.key] = field.defaultValue;
            }
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
  /// **Supports both normal and grid fields:**
  /// - Normal fields: Pass the value directly
  /// - Grid fields: Pass a map with `{value: actualValue, index: rowIndex}`
  ///
  /// Parameters:
  /// - [fieldKey]: The key of the field to update (without @index for grid
  /// fields)
  /// - [value]: The new value to set. For grid fields, use `{value:
  /// actualValue, index: rowIndex}`
  /// - [triggerDependencies]: Whether to trigger dependent field updates
  /// (deprecated)
  ///
  /// Examples:
  /// ```dart
  /// // Normal field
  /// dynamicFormKey.currentState?.updateFieldValue('policyNumber', 'POL123');
  ///
  /// // Grid field
  /// dynamicFormKey.currentState?.updateFieldValue('customerName', {value:
  /// 'John', index: 0});
  /// ```
  void updateFieldValue(
    String fieldKey,
    Object? value, {
    bool triggerDependencies = true,
  }) {
    // Check if this is a grid field update (value is a map with 'index' key)
    String actualKey = fieldKey;
    dynamic actualValue = value;

    if (value is Map && value.containsKey("index")) {
      // Grid field: construct flattened key
      final rowIndex = value["index"];
      actualKey = "$fieldKey@$rowIndex";
      actualValue = value["value"];
    }

    // Special handling for currency fields: support partial updates
    // If the new value is a currency map with null values, merge with existing
    if (actualValue is Map && actualValue.containsKey("fromCurrency")) {
      final existingValue = widget.document[actualKey];
      if (existingValue is Map) {
        // Check if currency is changing
        final currencyChanging = actualValue["fromCurrency"] != null &&
            actualValue["fromCurrency"] != existingValue["fromCurrency"];

        // Merge: use new values if not null, otherwise keep existing
        actualValue = <String, dynamic>{
          "fromCurrency":
              actualValue["fromCurrency"] ?? existingValue["fromCurrency"],
          "fromVal": actualValue["fromVal"] ?? existingValue["fromVal"],
          // Don't preserve aedEquivalent if:
          // 1. Currency is changing (needs recalculation for new currency)
          // 2. Caller explicitly passed aedEquivalent: null (force
          // recalculation)
          // Use containsKey to distinguish explicit null from omitted key
          "aedEquivalent": currencyChanging
              ? null
              : actualValue.containsKey("aedEquivalent")
                  ? actualValue[
                      "aedEquivalent"] // Honour explicit value (even null)
                  : existingValue[
                      "aedEquivalent"], // Key omitted → preserve existing
        };
      }
    }

    // Update document map
    widget.document[actualKey] = actualValue;

    // Update controller if this field has one
    if (_controllers.containsKey(actualKey)) {
      // For currency fields: normally they manage their own controller
      // formatting
      // via didUpdateWidget. However, when fromVal is explicitly provided
      // (non-null)
      // we must sync the controller NOW — before any async getCurrencyRates
      // callback
      // fires — so that the callback reads the correct amount from the
      // controller.
      final isCurrencyField =
          actualValue is Map && actualValue.containsKey("fromCurrency");

      if (isCurrencyField) {
        final dynamic fromVal = actualValue["fromVal"];
        if (fromVal != null) {
          // Format the numeric value with thousand-separator formatting
          final formatter = NumberFormat("#,###");
          final String formattedVal = formatter.format(fromVal);
          if (_controllers[actualKey]!.text != formattedVal) {
            _controllers[actualKey]!.text = formattedVal;
          }
        }
      } else {
        String textValue = "";

        // Handle different value types
        if (actualValue != null) {
          textValue = actualValue.toString();
        }

        // Only update if different to avoid cursor jumping
        if (_controllers[actualKey]!.text != textValue) {
          _controllers[actualKey]!.text = textValue;
        }
      }
    }
    logger
      ..i("update doc hash:${widget.document.hashCode}")
      ..i("set:$actualKey= $actualValue");

    // Rebuild to reflect changes
    setState(() {});
  }

  /// Shows or hides a field based on conditional logic
  ///
  /// This method updates the field's `showField` property to control
  /// visibility.
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
  /// dynamicFormKey.currentState?.setFieldVisibility('insuranceCompany',
  /// false);
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
  void setFieldVisibility(
    String fieldKey, {
    required bool isVisible,
    int? index,
  }) {
    bool fieldFound = false;
    logger.i("field check of the key $fieldKey");

    // Search through all sections, rows, and fields
    for (final Section section in widget.sections) {
      for (final RowElement row in section.rows ?? []) {
        for (final DynamicField field in row.fields ?? []) {
          // Check if this is a direct field match
          if (field.key == fieldKey) {
            field.showField = isVisible;
            fieldFound = true;
            setState(() {});
            return;
          }

          logger.i("field check ${field.controlType} of the key $fieldKey");

          // Check if this is a grid field and search within its columns
          if (field.controlType == FieldType.grid ||
              field.controlType == FieldType.table) {
            if (field.columnInfoList != null) {
              for (final gridColumn in field.columnInfoList!) {
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
      logger.i(
        'setFieldVisibility: Field with key "$fieldKey" not found in form',
      );
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
  /// - [isMandatory]: true to make the field mandatory, false to make it
  /// optional
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
  void setFieldMandatory(
    String fieldKey, {
    required bool isMandatory,
    int? index,
  }) {
    bool fieldFound = false;

    // Search through all sections, rows, and fields
    for (final Section section in widget.sections) {
      for (final RowElement row in section.rows ?? []) {
        for (final DynamicField field in row.fields ?? []) {
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
              for (final gridColumn in field.columnInfoList!) {
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
      logger.i(
        'setFieldMandatory: Field with key "$fieldKey" not found in form',
      );
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
  /// - Grid fields (specific cell): Pass fieldKey and index parameter
  ///   - The fieldKey should be the column key within the grid
  ///   - The index specifies which row's cell to enable/disable
  /// - Grid fields (entire column): Pass fieldKey without index
  ///   - Affects all rows in that column
  ///
  /// Parameters:
  /// - [fieldKey]: The key of the field to update
  ///   - For normal fields: the field's key
  ///   - For grid columns: the column's key (not the grid's key)
  /// - [isEnabled]: true to enable the field, false to disable it
  /// - [index]: Row index for grid cell-specific enablement (0-based)
  ///
  /// Examples:
  /// ```dart
  /// // Disable a normal field
  /// dynamicFormKey.currentState?.setFieldEnabled('insuranceCompany', false);
  ///
  /// // Enable a normal field
  /// dynamicFormKey.currentState?.setFieldEnabled('insuranceCompany', true);
  ///
  /// // Disable a specific grid cell (row 0 of customerRimGrid column)
  /// dynamicFormKey.currentState?.setFieldEnabled('customerRimGrid', false,
  /// index: 0);
  ///
  /// // Enable a specific grid cell
  /// dynamicFormKey.currentState?.setFieldEnabled('customerRimGrid', true,
  /// index: 0);
  ///
  /// // Disable entire grid column (affects all rows)
  /// dynamicFormKey.currentState?.setFieldEnabled('customerRimGrid', false);
  /// ```
  void setFieldEnabled(String fieldKey, {required bool isEnabled, int? index}) {
    // If index is provided, handle cell-specific enablement for grid fields
    if (index != null) {
      final String flattenedKey = "$fieldKey@$index";
      if (isEnabled) {
        // Add to enabled set (to override JSON isDisabled: true)
        _enabledGridCells.add(flattenedKey);
        _disabledGridCells.remove(flattenedKey);
      } else {
        // Add to disabled set (to override JSON isDisabled: false)
        _disabledGridCells.add(flattenedKey);
        _enabledGridCells.remove(flattenedKey);
      }
      logger.i(
        'setFieldEnabled: Grid cell "$flattenedKey" '
        '${isEnabled ? "enabled" : "disabled"}',
      );
      setState(() {});
      return;
    }

    // Handle normal field or entire grid column enablement
    bool fieldFound = false;

    // Search through all sections, rows, and fields
    for (final Section section in widget.sections) {
      for (final RowElement row in section.rows ?? []) {
        for (final DynamicField field in row.fields ?? []) {
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
              for (final gridColumn in field.columnInfoList!) {
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
      logger.i(
        'setFieldEnabled: Field with key "$fieldKey" not found in form',
      );
    }
  }

  /// Checks if a specific grid cell is disabled
  ///
  /// Returns true if the cell at the specified row index is disabled.
  /// This is used internally by grid widgets to determine cell state.
  ///
  /// Parameters:
  /// - [fieldKey]: The column key within the grid
  /// - [index]: The row index (0-based)
  bool isGridCellDisabled(String fieldKey, int index) {
    return _disabledGridCells.contains("$fieldKey@$index");
  }

  /// Returns a copy of the disabled grid cells Set
  ///
  /// This is used to pass the disabled state to child grid widgets.
  Set<String> get disabledGridCells => Set<String>.from(_disabledGridCells);

  /// Returns a copy of the enabled grid cells Set
  ///
  /// This is used to pass the enabled state (override for JSON isDisabled:
  /// true) to child grid widgets.
  Set<String> get enabledGridCells => Set<String>.from(_enabledGridCells);

  /// Updates multiple field values at once
  ///
  /// This is more efficient than calling updateFieldValue multiple times
  /// as it only triggers a single rebuild and dependency calculation pass.
  ///
  /// Parameters:
  ///   - updates: Map of field keys to their new values
  ///   - triggerDependencies: Whether to recalculate dependent fields (default:
  /// true)
  ///
  /// Example:
  /// ```dart
  /// dynamicFormKey.currentState?.updateFields({
  ///   'policyNumber': '12345',
  ///   'premiumAmount': {'fromCurrency': 'AED', 'fromVal': 50, 'aedEquivalent':
  /// 50},
  ///   'mortgagedInFavourOfCBD': true,
  /// });
  /// ```
  void updateFields(
    Map<String, dynamic> updates, {
    bool triggerDependencies = true,
  }) {
    // Update all fields
    for (final entry in updates.entries) {
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
  /// Returns the value from the document map, or null if the field doesn't
  /// exist.
  ///
  /// Example:
  /// ```dart
  /// final premiumAmount =
  /// dynamicFormKey.currentState?.getFieldValue('premiumAmount');
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
  ///   - clearSelection: Whether to clear the current selection if it's not in
  /// the new options (default: false)
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
    for (final Section section in widget.sections) {
      if (section.rows == null) {
        continue;
      }
      for (final RowElement row in section.rows!) {
        if (row.fields == null) {
          continue;
        }
        for (final DynamicField field in row.fields!) {
          if (field.key == fieldKey) {
            targetField = field;
            break;
          }
        }
        if (targetField != null) {
          break;
        }
      }
      if (targetField != null) {
        break;
      }
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
          // Clear the selection using updateFieldValue to ensure proper state
          // sync
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
  /// - Uses updateFieldValue to sync document (so DynamicFormDropdown picks it
  /// up).
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
    for (final Section section in widget.sections) {
      if (section.rows == null) {
        continue;
      }
      for (final RowElement row in section.rows!) {
        if (row.fields == null) {
          continue;
        }
        for (final DynamicField field in row.fields!) {
          if (field.key == fieldKey) {
            targetField = field;
            break;
          }
        }
        if (targetField != null) {
          break;
        }
      }
      if (targetField != null) {
        break;
      }
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
    // - If onlyIfDocumentEmpty ?? false, set default only when document has no
    // value.
    // - If forceOverwrite ?? false, set default regardless of current validity.
    // - Else if current selection is invalid or null, set default.
    // - Otherwise, keep current selection.

    final shouldSetDefault = (onlyIfDocumentEmpty && currentKey == null) ||
        forceOverwrite ||
        (!isCurrentValid);

    if (shouldSetDefault) {
      // Use updateFieldValue to ensure proper state synchronization
      updateFieldValue(fieldKey, defaultOption.key, triggerDependencies: false);
      return; // updateFieldValue already calls setState
    }

    // If we keep current selection, still rebuild to reflect any option
    // insertion
    setState(() {});
  }

  /// Clears the selected dropdown value.
  void clearDropdownSelection(
    String fieldKey,
  ) {
    // Find the field in sections
    DynamicField? targetField;
    for (final Section section in widget.sections) {
      if (section.rows == null) {
        continue;
      }
      for (final RowElement row in section.rows!) {
        if (row.fields == null) {
          continue;
        }
        for (final DynamicField field in row.fields!) {
          if (field.key == fieldKey) {
            targetField = field;
            break;
          }
        }
        if (targetField != null) {
          break;
        }
      }
      if (targetField != null) {
        break;
      }
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
          // separatorBuilder: (context, index) => const Gap(size:
          // GapSize.medium),
          shrinkWrap: true,
          itemCount: widget.sections.length,
          itemBuilder: (context, index) {
            final section = widget.sections[index];
            final hasOutlineClass = section.type?.toLowerCase() == "outline";

            final sectionContent = section.rows != null
                ? ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: section.rows!.length,
                    itemBuilder: (context, rowIndex) {
                      if (section.rows![rowIndex].fields == null) {
                        return const SizedBox.shrink();
                      }
                      final DynamicField sizedDynamicField = DynamicField(
                        controlType: FieldType.sizedBox,
                        key: "",
                        label: "",
                        required: false,
                        rowData: 3,
                        enabledDefault: false,
                        isDisable: false,
                      );
                      final bool containsGrid =
                          (section.rows![rowIndex].fields ?? []).any(
                        (e) =>
                            e.controlType == FieldType.grid ||
                            e.controlType == FieldType.table,
                      );
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
                            final field =
                                section.rows![rowIndex].fields![fieldIndex];
                            // Disable the field if:
                            // 1. The whole form is read-only (readOnly takes
                            // priority), OR
                            // 2. CMO-update mode is active and this field is
                            // not a CMO-updatable field
                            final bool isForceDisabled = widget.readOnly ||
                                (widget.disableAllExceptCMOUpdate &&
                                    !field.isCMOUpdate);

                            return Expanded(
                              child: Padding(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: AppStyle.spacing,
                                  vertical: AppStyle.spacingSmall,
                                ),
                                child: FormAccessProvider(
                                  disabled: isForceDisabled,
                                  child: DynamicFormField(
                                    field: field,
                                    document: widget.document,
                                    onFieldChange: widget.onFieldChange,
                                    controller: _controllers[field.key],
                                    onControllerCreated: (key, controller) {
                                      // Register grid controllers in
                                      // DynamicForm's _controllers map
                                      _controllers[key] = controller;
                                    },
                                    disabledCells: _disabledGridCells,
                                    enabledCells: _enabledGridCells,
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
                      );
                    },
                  )
                : const SizedBox.shrink();

            // Wrap in Container with grey background if sectionClass is
            // "outline"
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
