import "package:flutter/material.dart";
import "package:flutter/services.dart";
import "package:wcas_frontend/core/components/custom_table/table.dart";
import "package:wcas_frontend/core/components/datepicker.dart";
import "package:wcas_frontend/core/components/dropdown/dropdown.dart";
import "package:wcas_frontend/core/components/dropdown/multi_select_dropdown.dart";
import "package:wcas_frontend/core/components/dynamic_form/fields/currency_dropdown.dart";
import "package:wcas_frontend/core/components/dynamic_form/fields/dropdown.dart";
import "package:wcas_frontend/core/components/dynamic_form/fields/dropdown_textfield.dart";
import "package:wcas_frontend/core/components/dynamic_form/fields/reference_data_dropdown.dart";
import "package:wcas_frontend/core/components/dynamic_form/fields/single_check_box.dart";
import "package:wcas_frontend/core/components/dynamic_form/models/field.dart";
import "package:wcas_frontend/core/components/dynamic_form/models/grid_field.dart";
import "package:wcas_frontend/core/components/dynamic_form/utils/date_utils.dart";
import "package:wcas_frontend/core/components/gap.dart";
import "package:wcas_frontend/core/components/textfield.dart";
import "package:wcas_frontend/core/constants/constants.dart";
import "package:wcas_frontend/core/globals.dart";

class DynamicFormGrid extends StatefulWidget {
  const DynamicFormGrid({
    required this.fieldData,
    required this.document,
    super.key,
    this.isTable = false,
    this.onFieldChange,
    this.onControllerCreated,
    this.disabledCells,
    this.enabledCells,
  });
  final bool isTable;
  final DynamicField fieldData;
  final Map<String, dynamic> document;
  final void Function(String fieldKey, dynamic value)? onFieldChange;
  final void Function(String key, TextEditingController controller)?
      onControllerCreated;
  final Set<String>? disabledCells;
  final Set<String>? enabledCells;

  @override
  State<DynamicFormGrid> createState() => _DynamicFormGridState();
}

class _DynamicFormGridState extends State<DynamicFormGrid> {
  /// Map of text editing controllers for grid fields
  /// Key format: "{fieldKey}@{rowIndex}"
  final Map<String, TextEditingController> controllers = {};

  /// List of widget rows for the grid table
  List<List<Widget>> rows = [];

  /// Track number of rows (persists across rebuilds)
  int _rowCount = 1;

  /// Track when field properties change to force table rebuild
  /// This increments only when didUpdateWidget is called, not on every setState
  int _fieldPropertiesVersion = 0;

  /// Last computed hash of field properties to detect changes
  int _lastFieldPropertiesHash = 0;

  @override
  void initState() {
    super.initState();
    // Initialize row count from existing data in document
    _rowCount = _countExistingRowsInDocument();
    if (_rowCount == 0) {
      _rowCount = 1; // Start with at least one row if no data exists
    }
    rows = _buildRows(); // Build initial rows
    _lastFieldPropertiesHash = _computeFieldPropertiesHash(); // Initialize hash
  }

  /// Counts how many rows of data exist in the document for this grid
  int _countExistingRowsInDocument() {
    final String gridKey = widget.fieldData.key;
    final List<DynamicGridField> columns =
        widget.fieldData.columnInfoList ?? [];

    if (columns.isEmpty) return 0;

    // Get the first column key to check for row indices
    final String firstColumnKey = columns.first.dynamicField.key;

    // Count how many rows exist by finding the highest row index
    int maxRowIndex = -1;

    widget.document.forEach((key, value) {
      // Check if this key belongs to our grid and matches the pattern:
      // gridKey.columnKey@rowIndex
      if (key.startsWith("$gridKey.$firstColumnKey@")) {
        final parts = key.split("@");
        if (parts.length == 2) {
          final rowIndex = int.tryParse(parts[1]);
          if (rowIndex != null && rowIndex > maxRowIndex) {
            maxRowIndex = rowIndex;
          }
        }
      }
    });

    // Return count (maxRowIndex + 1 since indices are 0-based)
    // If maxRowIndex is -1 (no data found), return 0
    return maxRowIndex >= 0 ? maxRowIndex + 1 : 0;
  }

