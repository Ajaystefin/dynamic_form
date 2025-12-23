import 'package:flutter/material.dart';
import 'package:wcas_frontend/core/components/custom_table/table.dart';
import 'package:wcas_frontend/core/components/datepicker.dart';
import 'package:wcas_frontend/core/components/dropdown/dropdown.dart';
import 'package:wcas_frontend/core/components/dropdown/multi_select_dropdown.dart';
import 'package:wcas_frontend/core/components/dynamic_form/fields/currency_dropdown.dart';
import 'package:wcas_frontend/core/components/dynamic_form/fields/dropdown_textfield.dart';
import 'package:wcas_frontend/core/components/dynamic_form/fields/single_check_box.dart';
import 'package:wcas_frontend/core/components/dynamic_form/models/field.dart';
import 'package:wcas_frontend/core/components/dynamic_form/models/grid_field.dart';
import 'package:wcas_frontend/core/components/dynamic_form/utils/date_utils.dart';
import 'package:wcas_frontend/core/components/gap.dart';
import 'package:wcas_frontend/core/components/textfield.dart';
import 'package:wcas_frontend/core/constants/constants.dart';
import 'package:wcas_frontend/core/globals.dart';

class DynamicFormGrid extends StatefulWidget {
  final bool isTable;
  final DynamicField fieldData;
  final Map<String, dynamic> document;
  final void Function(String fieldKey, dynamic value)? onFieldChange;
  final void Function(String key, TextEditingController controller)?
      onControllerCreated;

  const DynamicFormGrid({
    super.key,
    required this.fieldData,
    this.isTable = false,
    required this.document,
    this.onFieldChange,
    this.onControllerCreated,
  });

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
    _rowCount = 1; // Start with one row
    rows = _buildRows(); // Build initial rows
    _lastFieldPropertiesHash = _computeFieldPropertiesHash(); // Initialize hash
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
    final columns = widget.fieldData.columnInfoList ?? [];
    int hash = 0;

    for (int i = 0; i < columns.length; i++) {
      final field = columns[i].dynamicField;
      // Combine field properties into hash
      hash = hash ^ field.isDisable.hashCode;
      hash = hash ^ field.isMandatory.hashCode;
      hash = hash ^ field.showField.hashCode;
      hash = hash ^ i; // Include index to differentiate columns
    }

