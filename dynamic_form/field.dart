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
import 'package:wcas_frontend/core/components/dynamic_form/fields/search_entity.dart';
import 'package:wcas_frontend/core/components/dynamic_form/fields/single_check_box.dart';
import 'package:wcas_frontend/core/components/dynamic_form/fields/text_area.dart';
import 'package:wcas_frontend/core/globals.dart';

import 'fields/textfield.dart';
import 'models/field.dart';

class DynamicFormField extends StatefulWidget {
  final DynamicField field;
  final Map<String, dynamic> document;
  final void Function(String fieldKey, dynamic value)? onFieldChange;
  final TextEditingController? controller; // Centrally managed controller

  const DynamicFormField({
    super.key,
    required this.field,
    required this.document,
    this.onFieldChange,
    this.controller,
  });

  @override
  State<DynamicFormField> createState() => _DynamicFormFieldState();
}

class _DynamicFormFieldState extends State<DynamicFormField> {
  @override
  void initState() {
    super.initState();
  }

  // Called when any source field changes
  void _onFieldChange(String? value) {
    // Update document map
    widget.document[widget.field.key] = value;

    // Invoke external callback if provided
    widget.onFieldChange?.call(widget.field.key, value);
  }

  // Called when currency field changes (receives a map with currency: value)
  void _onCurrencyFieldChange(Map<String, dynamic> value) {
    // Update document map with the currency map
    widget.document[widget.field.key] = value;

    // Invoke external callback if provided
    widget.onFieldChange?.call(widget.field.key, value);
  }

  Widget formWidget() {
    if (widget.field.showField) {
      switch (widget.field.controlType) {
        case FieldType.entityIdField:
          return DynamicFormSearchEntity(
            fieldData: widget.field,
            document: widget.document,
            onSubmit: _onFieldChange,
            controller: widget.controller,
          );
        case FieldType.textField:
          return DynamicFormTextField(
            fieldData: widget.field,
            document: widget.document,
            onSubmit: _onFieldChange,
            onChanged: _onFieldChange,
            controller: widget.controller,
          );
        case FieldType.percentage:
          widget.field.maxLength;
          return DynamicFormTextField(
            inputFormatters: [NumericFloatingPointFormatter()],
            fieldData: widget.field,
            document: widget.document,
            onSubmit: _onFieldChange,
            onChanged: _onFieldChange,
            controller: widget.controller,
          );
        case FieldType.sizedBox:
          return const SizedBox();
        case FieldType.datePicker:
          return DynamicFormDatePicker(
            fieldData: widget.field,
            document: widget.document,
            onSubmit: (selectedDate) {
              if (selectedDate != null) {
                // Save in the same format as API provides
                final dateValue = {
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
                widget.document[widget.field.key] = dateValue;
                widget.onFieldChange?.call(widget.field.key, dateValue);
              } else {
                widget.document[widget.field.key] = null;
                widget.onFieldChange?.call(widget.field.key, null);
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
              widget.document[widget.field.key] = value;
              widget.onFieldChange?.call(widget.field.key, value);
            },
          );
        case FieldType.dropdown:
          return DynamicFormDropdown(
              fieldData: widget.field,
              document: widget.document,
              selectedOption: (value) {
                widget.document[widget.field.key] = value.key;
                widget.onFieldChange?.call(widget.field.key, value.key);
              });
        case FieldType.currency:
          return DynamicFormCurrencyDropdownTextfield(
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
            onSubmit: _onCurrencyFieldChange,
            controller: widget.controller,
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
              selectedOptions: (value) {
                widget.document[widget.field.key] = value;
                widget.onFieldChange?.call(widget.field.key, value);
              });
        case FieldType.customerSearch:
          return DynamicFormTextField(
            fieldData: widget.field,
            document: widget.document,
            onSubmit: _onFieldChange,
          );

        case FieldType.amount:
          return DynamicFormTextField(
            fieldData: widget.field,
            document: widget.document,
            onSubmit: _onFieldChange,
          );
        case FieldType.tenorControl:
          return DynamicFormDropdownTextfield(
            onSubmit: (value) {
              widget.document[widget.field.key] = value;
              widget.onFieldChange?.call(widget.field.key, value);
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
              widget.onFieldChange?.call(widget.field.key, value);
            },
          );
        case FieldType.textArea: //TODO  this fieldType need to check
          return DynamicFormTextAreaField(
            fieldData: widget.field,
            document: widget.document,
            onSubmit: (value) {
              widget.document[widget.field.key] = value;
              widget.onFieldChange?.call(widget.field.key, value);
            },
          );
        case FieldType.radioButton:
          return DynamicRadioButton(
            options: widget.field.optionList
                    ?.map((e) => e.pairValue ?? "")
                    .toList() ??
                [],
            fieldData: widget.field,
            onChange: (value) {
              widget.document[widget.field.key] = value;
              widget.onFieldChange?.call(widget.field.key, value);
            },
          );
        case FieldType.refDataDropdown:
          return DynamicReferenceDataDropdown(
            fieldData: widget.field,
            document: widget.document,
            selectedOption: (value) {
              widget.document[widget.field.key] = value.value;
              widget.onFieldChange?.call(widget.field.key, value.value);
            },
          );
        case FieldType.countryDropdown: //TODO  this fieldType need to check
          return DynamicFormCountryDropdown(
            fieldData: widget.field,
            document: widget.document,
            selectedOption: (value) {
              widget.document[widget.field.key] = value;
              widget.onFieldChange?.call(widget.field.key, value);
            },
          );
        case FieldType.conditionaldropdown: //TODO  this fieldType need to check
          return DynamicFormDropdown(
            fieldData: widget.field,
            selectedOption: (value) {
              widget.document[widget.field.key] = value;
              widget.onFieldChange?.call(widget.field.key, value);
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
