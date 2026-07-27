import "package:wcas_frontend/core/components/dropdown/model.dart";
import "package:wcas_frontend/core/components/dynamic_form/models/grid_field.dart";

/// Supported dynamic form field types.
enum FieldType {
  /// Text input field.
  textField,

  /// Unknown or unsupported field type.
  none,

  /// Dropdown field.
  dropdown,

  /// Editable dropdown field.
  editableDropdown,

  /// Grid field.
  grid,

  /// Date picker field.
  datePicker,

  /// Single checkbox field.
  singleCheckBox,

  /// Multi-checkbox field where multiple items can be selected.
  checkbox,

  /// Percentage input field.
  percentage,

  /// Currency field.
  currency,

  /// Multi-select dropdown field.
  multiSelect,

  /// Customer search field.
  customerSearch,

  /// Amount input field.
  amount,

  /// Tenor control field.
  tenorControl,

  /// Conditional text field.
  conditionalTextbox,

  /// Entity identifier field.
  entityIdField,

  /// Radio button field.
  radioButton,

  /// Multi-line text area field.
  textArea,

  /// Reference data dropdown field.
  refDataDropdown,

  /// Table field.
  table,

  /// Conditional dropdown field.
  conditionaldropdown,

  /// Country dropdown field.
  countryDropdown,

  /// Spacer field.
  sizedBox,

  /// Account number field.
  accountNo,

  /// Label or header field.
  label,
}

/// Represents a dynamic form field configuration.
///
/// Contains metadata required to render, validate, and manage
/// dynamic form controls.
class DynamicField {
  /// Creates a [DynamicField].
  DynamicField({
    required this.controlType,
    required this.key,
    required this.label,
    required this.required,
    required this.rowData,
    required this.enabledDefault,
    required this.isDisable,
    this.isCMOUpdate = false,
    this.isActive = true,
    this.maxLength,
    this.optionList,
    this.message,
    this.validationPattern,
    this.directiveType,
    this.dependentList,
    this.operationKey,
    this.defaultValue,
    this.columnInfoList,
    this.isNewRow,
    this.disableDropdown = false,
    this.inputFormatterPattern,
    this.enableLimiterValidation = false,
  });

  /// Creates a [DynamicField] from JSON.
  factory DynamicField.fromJson(Map<String, dynamic> json) {
    final DynamicField field = DynamicField(
      controlType: _mapControlType(json["controlType"], key: json["key"]),
      key: json["key"] ?? "",
      label: json["label"] ?? "",
      required: json["required"] ?? false,
      isCMOUpdate: json["isCMOUpdate"] == "1",
      maxLength: json["maxLength"],
      rowData: json["rowData"],
      optionList: _parseOptionList(json["optionList"]),
      message: json["message"],
      validationPattern: json["validationPattern"],
      directiveType: json["directiveType"],
      dependentList: _parseOptionList(json["dependentList"]),
      operationKey: json["operationKey"],
      enabledDefault: json["enabledDefault"] ?? true,
      isDisable: json["isDisable"] ?? false,
      defaultValue: json["defaultValue"],
      columnInfoList: (json["columnInfoList"] as List?)
          ?.map((option) => DynamicGridField.fromJson(option))
          .toList(),
      isActive: json["isActive"] == "1",
    );
    field.showField = field.enabledDefault;
    return field;
  }

  /// Field control type.
  FieldType controlType;

  /// Field key.
  final String key;

  /// Field label.
  final String label;

  /// Indicates whether the field is required.
  bool required;

  /// Maximum input length.
  int? maxLength;

  /// Grid row span.
  final int rowData;

  /// Available options.
  List<Option>? optionList;

  /// Validation message.
  String? message;

  /// Validation pattern.
  final String? validationPattern;

  /// Directive type.
  final String? directiveType;

  /// Dependent field options.
  final List<Option>? dependentList;

  /// Operation key.
  final String? operationKey;

  /// Default enabled state.
  final bool enabledDefault;

  /// Indicates whether the field is disabled.
  bool isDisable;

  /// Indicates whether the field supports CMO updates.
  final bool isCMOUpdate;

  /// Indicates whether the field is active.
  bool isActive;

  /// Default field value.
  dynamic defaultValue;

  /// Grid column configuration.
  final List<DynamicGridField>? columnInfoList;

  /// Indicates whether the row is newly added.
  bool? isNewRow;

  /// Controls field visibility.
  bool showField = true;

  /// Runtime mandatory override.
  bool? isMandatory;

  /// Indicates whether the dropdown is disabled.
  bool disableDropdown;

