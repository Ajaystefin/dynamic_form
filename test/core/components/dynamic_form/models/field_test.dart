import "package:flutter_test/flutter_test.dart";
import "package:wcas_frontend/core/components/dropdown/model.dart";
import "package:wcas_frontend/core/components/dynamic_form/models/field.dart";

void main() {
  group("DynamicField", () {
    test("creates DynamicField with required parameters", () {
      final field = DynamicField(
        controlType: FieldType.textField,
        key: "test_key",
        label: "Test Label",
        required: true,
        rowData: 1,
        enabledDefault: true,
        isDisable: false,
      );

      expect(field.controlType, FieldType.textField);
      expect(field.key, "test_key");
      expect(field.label, "Test Label");
      expect(field.required, true);
      expect(field.rowData, 1);
      expect(field.enabledDefault, true);
      expect(field.isDisable, false);
    });

    test("creates DynamicField with optional parameters", () {
      final options = [
        Option(key: "option1", pairValue: "value1"),
        Option(key: "option2", pairValue: "value2"),
      ];

      final field = DynamicField(
        controlType: FieldType.dropdown,
        key: "test_key",
        label: "Test Label",
        required: false,
        rowData: 2,
        enabledDefault: false,
        isDisable: true,
        maxLength: 100,
        optionList: options,
        message: "Test message",
        validationPattern: r"^[a-zA-Z]*$",
        directiveType: "test_directive",
        dependentList: options,
        operationKey: "test_operation",
        defaultValue: "default_test",
      );

      expect(field.maxLength, 100);
      expect(field.optionList, options);
      expect(field.message, "Test message");
      expect(field.validationPattern, r"^[a-zA-Z]*$");
      expect(field.directiveType, "test_directive");
      expect(field.dependentList, options);
      expect(field.operationKey, "test_operation");
      expect(field.defaultValue, "default_test");
    });

    group("fromJson", () {
      test("creates DynamicField from JSON with all fields", () {
        final json = {
          "controlType": "dropdown",
          "key": "json_key",
          "label": "JSON Label",
          "required": true,
          "maxLength": 50,
          "rowData": 3,
          "optionList": [
            {"key": "opt1", "value": "val1"},
            {"key": "opt2", "value": "val2"},
          ],
          "message": "JSON message",
          "validationPattern": "[0-9]*",
          "directiveType": "json_directive",
          "dependentList": [
            {"key": "dep1", "value": "depval1"},
          ],
          "operationKey": "json_operation",
          "enabledDefault": false,
          "isDisable": true,
          "defaultValue": "json_default",
          "columnInfoList": null,
        };

        final field = DynamicField.fromJson(json);

        expect(field.controlType, FieldType.dropdown);
        expect(field.key, "json_key");
        expect(field.label, "JSON Label");
        expect(field.required, true);
        expect(field.maxLength, 50);
        expect(field.rowData, 3);
        expect(field.message, "JSON message");
        expect(field.validationPattern, "[0-9]*");
        expect(field.directiveType, "json_directive");
        expect(field.operationKey, "json_operation");
        expect(field.enabledDefault, false);
        expect(field.isDisable, true);
        expect(field.defaultValue, "json_default");
        expect(field.optionList?.length, 2);
        expect(field.dependentList?.length, 1);
        expect(field.columnInfoList, null);
      });

      // test('creates DynamicField from JSON with minimal fields', () {
      //   final json = {
      //     'rowData': 1,
      //     'controlType': 'none',
      //   };

      //   final field = DynamicField.fromJson(json);

      //   expect(field.controlType, FieldType.none);
      //   expect(field.key, '');
      //   expect(field.label, '');
      //   expect(field.required, false);
      //   expect(field.rowData, 1);
      //   expect(field.enabledDefault, true);
      //   expect(field.isDisable, false);
      //   expect(field.optionList, null);
      //   expect(field.dependentList, null);
      // });

      // test('creates DynamicField from JSON with null lists', () {
      //   final json = {
      //     'controlType': 'textbox',
      //     'key': 'test',
      //     'label': 'Test',
      //     'required': false,
      //     'rowData': 1,
      //     'optionList': null,
      //     'dependentList': null,
      //     'columnInfoList': null
      //   };

      //   final field = DynamicField.fromJson(json);

      //   expect(field.optionList, null);
      //   expect(field.dependentList, null);
      //   expect(field.columnInfoList, null);
      // });
    });

    group("toJson", () {
      test("converts DynamicField to JSON", () {
        final options = [
          Option(key: "option1", pairValue: "value1"),
        ];

        final field = DynamicField(
          controlType: FieldType.multiSelect,
          key: "test_key",
          label: "Test Label",
          required: true,
          rowData: 2,
          enabledDefault: false,
          isDisable: true,
          maxLength: 75,
          optionList: options,
          message: "Test message",
          validationPattern: r"^test$",
          directiveType: "test_type",
          dependentList: options,
          operationKey: "test_op",
          defaultValue: "test_default",
        );

        final json = field.toJson();

        expect(json["controlType"], "multiSelect");
        expect(json["key"], "test_key");
        expect(json["label"], "Test Label");
        expect(json["required"], true);
        expect(json["maxLength"], 75);
        expect(json["rowData"], 2);
        expect(json["message"], "Test message");
        expect(json["validationPattern"], r"^test$");
        expect(json["directiveType"], "test_type");
        expect(json["operationKey"], "test_op");
        expect(json["enabledDefault"], false);
        expect(json["isDisable"], true);
        expect(json["defaultValue"], "test_default");
        expect(json["optionList"], isA<List>());
        expect(json["dependentList"], isA<List>());
      });

      test("converts DynamicField to JSON with null values", () {
        final field = DynamicField(
          controlType: FieldType.textField,
          key: "simple_key",
          label: "Simple Label",
          required: false,
          rowData: 1,
          enabledDefault: true,
          isDisable: false,
        );

        final json = field.toJson();

        expect(json["optionList"], null);
        expect(json["dependentList"], null);
        expect(json["columnInfoList"], null);
        expect(json["maxLength"], null);
        expect(json["message"], null);
      });
    });

    group("_mapControlType", () {
      test("maps all known control types correctly", () {
        expect(
          DynamicField.fromJson({"controlType": "textbox", "rowData": 1})
              .controlType,
          FieldType.textField,
        );
        expect(
          DynamicField.fromJson({"controlType": "dropdown", "rowData": 1})
              .controlType,
          FieldType.dropdown,
        );
        expect(
          DynamicField.fromJson({"controlType": "datepicker", "rowData": 1})
              .controlType,
          FieldType.datePicker,
        );
        expect(
          DynamicField.fromJson({"controlType": "grid", "rowData": 1})
              .controlType,
          FieldType.grid,
        );
        expect(
          DynamicField.fromJson({"controlType": "singlecheckbox", "rowData": 1})
              .controlType,
          FieldType.singleCheckBox,
        );
        expect(
          DynamicField.fromJson({"controlType": "percentage", "rowData": 1})
              .controlType,
          FieldType.percentage,
        );
        expect(
          DynamicField.fromJson({"controlType": "currency", "rowData": 1})
              .controlType,
          FieldType.currency,
        );
        expect(
          DynamicField.fromJson({"controlType": "multiselect", "rowData": 1})
              .controlType,
          FieldType.multiSelect,
        );
        expect(
          DynamicField.fromJson({"controlType": "customersearch", "rowData": 1})
              .controlType,
          FieldType.customerSearch,
        );
        expect(
          DynamicField.fromJson({"controlType": "amount", "rowData": 1})
              .controlType,
          FieldType.amount,
        );
        expect(
          DynamicField.fromJson({"controlType": "tenorcontrol", "rowData": 1})
              .controlType,
          FieldType.tenorControl,
        );
        expect(
          DynamicField.fromJson(
            {"controlType": "conditionaltextbox", "rowData": 1},
          ).controlType,
          FieldType.conditionalTextbox,
        );
        expect(
          DynamicField.fromJson({"controlType": "radiobutton", "rowData": 1})
              .controlType,
          FieldType.radioButton,
        );
        expect(
          DynamicField.fromJson({"controlType": "textarea", "rowData": 1})
              .controlType,
          FieldType.textArea,
        );
        expect(
          DynamicField.fromJson({"controlType": "table", "rowData": 1})
              .controlType,
          FieldType.table,
        );
        expect(
          DynamicField.fromJson(
            {"controlType": "referencedatadropdown", "rowData": 1},
          ).controlType,
          FieldType.refDataDropdown,
        );
        expect(
          DynamicField.fromJson(
            {"controlType": "conditionaldropdown", "rowData": 1},
          ).controlType,
          FieldType.conditionaldropdown,
        );
        expect(
          DynamicField.fromJson(
            {"controlType": "countrydropdown", "rowData": 1},
          ).controlType,
          FieldType.countryDropdown,
        );
      });

      test("maps unknown control types to none", () {
        expect(
          DynamicField.fromJson({"controlType": "unknown", "rowData": 1})
              .controlType,
          FieldType.none,
        );
        expect(
          DynamicField.fromJson({"controlType": "invalid", "rowData": 1})
              .controlType,
          FieldType.none,
        );
        expect(
          DynamicField.fromJson({"controlType": "", "rowData": 1}).controlType,
          FieldType.none,
        );
      });

      test("handles case insensitivity", () {
        expect(
          DynamicField.fromJson({"controlType": "TEXTBOX", "rowData": 1})
              .controlType,
          FieldType.textField,
        );
        expect(
          DynamicField.fromJson({"controlType": "DropDown", "rowData": 1})
              .controlType,
          FieldType.dropdown,
        );
        expect(
          DynamicField.fromJson({"controlType": "DatePicker", "rowData": 1})
              .controlType,
          FieldType.datePicker,
        );
      });
    });

    group("FieldType enum", () {
      test("contains all expected field types", () {
        expect(FieldType.values.contains(FieldType.textField), true);
        expect(FieldType.values.contains(FieldType.none), true);
        expect(FieldType.values.contains(FieldType.dropdown), true);
        expect(FieldType.values.contains(FieldType.grid), true);
        expect(FieldType.values.contains(FieldType.datePicker), true);
        expect(FieldType.values.contains(FieldType.singleCheckBox), true);
        expect(FieldType.values.contains(FieldType.percentage), true);
        expect(FieldType.values.contains(FieldType.currency), true);
        expect(FieldType.values.contains(FieldType.multiSelect), true);
        expect(FieldType.values.contains(FieldType.customerSearch), true);
        expect(FieldType.values.contains(FieldType.amount), true);
        expect(FieldType.values.contains(FieldType.tenorControl), true);
        expect(FieldType.values.contains(FieldType.conditionalTextbox), true);
        expect(FieldType.values.contains(FieldType.radioButton), true);
        expect(FieldType.values.contains(FieldType.textArea), true);
        expect(FieldType.values.contains(FieldType.refDataDropdown), true);
        expect(FieldType.values.contains(FieldType.table), true);
        expect(FieldType.values.contains(FieldType.conditionaldropdown), true);
        expect(FieldType.values.contains(FieldType.countryDropdown), true);
      });
    });
  });

  group("Option", () {
    test("creates Option with key and pairValue", () {
      final option = Option(key: "test_key", pairValue: "test_value");

      expect(option.key, "test_key");
      expect(option.pairValue, "test_value");
      expect(option.label, "test_key");
      expect(option.value, "test_value");
    });

    test("creates Option from JSON", () {
      final json = {
        "key": "json_key",
        "value": "json_value",
      };

      final option = Option.fromJson(json);

      expect(option.key, "json_key");
      expect(option.pairValue, "json_value");
    });

    test("converts Option to JSON", () {
      final option = Option(key: "test_key", pairValue: "test_value");
      final json = option.toJson();

      expect(json["key"], "test_key");
      expect(json["value"], "test_value");
    });

    test("handles null key and pairValue", () {
      final option = Option(key: null, pairValue: null);

      expect(option.key, null);
      expect(option.pairValue, null);
      expect(option.label, "null");
      expect(option.value, null);
    });

    test("extends CustomDropdownItem correctly", () {
      final option = Option(key: "test", pairValue: "value");
      expect(option, isA<CustomDropdownItem>());
    });
  });
}
