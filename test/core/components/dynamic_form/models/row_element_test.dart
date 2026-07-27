import "package:flutter_test/flutter_test.dart";
import "package:wcas_frontend/core/components/dynamic_form/models/field.dart";
import "package:wcas_frontend/core/components/dynamic_form/models/row_element.dart";

void main() {
  group("RowElement", () {
    test("creates RowElement with list of fields", () {
      final field1 = DynamicField(
        controlType: FieldType.textField,
        key: "field1",
        label: "Field 1",
        required: true,
        rowData: 1,
        enabledDefault: true,
        isDisable: false,
      );

      final field2 = DynamicField(
        controlType: FieldType.dropdown,
        key: "field2",
        label: "Field 2",
        required: false,
        rowData: 1,
        enabledDefault: true,
        isDisable: false,
        optionList: [
          Option(key: "Option 1", pairValue: "value1"),
        ],
      );

      final rowElement = RowElement(fields: [field1, field2]);

      expect(rowElement.fields, isNotNull);
      expect(rowElement.fields?.length, 2);
      expect(rowElement.fields?[0], field1);
      expect(rowElement.fields?[1], field2);
      expect(rowElement.fields?[0].key, "field1");
      expect(rowElement.fields?[1].key, "field2");
    });

    test("creates RowElement with null fields", () {
      final rowElement = RowElement();

      expect(rowElement.fields, null);
    });

    test("creates RowElement with empty fields list", () {
      final rowElement = RowElement(fields: []);

      expect(rowElement.fields, isNotNull);
      expect(rowElement.fields?.length, 0);
    });

    test("creates RowElement with single field", () {
      final field = DynamicField(
        controlType: FieldType.percentage,
        key: "percentage_field",
        label: "Percentage Field",
        required: true,
        rowData: 1,
        enabledDefault: false,
        isDisable: true,
        maxLength: 5,
        validationPattern: r"^[0-9]+(\.[0-9]+)?$",
        message: "Please enter a valid percentage",
      );

      final rowElement = RowElement(fields: [field]);

      expect(rowElement.fields?.length, 1);
      expect(rowElement.fields?[0].controlType, FieldType.percentage);
      expect(rowElement.fields?[0].key, "percentage_field");
      expect(rowElement.fields?[0].label, "Percentage Field");
      expect(rowElement.fields?[0].required, true);
      expect(rowElement.fields?[0].maxLength, 5);
      expect(rowElement.fields?[0].validationPattern, r"^[0-9]+(\.[0-9]+)?$");
      expect(rowElement.fields?[0].message, "Please enter a valid percentage");
    });

    test("creates RowElement with fields of different types", () {
      final textField = DynamicField(
        controlType: FieldType.textField,
        key: "text_field",
        label: "Text Field",
        required: true,
        rowData: 1,
        enabledDefault: true,
        isDisable: false,
      );

      final dateField = DynamicField(
        controlType: FieldType.datePicker,
        key: "date_field",
        label: "Date Field",
        required: false,
        rowData: 1,
        enabledDefault: true,
        isDisable: false,
      );

      final checkboxField = DynamicField(
        controlType: FieldType.singleCheckBox,
        key: "checkbox_field",
        label: "Checkbox Field",
        required: false,
        rowData: 1,
        enabledDefault: true,
        isDisable: false,
      );

      final rowElement =
          RowElement(fields: [textField, dateField, checkboxField]);

      expect(rowElement.fields?.length, 3);
      expect(rowElement.fields?[0].controlType, FieldType.textField);
      expect(rowElement.fields?[1].controlType, FieldType.datePicker);
      expect(rowElement.fields?[2].controlType, FieldType.singleCheckBox);
    });

    test("creates RowElement with fields containing all optional properties",
        () {
      final options = [
        Option(key: "Option A", pairValue: "valueA"),
        Option(key: "Option B", pairValue: "valueB"),
      ];

      final field = DynamicField(
        controlType: FieldType.multiSelect,
        key: "multi_field",
        label: "Multi Select Field",
        required: true,
        rowData: 2,
        enabledDefault: false,
        isDisable: true,
        maxLength: 200,
        optionList: options,
        message: "Multi-select validation message",
        validationPattern: r"^[a-zA-Z,\s]*$",
        directiveType: "multi_directive",
        dependentList: options,
        operationKey: "multi_operation",
        defaultValue: "valueA,valueB",
      );

      final rowElement = RowElement(fields: [field]);

      expect(rowElement.fields?.length, 1);
      final testField = rowElement.fields![0];
      expect(testField.controlType, FieldType.multiSelect);
      expect(testField.key, "multi_field");
      expect(testField.label, "Multi Select Field");
      expect(testField.required, true);
      expect(testField.maxLength, 200);
      expect(testField.optionList?.length, 2);
      expect(testField.message, "Multi-select validation message");
      expect(testField.validationPattern, r"^[a-zA-Z,\s]*$");
      expect(testField.directiveType, "multi_directive");
      expect(testField.dependentList?.length, 2);
      expect(testField.operationKey, "multi_operation");
      expect(testField.enabledDefault, false);
      expect(testField.isDisable, true);
      expect(testField.defaultValue, "valueA,valueB");
    });

    group("fromJson", () {
      test("creates RowElement from JSON with all fields", () {
        final json = {
          "rowNumber": 1,
          "controlList": [
            {
              "controlType": "textbox",
              "key": "field1",
              "label": "Field 1",
              "required": true,
              "rowData": 1,
              "enabledDefault": true,
              "isDisable": false,
            }
          ],
        };

        final rowElement = RowElement.fromJson(json);

        expect(rowElement.number, 1);
        expect(rowElement.fields?.length, 1);
        expect(rowElement.fields?[0].key, "field1");
      });

      test("creates RowElement from JSON with null controlList", () {
        final json = {
          "rowNumber": 2,
          "controlList": null,
        };

        final rowElement = RowElement.fromJson(json);

        expect(rowElement.number, 2);
        expect(rowElement.fields, null);
      });
    });

    group("toJson", () {
      test("converts RowElement to JSON with fields", () {
        final field = DynamicField(
          controlType: FieldType.textField,
          key: "test_field",
          label: "Test Field",
          required: true,
          rowData: 1,
          enabledDefault: true,
          isDisable: false,
        );

        final rowElement = RowElement(number: 3, fields: [field]);

        final json = rowElement.toJson();

        expect(json["rowNumber"], 3);
        expect(json["controlList"], isA<List>());
        expect((json["controlList"] as List).length, 1);
      });

      test("converts RowElement to JSON with null fields", () {
        final rowElement = RowElement(number: 4);

        final json = rowElement.toJson();

        expect(json["rowNumber"], 4);
        expect(json.containsKey("controlList"), false);
      });
    });
  });
}
