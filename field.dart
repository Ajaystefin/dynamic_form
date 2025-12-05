import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:wcas_frontend/core/components/dynamic_form/fields/conditional_textbox.dart';
import 'package:wcas_frontend/core/components/dynamic_form/fields/country_dropdown.dart';
import 'package:wcas_frontend/core/components/dynamic_form/fields/currency_dropdown.dart';
import 'package:wcas_frontend/core/components/dynamic_form/fields/date_picker.dart';
import 'package:wcas_frontend/core/components/dynamic_form/fields/dropdown.dart';
import 'package:wcas_frontend/core/components/dynamic_form/fields/dropdown_textfield.dart';
import 'package:wcas_frontend/core/components/dynamic_form/fields/grid.dart';
import 'package:wcas_frontend/core/components/dynamic_form/fields/multiselect.dart';
import 'package:wcas_frontend/core/components/dynamic_form/fields/radio_button.dart';
import 'package:wcas_frontend/core/components/dynamic_form/fields/reference_data_dropdown.dart';
import 'package:wcas_frontend/core/components/dynamic_form/fields/single_check_box.dart';
import 'package:wcas_frontend/core/components/dynamic_form/fields/text_area.dart';
import 'package:wcas_frontend/core/constants/_server_constants.dart';
import 'package:wcas_frontend/core/globals.dart';

import 'field_dependencies.dart';
import 'fields/textfield.dart';
import 'models/field.dart';

class DynamicFormField extends StatefulWidget {
  final DynamicField field;
  final Map<String, dynamic> document;
  final FieldDependencies? dependencies;
  final Map<String, TextEditingController> dependentControllers;

  const DynamicFormField({
    super.key,
    required this.field,
    required this.document,
    this.dependencies,
    required this.dependentControllers,
  });

  @override
  State<DynamicFormField> createState() => _DynamicFormFieldState();
}

class _DynamicFormFieldState extends State<DynamicFormField> {
  // Controllers for dependent textfields and currency fields

  FieldDependencies get _dependencies =>
      widget.dependencies ?? FieldDependencies.empty;
  Map<String, TextEditingController> get _dependentControllers =>
      widget.dependentControllers;

