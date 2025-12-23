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
import 'package:wcas_frontend/core/components/dynamic_form/utils/date_utils.dart';
import 'package:wcas_frontend/core/globals.dart';

import 'fields/textfield.dart';
import 'models/field.dart';

class DynamicFormField extends StatefulWidget {
  final DynamicField field;
  final Map<String, dynamic> document;
  final TextEditingController? controller;
  final void Function(String fieldKey, dynamic value)? onFieldChange;
  final void Function(String key, TextEditingController controller)?
      onControllerCreated;

  const DynamicFormField({
    super.key,
    required this.field,
    required this.document,
    this.controller,
    this.onFieldChange,
    this.onControllerCreated,
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
    final fieldKey = (widget.field.key).trim();
    debugPrint('Key: ${fieldKey.isEmpty ? "<empty>" : fieldKey} '
        '→ Type: ${widget.field.controlType}');

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
            inputFormatters: [
              FilteringTextInputFormatter.allow(
                RegExp(r'^(?:100(?:\.0{0,2})?|\d{1,2}(?:\.\d{0,2})?)$'),
              ),
              LengthLimitingTextInputFormatter(6),
            ],
            fieldData: widget.field,
            document: widget.document,
            onSubmit: _onFieldChange,
            onChanged: _onFieldChange,
            controller: widget.controller,
          );
        case FieldType.sizedBox:
          return const SizedBox.shrink();
        case FieldType.datePicker:
          return DynamicFormDatePicker(
            fieldData: widget.field,
            document: widget.document,
            onSubmit: (selectedDate) {
              final dateValue = convertDateTimeToFormValue(selectedDate);
              widget.document[widget.field.key] = dateValue;
              widget.onFieldChange?.call(widget.field.key, dateValue);
            },
          );
        case FieldType.singleCheckBox:
          // Initialize with defaultValue if document doesn't have a value yet
          if (!widget.document.containsKey(widget.field.key) &&
              widget.field.defaultValue != null) {
            // Parse defaultValue (comes as string "true" or "false" from API)
            final defaultVal = widget.field.defaultValue;
            if (defaultVal is bool) {
              widget.document[widget.field.key] = defaultVal;
            } else if (defaultVal is String) {
              widget.document[widget.field.key] =
                  defaultVal.toLowerCase() == 'true';
            }
          }

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
                widget.onFieldChange?.call(widget.field.key, value);
              });
        case FieldType.currency:
          // Update the optionList to use currency codes but keep the original field
          // This preserves isMandatory and other runtime properties
          final currencyField = widget.field;
          currencyField.optionList = Globals.dynamicFormCurrencyCodes;

          return DynamicFormCurrencyDropdownTextfield(
            fieldData: currencyField,
            document: widget.document,
            showLabel: true,
            onSubmit: _onCurrencyFieldChange,
            controller: widget.controller,
          );
        case FieldType.grid:
          return DynamicFormGrid(
            fieldData: widget.field,
            document: widget.document,
            onFieldChange: widget.onFieldChange,
            onControllerCreated: widget.onControllerCreated,
          );
        case FieldType.table:
          return DynamicFormGrid(
            fieldData: widget.field,
            document: widget.document,
            isTable: true,
            onFieldChange: widget.onFieldChange,
            onControllerCreated: widget.onControllerCreated,
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
            onSubmit: _onFieldChange,
            selectedOption: (value) {
              widget.document[widget.field.key] = value.value;
              widget.onFieldChange?.call(widget.field.key, value);
            },
          );
        case FieldType.countryDropdown:
          return DynamicFormCountryDropdown(
            fieldData: widget.field,
            document: widget.document,
            selectedOption: (value) {
              widget.document[widget.field.key] = value;
              widget.onFieldChange?.call(widget.field.key, value);
            },
          );
        case FieldType.conditionaldropdown:
          return DynamicFormDropdown(
            fieldData: widget.field,
            selectedOption: (value) {
              widget.document[widget.field.key] = value;
              widget.onFieldChange?.call(widget.field.key, value);
            },
          );
        case FieldType.accountNo:
          return DynamicFormTextField(
            fieldData: widget.field,
            document: widget.document,
            onSubmit: _onFieldChange,
            onChanged: _onFieldChange,
            controller: widget.controller,
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