  @override
  void didUpdateWidget(DynamicFormGrid oldWidget) {
    super.didUpdateWidget(oldWidget);

    // Compute hash of current field properties
    final currentHash = _computeFieldPropertiesHash();

    // Check if hash changed (meaning field properties changed)
    if (_lastFieldPropertiesHash != currentHash) {
      _lastFieldPropertiesHash = currentHash;
      _fieldPropertiesVersion++;
      rows = _buildRows();
    }
  }

  /// Compute a hash of all field properties to detect changes
  int _computeFieldPropertiesHash() {
    final List<DynamicGridField> columns =
        widget.fieldData.columnInfoList ?? [];
    int hash = 0;

    for (int i = 0; i < columns.length; i++) {
      final DynamicField field = columns[i].dynamicField;
      // Combine field properties into hash
      hash = hash ^ field.isDisable.hashCode;
      hash = hash ^ field.isMandatory.hashCode;
      hash = hash ^ field.showField.hashCode;
      hash = hash ^ i; // Include index to differentiate columns
    }

    // Include disabledCells contents hash to trigger rebuild when cell disabled
    // state changes
    // We iterate over the Set contents because Set.hashCode is identity-based,
    // not content-based
    if (widget.disabledCells != null) {
      for (final String key in widget.disabledCells!) {
        // Use multiplier 1 for disabled cells
        hash = hash ^ (key.hashCode * 1);
      }
      // Also include length to detect additions/removals
      hash = hash ^ widget.disabledCells!.length;
    }

    // Include enabledCells contents hash to trigger rebuild when cell enabled
    // state changes
    // Use different multiplier (37) to distinguish from disabledCells
    // This ensures that moving a key between sets changes the hash
    if (widget.enabledCells != null) {
      for (final String key in widget.enabledCells!) {
        // Use multiplier 37 for enabled cells to distinguish from disabled
        hash = hash ^ (key.hashCode * 37);
      }
      // Also include length to detect additions/removals
      hash = hash ^ (widget.enabledCells!.length * 37);
    }

    return hash;
  }

  /// Builds rows for the current row count
  List<List<Widget>> _buildRows() {
    final List<DynamicGridField> dynamicFormGridFields =
        widget.fieldData.columnInfoList ?? [];

    return List.generate(_rowCount, (int rowIndex) {
      final List<Widget> rowWidgets = [
        for (int i = 0; i < dynamicFormGridFields.length; i++)
          buildGridCellWidget(
            dynamicFormGridFields[i].dynamicField,
            i,
            rowIndex,
            false, // Load from document
          ),
      ];

      // Only add delete button for grid types, not table types
      if (!widget.isTable) {
        rowWidgets.add(
          Visibility(
            visible: rowIndex != 0,
            child: deleteFunction(), // Add delete button
          ),
        );
      }

      return rowWidgets;
    });
  }

