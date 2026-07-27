import "package:test/test.dart";
import "package:wcas_frontend/models/admin/reference.dart";
import "package:wcas_frontend/models/request/file_attachment/doc_sub_type.dart";
import "package:wcas_frontend/models/request/file_attachment/doc_sub_type_data.dart";

void main() {
  group("DocSubTypeDetail.fromJson", () {
    test("parses name and attributes correctly", () {
      // ARRANGE
      final json = {
        "name": "Financial Documents",
        "attributes": {
          "someKey": "someValue",
        },
      };

      final documentTypes = [Reference(id: 1, name: "Type1")];
      final subTypes = [Reference(id: 2, name: "SubType")];
      final subSubTypes = [Reference(id: 3, name: "SubSubType")];
      final subSubSubTypes = [Reference(id: 4, name: "SubSubSubType")];
      final languages = [Reference(id: 5, name: "English")];

      // ACT
      final detail = DocSubTypeDetail.fromJson(
        json,
        documentTypes,
        subTypes,
        subSubTypes,
        subSubSubTypes,
        languages,
      );

      // ASSERT
      expect(detail.name, equals("Financial Documents"));
      expect(detail.data, isA<DocSubTypeData>());
    });

    test("sets data to null when attributes is missing", () {
      // ARRANGE
      final json = {
        "name": "No Attributes",
      };

      final refs = [Reference(id: 1, name: "Type")];

      // ACT
      final detail = DocSubTypeDetail.fromJson(
        json,
        refs,
        refs,
        refs,
        refs,
        refs,
      );

      // ASSERT
      expect(detail.name, equals("No Attributes"));
      expect(detail.data, isNull);
    });

    test("parses name even when non-string input is given", () {
      // ARRANGE
      final json = {
        "name": 12345,
        "attributes": null,
      };

      final refs = [Reference(id: 1, name: "Type")];

      // ACT
      final detail = DocSubTypeDetail.fromJson(
        json,
        refs,
        refs,
        refs,
        refs,
        refs,
      );

      // ASSERT
      expect(detail.name, equals("12345")); // .toString()
      expect(detail.data, isNull);
    });
  });
}