  /// Input formatter pattern.
  String? inputFormatterPattern;

  /// Enables limiter validation.
  bool enableLimiterValidation;

  /// Returns the effective required status for this field
  ///
  /// If [isMandatory] is set (not null), it overrides the original [required]
  /// property.
  /// This allows programmatic control of field requirement status at runtime.
  ///
  /// Returns:
  /// - [isMandatory] value if it's set (not null)
  /// - [required] value otherwise (the original API configuration)
  bool get isRequired => isMandatory ?? required;

  /// Converts this field configuration to JSON.
  Map<String, dynamic> toJson() {
    return {
      "controlType": controlType.name,
      "key": key,
      "label": label,
      "required": required,
      "maxLength": maxLength,
      "rowData": rowData,
      "optionList": optionList?.map((option) => option.toJson()).toList(),
      "message": message,
      "validationPattern": validationPattern,
      "directiveType": directiveType,
      "dependentList": dependentList?.map((dep) => dep.toJson()).toList(),
      "operationKey": operationKey,
      "enabledDefault": enabledDefault,
      "isDisable": isDisable,
      "defaultValue": defaultValue,
      "columnInfoList": columnInfoList?.map((col) => col.toJson()).toList(),
      "disableDropdown": disableDropdown,
      "enableLimiterValidation": enableLimiterValidation,
    };
  }

  /// Parses option data into a list of [Option] objects.
  static List<Option>? _parseOptionList(optionJson) {
    if (optionJson == null) {
      return [];
    }

    // Handle the nested structure with "myArrayList" or "values"
    if (optionJson is Map<String, dynamic>) {
      final list = optionJson["myArrayList"] ?? optionJson["values"];
      if (list != null && list is List) {
        return list.map((item) {
          final map =
              (item["map"] ?? item["nameValuePairs"]) as Map<String, dynamic>;
          return Option(key: map["key"], pairValue: map["value"]);
        }).toList();
      }
    }

    // Existing logic for other cases
    if (optionJson is List) {
      return optionJson.map((e) => Option.fromJson(e)).toList();
    }

    return [];
  }

  /// Maps a control type string to a [FieldType].
  static FieldType _mapControlType(String type, {String? key}) {
    if (key == "guarantorEntityId") {
      return FieldType.entityIdField;
    }

    if (key == "accountNo" ||
        key == "account_number" ||
        key == "accountNumber") {
      return FieldType.accountNo;
    }

    switch (type.toLowerCase()) {
      case "textbox":
        return FieldType.textField;
      case "dropdown":
        return FieldType.dropdown;
      case "editabledropdown":
        return FieldType.editableDropdown;
      case "datepicker":
        return FieldType.datePicker;
      case "grid":
        return FieldType.grid;
      case "singlecheckbox":
        return FieldType.singleCheckBox;
      case "checkbox":
        return FieldType.checkbox;
      case "percentage":
        return FieldType.percentage;
      case "currency":
        return FieldType.currency;
      case "multiselect":
        return FieldType.multiSelect;
      case "customersearch":
        return FieldType.customerSearch;
      case "amount":
        return FieldType.amount;
      case "tenorcontrol":
        return FieldType.tenorControl;
      case "conditionaltextbox":
        return FieldType.conditionalTextbox;
      case "radiobutton":
        return FieldType.radioButton;
      case "textarea":
        return FieldType.textArea;
      case "table":
        return FieldType.table;
      case "referencedatadropdown":
        return FieldType.refDataDropdown;
      case "conditionaldropdown":
        return FieldType.conditionaldropdown;
      case "countrydropdown":
        return FieldType.countryDropdown;
      case "sizedBox":
        return FieldType.sizedBox;
      case "accountNumber":
        return FieldType.accountNo;
      case "label":
        return FieldType.label;
      default:
        return FieldType.none;

      // map more control type
      // throw Exception("Unknown control type: $type");
    }
  }
}

/// Represents a key-value option used in dropdown controls.
class Option extends CustomDropdownItem {
  /// Creates an [Option].
  Option({required this.key, required this.pairValue, this.metaData})
      : super(label: key, value: pairValue);

  /// Creates an [Option] from JSON.
  factory Option.fromJson(Map<String, dynamic> json) {
    return Option(
      key: json["key"].toString(),
      pairValue: json["value"],
    );
  }

  /// Option key.
  final String? key;

  /// Option value.
  final String? pairValue;

  /// Additional metadata associated with the option.
  dynamic metaData;

  /// Converts this option to JSON.
  Map<String, dynamic> toJson() {
    return {
      "key": key,
      "value": pairValue,
    };
  }
}