  @override
  Widget build(BuildContext context) {
    // Don't rebuild rows here - only rebuild when row count changes (in
    // didUpdateWidget)
    // This preserves text field focus

    return SingleChildScrollView(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text.rich(
                TextSpan(
                  text: widget.fieldData.label,
                  children: [
                    if (widget.fieldData.isRequired)
                      const TextSpan(
                        text: " *",
                        style: TextStyle(
                          color: AppColors.failure,
                          fontFeatures: [FontFeature.enable("sups")],
                        ),
                      ),
                    if (widget.fieldData.isCMOUpdate)
                      const TextSpan(
                        text: " #",
                        style: TextStyle(
                          fontSize: 9,
                          fontFeatures: [
                            FontFeature.superscripts(),
                            FontFeature.enable("sups"),
                          ],
                        ),
                      ),
                  ],
                  style: AppStyle.boldLabel,
                ),
              ),
              const Gap(
                direction: Axis.horizontal,
              ),
              if (!widget.isTable)
                IconButton(
                  onPressed: addGridRow,
                  icon: const Icon(Icons.add),
                ),
            ],
          ),
          buildTable(columns: getTableColumns()),
        ],
      ),
    );
  }

  /// Builds the initial grid rows from field configuration
  ///
  /// Returns a list of widget rows, each containing cells for the configured
  /// columns.
  /// The first row (index 0) is created with isNewRow=false to load existing
  /// data.
  List<List<Widget>> buildInitialGridRows() {
    final List<DynamicGridField> dynamicFormGridFields =
        (widget.fieldData.columnInfoList ?? []);
    return [
      [
        for (int i = 0; i < dynamicFormGridFields.length; i++) ...[
          buildGridCellWidget(
            dynamicFormGridFields[i].dynamicField,
            i,
            0,
            false,
          ), // rowIndex=0
        ],
        const SizedBox(),
      ]
    ];
  }

  Widget buildTable({
    required List<TableColumn> columns,
  }) {
    return CustomRawTable(
      rowHeight: 90,
      key: ValueKey(
        "grid_${_rowCount}_$_fieldPropertiesVersion",
      ), // Stable key that changes only when needed
      columns: columns,
      autoFitWidth: false,
      rows: rows,
    );
  }

  /// Deletes the last row from the grid
  void deleteGridRow() {
    if (_rowCount > 1) {
      setState(() {
        _rowCount--;
        rows = _buildRows(); // Rebuild rows with new count
      });
    }
  }

  /// Adds a new row to the grid
  void addGridRow() {
    setState(() {
      _rowCount++;
      rows = _buildRows(); // Rebuild rows with new count
    });
  }

  List<TableColumn> getTableColumns() {
    final List<TableColumn> columns = [];
    for (final DynamicGridField element
        in widget.fieldData.columnInfoList ?? []) {
      columns.add(
        TableColumn(
          // forcedWidth: 50.w,

          width: _getColumnWidth(element.dynamicField.controlType),

          label: RichText(
            text: TextSpan(
              children: [
                TextSpan(
                  text: element.dynamicField.label,
                ),
                if (element.dynamicField.isRequired)
                  const TextSpan(
                    text: " *",
                    style: TextStyle(
                      color: AppColors.failure,
                      fontFeatures: [FontFeature.enable("sups")],
                    ),
                  ),
              ],
            ),
          ),
        ),
      );
    }
    // Only add delete button column for grid types, not table types
    if (!widget.isTable) {
      return [
        ...columns,
        const TableColumn(forcedWidth: 50, label: SizedBox()),
      ];
    }
    return columns;
  }

  double _getColumnWidth(FieldType type) {
    switch (type) {
      case FieldType.singleCheckBox:
        return 150;
      case FieldType.amount:
      case FieldType.currency:
        return 240;
      case FieldType.datePicker:
      case FieldType.dropdown:
      case FieldType.editableDropdown:
      case FieldType.multiSelect:
      case FieldType.customerSearch:
      case FieldType.accountNo:
      case FieldType.refDataDropdown:
        return 280;
      case FieldType.textField:
      case FieldType.percentage:
      default:
        return 180;
    }
  }

  /// Builds the delete button widget for a grid row
  Widget deleteFunction() {
    return IconButton(
      onPressed: deleteGridRow,
      icon: const Icon(Icons.delete),
    );
  }

  /// Builds a widget for a single grid cell
  ///
  /// This method creates the appropriate widget based on the field's
  /// controlType.
  /// All field values are stored in the document map using the flattened key
  /// format:
  /// "{fieldKey}@{rowIndex}"
  ///
  /// Parameters:
  /// - [dynamicField]: Field configuration from the API
  /// - [colIndex]: Column index in the grid
  /// - [rowIndex]: Row index in the grid
  /// - [isNewRow]: Whether this is a newly added row (starts empty)
  Widget buildGridCellWidget(
    DynamicField dynamicField,
    int colIndex,
    int rowIndex,
    bool isNewRow,
  ) {
    late Widget returnWidget;

    // Construct the grid-qualified key for this grid cell
    // Format: gridName.fieldKey@rowIndex (e.g.,
    // "listofApprovedBeneficiaries.customerRimGrid@0")
    // This ensures unique keys when the same field name exists in multiple
    // grids
    final String controllerKey =
        "${widget.fieldData.key}.${dynamicField.key}@$rowIndex";

    // Determine if this cell is disabled:
    // 1. If explicitly enabled (in enabledCells), cell is ENABLED (overrides
    // JSON isDisabled: true)
    // 2. If explicitly disabled (in disabledCells), cell is DISABLED (overrides
    // JSON isDisabled: false)
    // 3. Otherwise, use the JSON default (dynamicField.isDisable)
    bool isCellDisabled;
    if (widget.enabledCells?.contains(controllerKey) ?? false) {
      // Explicitly enabled via setFieldEnabled(key, true, index)
      isCellDisabled = false;
    } else if (widget.disabledCells?.contains(controllerKey) ?? false) {
      // Explicitly disabled via setFieldEnabled(key, false, index)
      isCellDisabled = true;
    } else {
      // Fall back to JSON default
      isCellDisabled = dynamicField.isDisable;
    }

    final TextEditingController controller = controllers.putIfAbsent(
      controllerKey,
      () {
        final TextEditingController newController = TextEditingController();

        // Register this controller with DynamicForm's _controllers map
        if (widget.onControllerCreated != null) {
          widget.onControllerCreated!(controllerKey, newController);
        }

        return newController;
      },
    );

    // Load initial value from document using flattened key
    final dynamic storedValue =
        isNewRow ? null : widget.document[controllerKey];

    // Handle initial value setting based on field type
    final bool isCurrencyMap = dynamicField.controlType == FieldType.currency &&
        storedValue is Map<String, dynamic>;

    if (!isCurrencyMap && storedValue != null) {
      final String initialText = storedValue.toString();
      if (controller.text != initialText) {
        controller.text = initialText;
      }
    } else if (!isCurrencyMap) {
      // Ensure controller starts blank when no stored value
      if (controller.text.isNotEmpty) {
        controller.text = "";
      }
    }

    switch (dynamicField.controlType) {
      case FieldType.textField || FieldType.accountNo:
        returnWidget = CustomTextField(
          key: ValueKey("${dynamicField.key}_${rowIndex}_$isCellDisabled"),
          controller: controller,
          hintText: dynamicField.defaultValue,
          maxLength: dynamicField.maxLength,
          errorText: dynamicField.message,
          readOnly: isCellDisabled,
          filled: isCellDisabled,
          counterText: "",
          onSaved: (value) {
            widget.document[controllerKey] = value;
          },
          onChanged: (value) {
            widget.document[controllerKey] = value;

            // Trigger onFieldChange callback for parent ViewModel
            if (widget.onFieldChange != null) {
              widget.onFieldChange!(dynamicField.key, {
                "gridName": widget.fieldData.key,
                "index": rowIndex,
                "value": value,
              });
            }
          },
        );

      case FieldType.customerSearch:
        returnWidget = CustomTextField(
          key: ValueKey("${dynamicField.key}_${rowIndex}_$isCellDisabled"),
          controller: controller,
          hintText: dynamicField.defaultValue ?? "Search",
          maxLength: dynamicField.maxLength,
          // errorText: dynamicField.message,
          readOnly: isCellDisabled,
          counterText: "",
          onSaved: (value) {
            widget.document[controllerKey] = value;
          },
          onChanged: (value) {
            widget.document[controllerKey] = value;

            // Trigger onFieldChange callback for parent ViewModel
            if (widget.onFieldChange != null) {
              widget.onFieldChange!(dynamicField.key, {
                "gridName": widget.fieldData.key,
                "index": rowIndex,
                "value": value,
              });
            }
          },
        );

      case FieldType.amount:
        returnWidget = CustomTextField(
          key: ValueKey("${dynamicField.key}_${rowIndex}_$isCellDisabled"),
          controller: controller,
          hintText: dynamicField.defaultValue,
          maxLength: dynamicField.maxLength,
          errorText: dynamicField.message,
          readOnly: isCellDisabled,
          onSaved: (value) {
            widget.document[controllerKey] = value;
          },
          onChanged: (value) {
            widget.document[controllerKey] = value;

            // Trigger onFieldChange callback for parent ViewModel
            if (widget.onFieldChange != null) {
              widget.onFieldChange!(dynamicField.key, {
                "gridName": widget.fieldData.key,
                "index": rowIndex,
                "value": value,
              });
            }
          },
        );
      case FieldType.percentage:
        returnWidget = CustomTextField(
          key: ValueKey("${dynamicField.key}_${rowIndex}_$isCellDisabled"),
          controller: controller,
          inputFormatters: [
            FilteringTextInputFormatter.allow(
              RegExp(r"^\d{0,2}(\.\d{0,})?$|^100(\.0*)?$"),
            ),
            LengthLimitingTextInputFormatter(7),
          ],
          initialValue: dynamicField.defaultValue,
          // labelText: dynamicField.defaultValue,
          maxLength: dynamicField.maxLength,
          errorText: dynamicField.message,
          readOnly: isCellDisabled,
          onSaved: (value) {
            widget.document[controllerKey] = value;
          },
          onChanged: (value) {
            widget.document[controllerKey] = value;

            // Trigger onFieldChange callback for parent ViewModel
            if (widget.onFieldChange != null) {
              widget.onFieldChange!(dynamicField.key, {
                "gridName": widget.fieldData.key,
                "index": rowIndex,
                "value": value,
              });
            }
          },
        );
      case FieldType.datePicker:
        DateTime? initialDate;
        if (storedValue != null) {
          if (storedValue is String) {
            initialDate = DateTime.tryParse(storedValue);
          } else if (storedValue is DateTime) {
            initialDate = storedValue;
          } else if (storedValue is Map) {
            // Handle custom date format like {"date": {...}, "jsdate": "...",
            // "epoc": ...}
            final dynamic jsdate = storedValue["jsdate"];
            if (jsdate is String) {
              initialDate = DateTime.tryParse(jsdate);
            }
          }
        }

        returnWidget = CustomDatePicker(
          key: ValueKey("${dynamicField.key}_$rowIndex"),
          initialDateTime: initialDate,
          validator: dynamicField.isRequired
              ? (value) {
                  if (value == null || value.isEmpty) {
                    return dynamicField.message ??
                        "${dynamicField.label} is required";
                  }
                  return null;
                }
              : null,
          onSubmit2: (DateTime? selectedDate) {
            final dynamic dateValue = convertDateTimeToFormValue(selectedDate);
            widget.document[controllerKey] = dateValue;

            // Trigger onFieldChange callback for parent ViewModel
            if (widget.onFieldChange != null) {
              widget.onFieldChange!(dynamicField.key, {
                "gridName": widget.fieldData.key,
                "index": rowIndex,
                "value": dateValue,
              });
            }
          },
        );

      case FieldType.singleCheckBox:
        {
          final dynamic currentValue = widget.document[controllerKey];
          final bool boolValue = (currentValue is bool) ? currentValue : false;

          debugPrint(
            "Checkbox $controllerKey: "
            "currentValue=$currentValue, boolValue=$boolValue",
          );

          returnWidget = DynamicFormSingleCheckBox(
            fieldData: dynamicField,
            document: widget.document, // Pass document
            documentKey: controllerKey, // Pass key to read from
            value: boolValue, // Initial value
            onChanged: (value) {
              widget.document[controllerKey] = value;

              // Trigger onFieldChange callback for parent ViewModel
              if (widget.onFieldChange != null) {
                widget.onFieldChange!(dynamicField.key, {
                  "gridName": widget.fieldData.key,
                  "index": rowIndex,
                  "value": value,
                });
              }

              setState(() {});
            },
            onSaved: (value) {
              widget.document[controllerKey] = value == true;
            },
          );
          break;
        }

      case FieldType.dropdown:
        // Create a temporary document that maps the simple key format to the
        // grid-qualified value
        // This allows syncSelectedOptionFromDocument to work with grid cells
        final Map<String, dynamic> dropdownDocument = {
          "${dynamicField.key}@$rowIndex": widget.document[controllerKey],
        };

        final Option? selectedOption = syncSelectedOptionFromDocument(
          document: dropdownDocument,
          fieldData: dynamicField,
          index: rowIndex,
        );
        returnWidget = CustomDropdown<Option>(
          key: ValueKey("${dynamicField.key}_${rowIndex}_$isCellDisabled"),
          validationMessage: dynamicField.message,
          isEnabled: !isCellDisabled,
          isSearchable: true,
          items: dynamicField.optionList ?? [],
          selectedItems: [selectedOption],
          filterFn: (item, search) {
            return (item.value ?? "")
                .toLowerCase()
                .contains(search.toLowerCase());
          },
          onSelected: (value) {
            widget.document[controllerKey] = value.first.key;

            // Trigger onFieldChange callback for parent ViewModel
            if (widget.onFieldChange != null) {
              widget.onFieldChange!(dynamicField.key, {
                "gridName": widget.fieldData.key,
                "index": rowIndex,
                "value": value,
              });
            }
          },
          itemBuilder: (context, item, isDisabled, isSelected) {
            return dropdownItemBuildWidget(item.value);
          },
          dropdownBuilder: (context, data) {
            return dropdownBuilderWidget(
              text: data?.value ?? "",
              showToolTip: false,
            );
          },
        );

      case FieldType.editableDropdown:
        // Get or create controller for edit mode (similar to textField)
        final TextEditingController editController = controllers.putIfAbsent(
          "${controllerKey}_edit",
          () {
            final TextEditingController newController = TextEditingController();
            return newController;
          },
        );

        // Load initial value from document
        final dynamic storedValue =
            isNewRow ? null : widget.document[controllerKey];

        // Try to find matching option for dropdown selection
        Option? selectedOption;
        if (storedValue != null && dynamicField.optionList != null) {
          try {
            selectedOption = dynamicField.optionList!.firstWhere(
              (option) => option.key == storedValue.toString(),
              orElse: () => throw StateError("Not found"),
            );
            // Clear edit controller if value matches an option
            if (editController.text != storedValue.toString()) {
              editController.clear();
            }
          } catch (e) {
            // No matching option found, treat as custom text
            selectedOption = null;
            if (editController.text != storedValue.toString()) {
              editController.text = storedValue.toString();
            }
          }
        } else if (storedValue != null) {
          // No option list, treat as custom text
          selectedOption = null;
          if (editController.text != storedValue.toString()) {
            editController.text = storedValue.toString();
          }
        }

        returnWidget = CustomDropdown<Option>(
          key: ValueKey("${dynamicField.key}_${rowIndex}_$isCellDisabled"),
          validationMessage: dynamicField.message,
          isEnabled: !isCellDisabled,
          isSearchable: true,
          items: dynamicField.optionList ?? [],
          selectedItems: selectedOption != null ? [selectedOption] : null,
          showEditIcon: true, // Enable edit mode
          editController: editController, // Pass controller for edit mode
          filterFn: (item, search) {
            return (item.value ?? "")
                .toLowerCase()
                .contains(search.toLowerCase());
          },
          onSelected: (value) {
            widget.document[controllerKey] = value.first.key;
            editController
                .clear(); // Clear edit controller when option selected

            // Trigger onFieldChange callback for parent ViewModel
            if (widget.onFieldChange != null) {
              widget.onFieldChange!(dynamicField.key, {
                "gridName": widget.fieldData.key,
                "index": rowIndex,
                "value": value,
              });
            }
          },
          onEditComplete: (text) {
            // Save custom text value when user finishes editing
            widget.document[controllerKey] = text.isEmpty ? null : text;

            // Trigger onFieldChange callback for parent ViewModel
            if (widget.onFieldChange != null) {
              widget.onFieldChange!(dynamicField.key, {
                "gridName": widget.fieldData.key,
                "index": rowIndex,
                "value": text,
              });
            }
          },
          onTextChanged: (text) {
            // Update document on every keystroke
            widget.document[controllerKey] = text.isEmpty ? null : text;
          },
          // Configure input formatters for numeric-only input with max length 4
          editInputFormatters: [
            FilteringTextInputFormatter.digitsOnly,
            LengthLimitingTextInputFormatter(4),
          ],
          editKeyboardType: TextInputType.number,
          itemBuilder: (context, item, isDisabled, isSelected) {
            return dropdownItemBuildWidget(item.value);
          },
          dropdownBuilder: (context, data) {
            // If there's a selected option, show it
            // Otherwise, show custom text from edit controller
            String displayText;
            if (data != null) {
              displayText = data.value ?? "";
            } else if (editController.text.isNotEmpty) {
              displayText = editController.text;
            } else {
              displayText = "";
            }

            return Text(
              displayText,
              style: const TextStyle(fontSize: 13),
              textAlign: TextAlign.left,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            );
          },
        );

      case FieldType.currency:
        // Currency dropdown uses global currency codes
        dynamicField.optionList = Globals.dynamicFormCurrencyCodes;

        // Create a temporary document map that maps the field key to the
        // flattened key value
        // This allows CurrencyUtils.extractFromDocument to find the stored
        // value
        final Map<String, dynamic> currencyDocument = {
          dynamicField.key: widget.document[controllerKey],
        };

        // Use the refactored DynamicFormCurrencyDropdownTextfield component
        returnWidget = DynamicFormCurrencyDropdownTextfield(
          key: ValueKey("${dynamicField.key}_$rowIndex"),
          fieldData: dynamicField,
          document: currencyDocument,
          showLabel: false,
          controller: controller,
          onSubmit: (Map<String, dynamic> payload) {
            // Store with flattened key format
            // final String documentKey = '${dynamicField.key}@$rowIndex';
            widget.document[controllerKey] = payload;

            // Trigger onFieldChange callback if provided
            if (widget.onFieldChange != null) {
              widget.onFieldChange!(dynamicField.key, {
                "gridName": widget.fieldData.key,
                "index": rowIndex,
                "value": payload,
              });
            }
          },
        );
      case FieldType.grid:
        returnWidget = DynamicFormGrid(
          key: UniqueKey(),
          fieldData: dynamicField,
          document: widget.document,
        );
      case FieldType.multiSelect:
        returnWidget = CustomMultiSelectDropdown(
          key: ValueKey("${dynamicField.key}_${rowIndex}_$isCellDisabled"),
          isEnabled: !isCellDisabled,
          isSearchable: true,
          items: (dynamicField.optionList ?? []).map((e) => e.value).toList(),
          onSelected: (value) {
            widget.document[controllerKey] = value;

            // Trigger onFieldChange callback for parent ViewModel
            if (widget.onFieldChange != null) {
              widget.onFieldChange!(dynamicField.key, {
                "gridName": widget.fieldData.key,
                "index": rowIndex,
                "value": value,
              });
            }
          },
        );
      case FieldType.tenorControl:
        // Create document map for this cell using flattened key
        final Map<String, dynamic> tenorDocument = {
          dynamicField.key: widget.document[controllerKey],
        };

        returnWidget = DynamicFormDropdownTextfield(
          key: ValueKey("${dynamicField.key}_$rowIndex"),
          fieldData: dynamicField,
          document: tenorDocument,
          showLabel: false,
          controller: controller,
          onSubmit: (Map<String, dynamic> value) {
            // Save with flattened key format
            widget.document[controllerKey] = value;

            // Trigger onFieldChange callback for parent ViewModel
            if (widget.onFieldChange != null) {
              widget.onFieldChange!(dynamicField.key, {
                "gridName": widget.fieldData.key,
                "index": rowIndex,
                "value": value,
              });
            }
          },
        );

      case FieldType.refDataDropdown:
        // Create a temporary document that maps the simple key format to the
        // grid-qualified value
        // This allows DynamicReferenceDataDropdown to sync with grid cells
        final Map<String, dynamic> refDataDocument = {
          dynamicField.key: widget.document[controllerKey],
        };

        returnWidget = DynamicReferenceDataDropdown(
          key: ValueKey("${dynamicField.key}_${rowIndex}_$isCellDisabled"),
          fieldData: dynamicField,
          document: refDataDocument,
          showLabel: false,
          onSubmit: (String? value) {
            // onSubmit is required but not used for grid cells
            // Value updates happen through selectedOption callback
          },
          selectedOption: (selectedItem) {
            // Cast to Option to access the key property
            final option = selectedItem as Option;
            // Store the selected value using the qualified flattened key
            widget.document[controllerKey] = option.key;

            // Trigger onFieldChange callback for parent ViewModel
            if (widget.onFieldChange != null) {
              widget.onFieldChange!(dynamicField.key, {
                "gridName": widget.fieldData.key,
                "index": rowIndex,
                "value": option.key,
              });
            }
          },
        );
      default:
        returnWidget = const SizedBox();
    }
    return returnWidget;
  }

  // /// Adds a new row to the grid
  // ///
  // /// Creates a new row with empty fields (isNewRow=true) and a delete button.
  // void addGridRow() {
  //   final rowIndex = rows.length; // new row position

  //   rows.add([
  //     for (int i = 0; i < (widget.fieldData.columnInfoList?.length ?? 0);
  // i++)
  //       buildGridCellWidget(widget.fieldData.columnInfoList![i].dynamicField,
  // i,
  //           rowIndex, true),
  //     deleteFunction(),
  //   ]);
  //   setState(() {});
  // }
}
