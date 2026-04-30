import "package:flutter_test/flutter_test.dart";
import "package:wcas_frontend/core/components/dynamic_form/models/field.dart";
import "package:wcas_frontend/core/components/dynamic_form/models/grid_field.dart";

void main() {
  group("DynamicGridField", () {
    test("creates DynamicGridField with all properties", () {
      final dynamicField = DynamicField(
        controlType: FieldType.textField,
        key: "grid_key",
        label: "Grid Label",
        required: true,
        rowData: 1,
        enabledDefault: false,
        isDisable: true,
        maxLength: 100,
        validationPattern: r"^[a-zA-Z]+$",
        message: "Test message",
        directiveType: "test_directive",
        defaultValue: "default_value",
      );

      final gridField = DynamicGridField(
        columnTitle: "Test Column",
        dynamicField: dynamicField,
      );

      expect(gridField.columnTitle, "Test Column");
      expect(gridField.dynamicField, dynamicField);
      expect(gridField.dynamicField.controlType, FieldType.textField);
      expect(gridField.dynamicField.key, "grid_key");
      expect(gridField.dynamicField.label, "Grid Label");
      expect(gridField.dynamicField.required, true);
      expect(gridField.dynamicField.maxLength, 100);
      expect(gridField.dynamicField.validationPattern, r"^[a-zA-Z]+$");
      expect(gridField.dynamicField.message, "Test message");
    });

    test("creates DynamicGridField with minimal properties", () {
      final dynamicField = DynamicField(
        controlType: FieldType.dropdown,
        key: "minimal_key",
        label: "Minimal Label",
        required: false,
        rowData: 1,
        enabledDefault: true,
        isDisable: false,
      );

      final gridField = DynamicGridField(
        columnTitle: "Minimal Column",
        dynamicField: dynamicField,
      );

      expect(gridField.columnTitle, "Minimal Column");
      expect(gridField.dynamicField.controlType, FieldType.dropdown);
      expect(gridField.dynamicField.key, "minimal_key");
      expect(gridField.dynamicField.label, "Minimal Label");
      expect(gridField.dynamicField.required, false);
      expect(gridField.dynamicField.enabledDefault, true);
      expect(gridField.dynamicField.isDisable, false);
    });

    group("fromJson", () {
      test("creates DynamicGridField from JSON with all fields", () {
        final json = {
          "columnTitle": "JSON Column",
          "control": {
            "controlType": "textbox",
            "key": "json_key",
            "label": "JSON Label",
            "required": true,
            "rowData": 1,
            "maxLength": 50,
            "validationPattern": r"^\d+$",
            "message": "JSON message",
            "directiveType": "json_directive",
            "enabledDefault": false,
            "isDisable": true,
            "defaultValue": "json_default",
          },
        };

        final gridField = DynamicGridField.fromJson(json);

        expect(gridField.columnTitle, "JSON Column");
        expect(gridField.dynamicField.controlType, FieldType.textField);
        expect(gridField.dynamicField.key, "json_key");
        expect(gridField.dynamicField.label, "JSON Label");
        expect(gridField.dynamicField.required, true);
        expect(gridField.dynamicField.maxLength, 50);
        expect(gridField.dynamicField.validationPattern, r"^\d+$");
        expect(gridField.dynamicField.message, "JSON message");
        expect(gridField.dynamicField.directiveType, "json_directive");
        expect(gridField.dynamicField.enabledDefault, false);
        expect(gridField.dynamicField.isDisable, true);
        expect(gridField.dynamicField.defaultValue, "json_default");
      });

      test("creates DynamicGridField from JSON with minimal fields", () {
        final json = {
          "columnTitle": null,
          "control": {
            "controlType": "dropdown",
            "key": "test_key",
            "label": "Test Label",
            "required": false,
            "rowData": 1,
            "enabledDefault": true,
            "isDisable": false,
          },
        };

        final gridField = DynamicGridField.fromJson(json);

        expect(gridField.columnTitle, "");
        expect(gridField.dynamicField.controlType, FieldType.dropdown);
        expect(gridField.dynamicField.key, "test_key");
        expect(gridField.dynamicField.label, "Test Label");
        expect(gridField.dynamicField.required, false);
        expect(gridField.dynamicField.enabledDefault, true);
        expect(gridField.dynamicField.isDisable, false);
      });
    });

    group("toJson", () {
      test("converts DynamicGridField to JSON", () {
        final dynamicField = DynamicField(
          controlType: FieldType.textField,
          key: "test_key",
          label: "Test Label",
          required: true,
          rowData: 1,
          enabledDefault: false,
          isDisable: true,
          maxLength: 100,
          validationPattern: r"^test$",
          message: "Test message",
          directiveType: "test_directive",
          defaultValue: "test_default",
        );

        final gridField = DynamicGridField(
          columnTitle: "Test Column",
          dynamicField: dynamicField,
        );

        final json = gridField.toJson();

        expect(json["columnTitle"], "Test Column");
        expect(json["controlList"], isA<Map<String, dynamic>>());
        final controlJson = json["controlList"] as Map<String, dynamic>;
        expect(controlJson["controlType"], "textField");
        expect(controlJson["key"], "test_key");
        expect(controlJson["label"], "Test Label");
      });

      test("converts DynamicGridField to JSON with null columnTitle", () {
        final dynamicField = DynamicField(
          controlType: FieldType.dropdown,
          key: "simple_key",
          label: "Simple Label",
          required: false,
          rowData: 1,
          enabledDefault: true,
          isDisable: false,
        );

        final gridField = DynamicGridField(
          columnTitle: null,
          dynamicField: dynamicField,
        );

        final json = gridField.toJson();

        expect(json["columnTitle"], null);
        expect(json["controlList"], isA<Map<String, dynamic>>());
        final controlJson = json["controlList"] as Map<String, dynamic>;
        expect(controlJson["controlType"], "dropdown");
        expect(controlJson["key"], "simple_key");
      });
    });
  });
}
