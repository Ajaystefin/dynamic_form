import "package:flutter_test/flutter_test.dart";
import "package:wcas_frontend/core/components/dynamic_form/models/field.dart";
import "package:wcas_frontend/core/components/dynamic_form/models/row_element.dart";
import "package:wcas_frontend/core/components/dynamic_form/models/section.dart";

void main() {
  group("Section", () {
    test("creates Section with all properties", () {
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
      );

      final row1 = RowElement(number: 1, fields: [field1]);
      final row2 = RowElement(number: 2, fields: [field2]);
      final section = Section(number: 1, type: "main", rows: [row1, row2]);

      expect(section.number, 1);
      expect(section.type, "main");
      expect(section.rows, isNotNull);
      expect(section.rows?.length, 2);
      expect(section.rows?[0], row1);
      expect(section.rows?[1], row2);
    });

    test("creates Section with null rows", () {
      final section = Section(rows: null);

      expect(section.rows, null);
    });

    test("creates Section with empty rows list", () {
      final section = Section(rows: []);

      expect(section.rows, isNotNull);
      expect(section.rows?.length, 0);
    });

    test("creates Section with mixed row content", () {
      final field = DynamicField(
        controlType: FieldType.textField,
        key: "field",
        label: "Field",
        required: true,
        rowData: 1,
        enabledDefault: true,
        isDisable: false,
      );

      final rowWithFields = RowElement(fields: [field]);
      final rowWithoutFields = RowElement(fields: []);
      final rowWithNullFields = RowElement(fields: null);

      final section =
          Section(rows: [rowWithFields, rowWithoutFields, rowWithNullFields]);

      expect(section.rows?.length, 3);
      expect(section.rows?[0].fields?.length, 1);
      expect(section.rows?[1].fields?.length, 0);
      expect(section.rows?[2].fields, null);
    });

    group("fromJson", () {
      test("creates Section from JSON with all fields", () {
        final json = {
          "sectionNumber": 1,
          "sectionClass": "main",
          "rowList": [
            {
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
            }
          ],
        };

        final section = Section.fromJson(json);

        expect(section.number, 1);
        expect(section.type, "main");
        expect(section.rows?.length, 1);
        expect(section.rows?[0].number, 1);
        expect(section.rows?[0].fields?.length, 1);
      });

      test("creates Section from JSON with null rowList", () {
        final json = {
          "sectionNumber": 2,
          "sectionClass": "secondary",
          "rowList": null,
        };

        final section = Section.fromJson(json);

        expect(section.number, 2);
        expect(section.type, "secondary");
        expect(section.rows, null);
      });
    });

    group("toJson", () {
      test("converts Section to JSON with rows", () {
        final field = DynamicField(
          controlType: FieldType.textField,
          key: "test_field",
          label: "Test Field",
          required: true,
          rowData: 1,
          enabledDefault: true,
          isDisable: false,
        );

        final row = RowElement(number: 1, fields: [field]);
        final section = Section(number: 3, type: "test", rows: [row]);

        final json = section.toJson();

        expect(json["sectionNumber"], 3);
        expect(json["sectionClass"], "test");
        expect(json["rowList"], isA<List>());
        expect((json["rowList"] as List).length, 1);
      });

      test("converts Section to JSON with null rows", () {
        final section = Section(number: 4, type: "empty", rows: null);

        final json = section.toJson();

        expect(json["sectionNumber"], 4);
        expect(json["sectionClass"], "empty");
        expect(json.containsKey("rowList"), false);
      });
    });
  });
}