    return hash;
  }

  /// Builds rows for the current row count
  List<List<Widget>> _buildRows() {
    List<DynamicGridField> dynamicFormGridFields =
        widget.fieldData.columnInfoList ?? [];

    return List.generate(_rowCount, (rowIndex) {
      return [
        for (int i = 0; i < dynamicFormGridFields.length; i++)
          buildGridCellWidget(
            dynamicFormGridFields[i].dynamicField,
            i,
            rowIndex,
            false, // Load from document
          ),
        deleteFunction() // Add delete button
      ];
    });
  }

  @override
  Widget build(BuildContext context) {
    // Don't rebuild rows here - only rebuild when row count changes (in didUpdateWidget)
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
                        text: ' *',
                        style: TextStyle(
                          color: AppColors.failure,
                          fontFeatures: [FontFeature.enable('sups')],
                        ),
                      ),
                    if (widget.fieldData.isCMOUpdate)
                      const TextSpan(
                        text: " #",
                        style: TextStyle(
                          fontSize: 9,
                          fontFeatures: [
                            FontFeature.superscripts(),
                            FontFeature.enable('sups')
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
                    onPressed: () {
                      addGridRow();
                    },
                    icon: const Icon(Icons.add)),
            ],
          ),
          buildTable(columns: getTableColumns()),
        ],
      ),
    );
  }

  /// Builds the initial grid rows from field configuration
  ///
  /// Returns a list of widget rows, each containing cells for the configured columns.
  /// The first row (index 0) is created with isNewRow=false to load existing data.
  List<List<Widget>> buildInitialGridRows() {
    List<DynamicGridField>? dynamicFormGridFields =
        (widget.fieldData.columnInfoList ?? []);
    return [
      [
        for (int i = 0; i < dynamicFormGridFields.length; i++) ...[
          buildGridCellWidget(
              dynamicFormGridFields[i].dynamicField, i, 0, false) // rowIndex=0
        ],
        const SizedBox()
      ]
    ];
  }

  Widget buildTable({
    required List<TableColumn> columns,
  }) {
    return CustomRawTable(
      rowHeight: 90,
      key: ValueKey(
          'grid_${_rowCount}_$_fieldPropertiesVersion'), // Stable key that changes only when needed
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
    List<TableColumn> columns = [];
    for (DynamicGridField element in widget.fieldData.columnInfoList ?? []) {
      columns.add(
        TableColumn(
          // forcedWidth: 50.w,

          width: _getColumnWidth(element.dynamicField.controlType),

          label: RichText(
              text: TextSpan(children: [
            TextSpan(
              text: element.dynamicField.label,
            ),
            if (element.dynamicField.isRequired)
              const TextSpan(
                text: ' *',
                style: TextStyle(
                  color: AppColors.failure,
                  fontFeatures: [FontFeature.enable('sups')],
                ),
              ),
          ])),
        ),
      );
    }
    return [...columns, const TableColumn(forcedWidth: 50, label: SizedBox())];
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
      case FieldType.multiSelect:
      case FieldType.customerSearch:
      case FieldType.accountNo:
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
        onPressed: () {
          deleteGridRow();
        },
        icon: const Icon(Icons.delete));
  }

  /// Builds a widget for a single grid cell
  ///
  /// This method creates the appropriate widget based on the field's controlType.
  /// All field values are stored in the document map using the flattened key format:
  /// "{fieldKey}@{rowIndex}"
  ///
  /// Parameters:
  /// - [dynamicField]: Field configuration from the API
  /// - [colIndex]: Column index in the grid
  /// - [rowIndex]: Row index in the grid
  /// - [isNewRow]: Whether this is a newly added row (starts empty)
  Widget buildGridCellWidget(
      DynamicField dynamicField, int colIndex, int rowIndex, bool isNewRow) {
    late Widget returnWidget;

    // Construct the flattened key for this grid cell
    final controllerKey = '${dynamicField.key}@$rowIndex';
    final controller = controllers.putIfAbsent(
      controllerKey,
      () {
        final newController = TextEditingController();

        // Register this controller with DynamicForm's _controllers map
        if (widget.onControllerCreated != null) {
          widget.onControllerCreated!(controllerKey, newController);
        }

        return newController;
      },
    );

    // Load initial value from document using flattened key
    final storedValue = isNewRow ? null : widget.document[controllerKey];

    // Handle initial value setting based on field type
    final isCurrencyMap = dynamicField.controlType == FieldType.currency &&
        storedValue is Map<String, dynamic>;

    if (!isCurrencyMap && storedValue != null) {
      final initialText = storedValue.toString();
      if (controller.text != initialText) {
        controller.text = initialText;
      }
    } else if (!isCurrencyMap) {
      // Ensure controller starts blank when no stored value
      if (controller.text.isNotEmpty) {
        controller.text = '';
      }
    }

    switch (dynamicField.controlType) {
      case FieldType.textField || FieldType.accountNo:
        returnWidget = CustomTextField(
          key: ValueKey(
              '${dynamicField.key}_${rowIndex}_${dynamicField.isDisable}'),
          controller: controller,
          hintText: dynamicField.defaultValue,
          maxLength: dynamicField.maxLength,
          errorText: dynamicField.message,
          readOnly: dynamicField.isDisable,
          filled: dynamicField.isDisable,
          counterText: "",
          onSaved: (value) {
            widget.document[controllerKey] = value;
          },
          onChanged: (value) {
            widget.document[controllerKey] = value;

            // Trigger onFieldChange callback for parent ViewModel
            if (widget.onFieldChange != null) {
              widget.onFieldChange!(
                  dynamicField.key, {'index': rowIndex, 'value': value});
            }
          },
        );

      case FieldType.customerSearch:
        returnWidget = CustomTextField(
          key: ValueKey(
              '${dynamicField.key}_${rowIndex}_${dynamicField.isDisable}'),
          controller: controller,
          hintText: dynamicField.defaultValue ?? 'Search',
          maxLength: dynamicField.maxLength,
          // errorText: dynamicField.message,
          readOnly: dynamicField.isDisable,
          counterText: "",
          onSaved: (value) {
            widget.document[controllerKey] = value;
          },
          onChanged: (value) {
            widget.document[controllerKey] = value;

            // Trigger onFieldChange callback for parent ViewModel
            if (widget.onFieldChange != null) {
              widget.onFieldChange!(
                  dynamicField.key, {'index': rowIndex, 'value': value});
            }
          },
        );

      case FieldType.amount:
        returnWidget = CustomTextField(
          key: ValueKey('${dynamicField.key}_$rowIndex'),
          controller: controller,
          hintText: dynamicField.defaultValue,
          maxLength: dynamicField.maxLength,
          errorText: dynamicField.message,
          readOnly: dynamicField.isDisable,
          onSaved: (value) {
            widget.document[controllerKey] = value;
          },
          onChanged: (value) {
            widget.document[controllerKey] = value;

            // Trigger onFieldChange callback for parent ViewModel
            if (widget.onFieldChange != null) {
              widget.onFieldChange!(
                  dynamicField.key, {'index': rowIndex, 'value': value});
            }
          },
        );
      case FieldType.percentage:
        returnWidget = CustomTextField(
          key: ValueKey('${dynamicField.key}_$rowIndex'),
          controller: controller,
          hintText: dynamicField.defaultValue,
          maxLength: dynamicField.maxLength,
          errorText: dynamicField.message,
          readOnly: dynamicField.isDisable,
          onSaved: (value) {
            widget.document[controllerKey] = value;
          },
          onChanged: (value) {
            widget.document[controllerKey] = value;

            // Trigger onFieldChange callback for parent ViewModel
            if (widget.onFieldChange != null) {
              widget.onFieldChange!(
                  dynamicField.key, {'index': rowIndex, 'value': value});
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
            // Handle custom date format like {"date": {...}, "jsdate": "...", "epoc": ...}
            final jsdate = storedValue['jsdate'];
            if (jsdate is String) {
              initialDate = DateTime.tryParse(jsdate);
            }
          }
        }

        returnWidget = CustomDatePicker(
          key: ValueKey('${dynamicField.key}_$rowIndex'),
          initialDateTime: initialDate,
          validator: dynamicField.isRequired
              ? (value) {
                  if (value == null || value.isEmpty) {
                    return dynamicField.message ??
                        '${dynamicField.label} is required';
                  }
                  return null;
                }
              : null,
          onSubmit2: (DateTime? selectedDate) {
            final dateValue = convertDateTimeToFormValue(selectedDate);
            widget.document[controllerKey] = dateValue;

            // Trigger onFieldChange callback for parent ViewModel
            if (widget.onFieldChange != null) {
              widget.onFieldChange!(
                  dynamicField.key, {'index': rowIndex, 'value': dateValue});
            }
          },
        );
        break;

      case FieldType.singleCheckBox:
        {
          final currentValue = widget.document[controllerKey];
          final boolValue = (currentValue is bool) ? currentValue : false;

          debugPrint(
              'Checkbox $controllerKey: currentValue=$currentValue, boolValue=$boolValue');

          returnWidget = DynamicFormSingleCheckBox(
            fieldData: dynamicField,
            document: widget.document, // Pass document
            documentKey: controllerKey, // Pass key to read from
            value: boolValue, // Initial value
            onChanged: (value) {
              widget.document[controllerKey] = value == true;

              // Trigger onFieldChange callback for parent ViewModel
              if (widget.onFieldChange != null) {
                widget.onFieldChange!(dynamicField.key,
                    {'index': rowIndex, 'value': value == true});
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
        returnWidget = CustomDropdown<Option>(
          key: ValueKey('${dynamicField.key}_$rowIndex'),
          validationMessage: dynamicField.message,
          isEnabled: !dynamicField.isDisable,
          isSearchable: true,
          items: dynamicField.optionList ?? [],
          selectedItems: widget.document[controllerKey],
          onSelected: (value) {
            widget.document[controllerKey] = value;

            // Trigger onFieldChange callback for parent ViewModel
            if (widget.onFieldChange != null) {
              widget.onFieldChange!(
                  dynamicField.key, {'index': rowIndex, 'value': value});
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
      case FieldType.currency:
        // Update the optionList to use currency codes but keep the original field
        // This preserves isMandatory and other runtime properties
        final currencyField = dynamicField;
        currencyField.optionList = Globals.dynamicFormCurrencyCodes;
        // Use the standard DynamicFormCurrencyDropdownTextfield component
        returnWidget = DynamicFormCurrencyDropdownTextfield(
          key: ValueKey('${dynamicField.key}_$rowIndex'),
          fieldData: dynamicField,
          document: widget.document,
          showLabel: false,
          controller: controller,
          onSubmit: (payload) {
            // Store with flattened key format
            final documentKey = '${dynamicField.key}@$rowIndex';
            widget.document[documentKey] = payload;

            // Trigger onFieldChange callback if provided
            if (widget.onFieldChange != null) {
              widget.onFieldChange!(
                  dynamicField.key, {'index': rowIndex, 'value': payload});
            }
          },
        );
        break;
      case FieldType.grid:
        returnWidget = DynamicFormGrid(
          key: UniqueKey(),
          fieldData: dynamicField,
          document: widget.document,
        );
      case FieldType.multiSelect:
        returnWidget = CustomMultiSelectDropdown(
            key: ValueKey('${dynamicField.key}_$rowIndex'),
            isEnabled: !dynamicField.isDisable,
            isSearchable: true,
            items: (dynamicField.optionList ?? []).map((e) => e.value).toList(),
            onSelected: (value) {
              widget.document[controllerKey] = value;

              // Trigger onFieldChange callback for parent ViewModel
              if (widget.onFieldChange != null) {
                widget.onFieldChange!(
                    dynamicField.key, {'index': rowIndex, 'value': value});
              }
            });
      case FieldType.tenorControl:
        returnWidget = DynamicFormDropdownTextfield(
          key: UniqueKey(),
          onSubmit: (value) {}, inputFormatters: const [],
          showLabel: false,
          fieldData: dynamicField,
          // selectedOptions: (value) =>
          //     widget.document[dynamicField.key] = value);
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
  //     for (int i = 0; i < (widget.fieldData.columnInfoList?.length ?? 0); i++)
  //       buildGridCellWidget(widget.fieldData.columnInfoList![i].dynamicField, i,
  //           rowIndex, true),
  //     deleteFunction(),
  //   ]);
  //   setState(() {});
  // }
}