  @override
  void initState() {
    super.initState();

    // Create controller for ALL text fields (not just dependent ones)
    // This ensures programmatic updates via updateFieldValue work correctly
    if (_isTextField()) {
      // Only create if not already exists (avoid duplicates)
      if (!_dependentControllers.containsKey(widget.field.key)) {
        _dependentControllers[widget.field.key] = TextEditingController();
      }

      // If this is a dependent field, calculate initial value
      if (_dependencies.isDependent(widget.field.key)) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          _updateDependentField(widget.field.key);
        });
      } else {
        // For non-dependent fields, set initial value from document if exists
        WidgetsBinding.instance.addPostFrameCallback((_) {
          final initialValue = widget.document[widget.field.key];
          if (initialValue != null) {
            _dependentControllers[widget.field.key]?.text =
                initialValue.toString();
          }
        });
      }
    }

    // Create controller for ALL currency fields (not just dependent ones)
    if (_isCurrencyField()) {
      // Only create if not already exists (avoid duplicates)
      if (!_dependentControllers.containsKey(widget.field.key)) {
        _dependentControllers[widget.field.key] = TextEditingController();
      }

      // If this is a dependent field, calculate initial value
      if (_dependencies.isDependent(widget.field.key)) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          _updateDependentField(widget.field.key);
        });
      } else {
        // For non-dependent currency fields, set initial value from document if exists
        WidgetsBinding.instance.addPostFrameCallback((_) {
          final initialValue = widget.document[widget.field.key];
          if (initialValue is Map<String, dynamic> &&
              initialValue.containsKey('value')) {
            _dependentControllers[widget.field.key]?.text =
                initialValue['value']?.toString() ?? '';
          }
        });
      }
    }
  }

  @override
  void dispose() {
    for (var controller in _dependentControllers.values) {
      controller.dispose();
    }
    super.dispose();
  }

  bool _isTextField() {
    return widget.field.controlType == FieldType.textField ||
        widget.field.controlType == FieldType.percentage ||
        widget.field.controlType == FieldType.customerSearch ||
        widget.field.controlType == FieldType.amount;
  }

  bool _isCurrencyField() {
    return widget.field.controlType == FieldType.currency;
  }

  // Called when any source field changes
  void _onFieldChange(String? value) {
    // Update document map
    widget.document[widget.field.key] = value;

    // Find all dependencies triggered by this field
    final dependencies =
        _dependencies.getDependenciesForSource(widget.field.key);

    // Update each dependent field
    for (var dependency in dependencies) {
      _updateDependentField(dependency.dependentFieldKey);
    }
  }

  // Called when currency field changes (receives a map with currency: value)
  void _onCurrencyFieldChange(Map<String, dynamic> value) {
    // Update document map with the currency map
    widget.document[widget.field.key] = value;

    // Find all dependencies triggered by this field
    List<FieldDependency> dependencies =
        _dependencies.getDependenciesForSource(widget.field.key);

    // Update each dependent field
    for (FieldDependency dependency in dependencies) {
      _updateDependentField(dependency.dependentFieldKey);
    }
  }

  // Calculate and update a dependent field
  void _updateDependentField(String dependentKey) {
    final dependency = _dependencies.getDependency(dependentKey);
    if (dependency == null) return;

    // Calculate new value using the calculator function
    final newValue = dependency.calculator(widget.document);

    // Update UI via controller
    _dependentControllers[dependentKey]?.text = newValue;

    // Update document map
    widget.document[dependentKey] = newValue;
  }

  Widget formWidget() {
    if (widget.field.isActive || widget.field.enabledDefault) {
      switch (widget.field.controlType) {
        case FieldType.textField:
          return DynamicFormTextField(
            fieldData: widget.field,
            document: widget.document,
            controller: _dependentControllers[widget.field.key],
            onSubmit: _onFieldChange,
            onChanged: _onFieldChange,
          );
        case FieldType.percentage:
          return DynamicFormTextField(
            inputFormatters: [NumericFloatingPointFormatter()],
            fieldData: widget.field,
            document: widget.document,
            controller: _dependentControllers[widget.field.key],
            onSubmit: _onFieldChange,
            onChanged: _onFieldChange,
          );
        case FieldType.datePicker:
          return DynamicFormDatePicker(
            fieldData: widget.field,
            document: widget.document,
            onSubmit: (selectedDate) {
              if (selectedDate != null) {
                // Save in the same format as API provides
                widget.document[widget.field.key] = {
                  'date': {
                    'year': selectedDate.year,
                    'month': selectedDate.month,
                    'day': selectedDate.day,
                  },
                  'jsdate': selectedDate.toIso8601String(),
                  'formatted':
                      '${selectedDate.day.toString().padLeft(2, '0')}/${selectedDate.month.toString().padLeft(2, '0')}/${selectedDate.year}',
                  'epoc': selectedDate.millisecondsSinceEpoch ~/ 1000,
                };
              } else {
                widget.document[widget.field.key] = null;
              }
            },
          );
        case FieldType.singleCheckBox:
          return DynamicFormSingleCheckBox(
            fieldData: widget.field,
            document: widget.document,
            onSaved: (value) {
              widget.document[widget.field.key] = value;
            },
            onChanged: (value) {
              // widget.document[dynamicField.key] = value;
            },
          );
        case FieldType.dropdown:
          return DynamicFormDropdown(
              fieldData: widget.field,
              document: widget.document,
              selectedOption: (value) =>
                  widget.document[widget.field.key] = value.key);
        case FieldType.currency:
          return DynamicFormCurrecnyDropdownTextfield(
            fieldData: DynamicField(
              controlType: widget.field.controlType,
              key: widget.field.key,
              label: widget.field.label,
              required: widget.field.required,
              maxLength: widget.field.maxLength,
              rowData: widget.field.rowData,
              optionList: Globals.dynamicFormCurrencyCodes,
              message: widget.field.message,
              validationPattern: widget.field.validationPattern,
              directiveType: widget.field.directiveType,
              dependentList: widget.field.dependentList,
              operationKey: widget.field.operationKey,
              enabledDefault: widget.field.enabledDefault,
              isDisable: widget.field.isDisable,
              defaultValue: widget.field.defaultValue,
              columnInfoList: widget.field.columnInfoList,
            ),
            document: widget.document,
            showLabel: true,
            controller: _dependentControllers[widget.field.key],
            onSubmit: _onCurrencyFieldChange,
          );
        case FieldType.grid:
          return DynamicFormGrid(
            fieldData: widget.field,
            document: widget.document,
          );
        case FieldType.table:
          return DynamicFormGrid(
            fieldData: widget.field,
            document: widget.document,
            isTable: true,
          );
        case FieldType.multiSelect: //TODO  this fieldType need to check
          return DynamicFormMultiSelectDropdown(
              fieldData: widget.field,
              selectedOptions: (value) =>
                  widget.document[widget.field.key] = value);
        case FieldType.customerSearch:
          return DynamicFormTextField(
            fieldData: widget.field,
            document: widget.document,
            controller: _dependentControllers[widget.field.key],
            onSubmit: _onFieldChange,
          );

        case FieldType.amount:
          return DynamicFormTextField(
            fieldData: widget.field,
            document: widget.document,
            controller: _dependentControllers[widget.field.key],
            onSubmit: _onFieldChange,
          );
        case FieldType.tenorControl:
          return DynamicFormDropdownTextfield(
            onSubmit: (value) {
              widget.document[widget.field.key] = value;
            },
            showLabel: true,
            // inputFormatters: const [],
            fieldData: widget.field,
          );
        case FieldType.conditionalTextbox: // TODO  this fieldType need to check
          return DynamicConditionalTextbox(
            fieldData: widget.field,
            onSubmit: (value) {
              widget.document[widget.field.key] = value;
            },
          );
        case FieldType.textArea: //TODO  this fieldType need to check
          return DynamicFormTextAreaField(
            fieldData: widget.field,
            document: widget.document,
            onSubmit: (value) {
              widget.document[widget.field.key] = value;
            },
          );
        case FieldType.radioButton: //TODO  this fieldType need to check
          return DynamicRadioButton(
            options: const ["TSW", "RMH", "OBU"],
            fieldData: widget.field,
            onChange: (value) {
              widget.document[widget.field.key] = value;
            },
          );
        case FieldType.refDataDropdown:
          return DynamicReferenceDataDropdown(
            fieldData: widget.field.key == ServerConstants.nameOfZoneKeyValue
                ? DynamicField(
                    controlType: widget.field.controlType,
                    key: widget.field.key,
                    label: widget.field.label,
                    required: widget.field.required,
                    maxLength: widget.field.maxLength,
                    rowData: widget.field.rowData,
                    optionList: Globals.dynamicFormEconomicZones,
                    message: widget.field.message,
                    validationPattern: widget.field.validationPattern,
                    directiveType: widget.field.directiveType,
                    dependentList: widget.field.dependentList,
                    operationKey: widget.field.operationKey,
                    enabledDefault: widget.field.enabledDefault,
                    isDisable: widget.field.isDisable,
                    defaultValue: widget.field.defaultValue,
                    columnInfoList: widget.field.columnInfoList,
                  )
                : widget.field,
            document: widget.document,
            selectedOption: (value) {
              widget.document[widget.field.key] = value.value;
            },
          );
        case FieldType.countryDropdown: //TODO  this fieldType need to check
          return DynamicFormCountryDropdown(
            fieldData: widget.field,
            document: widget.document,
            selectedOption: (value) {
              widget.document[widget.field.key] = value;
            },
          );
        case FieldType.conditionaldropdown: //TODO  this fieldType need to check
          return DynamicFormDropdown(
            fieldData: widget.field,
            selectedOption: (value) {
              widget.document[widget.field.key] = value;
            },
          );
        default:
          return const SizedBox.shrink();
      }
    } else {
      return const SizedBox.shrink();
    }
  }

  @override
  Widget build(BuildContext context) {
    return formWidget();
  }
}

// format text input to write only floating value
class NumericFloatingPointFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    // Allow empty input or if it's a valid number or floating point value
    if (newValue.text.isEmpty) {
      return newValue;
    }

    // Allow only digits and one decimal point
    if (RegExp(r'^\d*\.?\d*$').hasMatch(newValue.text)) {
      return newValue;
    }

    return oldValue;
  }
}
