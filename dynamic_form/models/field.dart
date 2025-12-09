import 'package:wcas_frontend/core/components/dropdown/model.dart';
import 'package:wcas_frontend/core/components/dynamic_form/models/grid_field.dart';

enum FieldType {
  textField,
  none,
  dropdown,
  grid,
  datePicker,
  singleCheckBox,
  percentage,
  currency,
  multiSelect,
  customerSearch,
  amount,
  tenorControl,
  conditionalTextbox,
  entityIdField,
  radioButton,
  textArea,
  refDataDropdown,
  table,
  conditionaldropdown,
  countryDropdown,
  sizedBox
}

class DynamicField {
  final FieldType controlType;
  final String key;
  final String label;
  final bool required;
  int? maxLength;
  final int rowData;
  List<Option>? optionList;
  final String? message;
  final String? validationPattern;
  final String? directiveType;
  final List<Option>? dependentList;
  final String? operationKey;
  final bool enabledDefault;
  final bool isDisable;
  final bool isCMOUpdate;
  bool isActive;
  final dynamic defaultValue;
  final List<DynamicGridField>? columnInfoList;
  bool? isNewRow;
  bool showField = true;

  DynamicField({
    required this.controlType,
    this.isCMOUpdate = false,
    this.isActive = true,
    required this.key,
    required this.label,
    required this.required,
    this.maxLength,
    required this.rowData,
    this.optionList,
    this.message,
    this.validationPattern,
    this.directiveType,
    this.dependentList,
    this.operationKey,
    required this.enabledDefault,
    required this.isDisable,
    this.defaultValue,
    this.columnInfoList,
    this.isNewRow,
  });

  factory DynamicField.fromJson(Map<String, dynamic> json) {
    return DynamicField(
      controlType: _mapControlType(json['controlType'], key: json['key']),
      key: json['key'] ?? "",
      label: json['label'] ?? "",
      required: json['required'] ?? false,
      isCMOUpdate: json["isCMOUpdate"] == "1" ? true : false,
      maxLength: json['maxLength'],
      rowData: json['rowData'],
      optionList: _parseOptionList(json['optionList']),
      message: json['message'],
      validationPattern: json['validationPattern'],
      directiveType: json['directiveType'],
      dependentList: (json['dependentList'] as List?)
          ?.map((option) => Option.fromJson(option))
          .toList(),
      operationKey: json['operationKey'],
      enabledDefault: json['enabledDefault'] ?? true,
      isDisable: json['isDisable'] ?? false,
      defaultValue: json['defaultValue'],
      columnInfoList: (json['columnInfoList'] as List?)
          ?.map((option) => DynamicGridField.fromJson(option))
          .toList(),
      isActive: json['isActive'] == "1" ? true : false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'controlType': controlType.name,
      'key': key,
      'label': label,
      'required': required,
      'maxLength': maxLength,
      'rowData': rowData,
      'optionList': optionList?.map((option) => option.toJson()).toList(),
      'message': message,
      'validationPattern': validationPattern,
      'directiveType': directiveType,
      'dependentList': dependentList?.map((dep) => dep.toJson()).toList(),
      'operationKey': operationKey,
      'enabledDefault': enabledDefault,
      'isDisable': isDisable,
      'defaultValue': defaultValue,
      'columnInfoList': columnInfoList?.map((col) => col.toJson()).toList(),
    };
  }

  static List<Option>? _parseOptionList(dynamic optionJson) {
    if (optionJson == null) return [];

    // Handle the nested structure with "myArrayList"
    if (optionJson is Map<String, dynamic> &&
        optionJson['myArrayList'] != null) {
      final list = optionJson['myArrayList'] as List;
      return list.map((item) {
        final map = item['map'] as Map<String, dynamic>;
        return Option(key: map['key'], pairValue: map['value']);
      }).toList();
    }

    // Existing logic for other cases
    if (optionJson is List) {
      return optionJson.map((e) => Option.fromJson(e)).toList();
    }

    return [];
  }

  static FieldType _mapControlType(String type, {String? key}) {
    if (key == 'guarantorEntityId') {
      return FieldType.entityIdField;
    }
    switch (type.toLowerCase()) {
      case 'textbox':
        return FieldType.textField;
      case 'dropdown':
        return FieldType.dropdown;
      case 'datepicker':
        return FieldType.datePicker;
      case 'grid':
        return FieldType.grid;
      case 'singlecheckbox':
        return FieldType.singleCheckBox;
      case 'percentage':
        return FieldType.percentage;
      case 'currency':
        return FieldType.currency;
      case 'multiselect':
        return FieldType.multiSelect;
      case 'customersearch':
        return FieldType.customerSearch;
      case 'amount':
        return FieldType.amount;
      case 'tenorcontrol':
        return FieldType.tenorControl;
      case 'conditionaltextbox':
        return FieldType.conditionalTextbox;
      case 'radiobutton':
        return FieldType.radioButton;
      case 'textarea':
        return FieldType.textArea;
      case 'table':
        return FieldType.table;
      case 'referencedatadropdown':
        return FieldType.refDataDropdown;
      case 'conditionaldropdown':
        return FieldType.conditionaldropdown;
      case 'countrydropdown':
        return FieldType.countryDropdown;
      case 'sizedBox':
        return FieldType.sizedBox;
      default:
        return FieldType.none;

      //map more control type
      // throw Exception("Unknown control type: $type");
    }
  }
}

class Option extends CustomDropdownItem {
  final String? key;
  final String? pairValue;
  dynamic metaData;

  Option({required this.key, required this.pairValue, this.metaData})
      : super(label: key, value: pairValue);

  factory Option.fromJson(Map<String, dynamic> json) {
    return Option(
      key: json['key'].toString(),
      pairValue: json['value'],
    );
  }
  Map<String, dynamic> toJson() {
    return {
      'key': key,
      'value': pairValue,
    };
  }
}
