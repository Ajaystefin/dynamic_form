import "package:flutter_test/flutter_test.dart";
import "package:wcas_frontend/models/admin/reference.dart";
import "package:wcas_frontend/models/admin/reference_type.dart";

void main() {
  group("ReferenceType", () {
    test("fromJson creates ReferenceType object correctly", () {
      final Map<String, dynamic> json = {
        "referenceDataTypeId": 1,
        "name": "Test Type",
        "description": "Description of test type",
        "status": "Active",
        "referenceDataList": [
          {
            "referenceDataListId": 101,
            "name": "Ref 1",
            "description": "Desc 1",
            "status": "Active",
            "reference1": "Val1",
            "reference2": "Val2",
            "reference3": "Val3",
            "reference4": "Val4",
            "reference5": "Val5",
            "createdBy": "UserA",
            "createdDate": 1678886400000,
            "updatedBy": "UserB",
            "updatedDate": 1678886400000,
          }
        ],
        "columnsInfo": "col1,col2",
      };

      final referenceType = ReferenceType.fromJson(json);

      expect(referenceType.id, 1);
      expect(referenceType.name, "Test Type");
      expect(referenceType.description, "Description of test type");
      expect(referenceType.status, "Active");
      expect(referenceType.references, isNotNull);
      expect(referenceType.references!.length, 1);
      expect(referenceType.references![0].id, 101);
      expect(referenceType.references![0].name, "Ref 1");
      expect(referenceType.columnsInformation, "col1,col2");
    });

    test("toJson converts ReferenceType object to JSON correctly", () {
      final referenceType = ReferenceType(
        id: 1,
        name: "Test Type",
        description: "Description of test type",
        status: "Active",
        references: [
          Reference(
            id: 101,
            name: "Ref 1",
            description: "Desc 1",
            status: "Active",
            reference1: "Val1",
            reference2: "Val2",
            reference3: "Val3",
            reference4: "Val4",
            reference5: "Val5",
            createdBy: "UserA",
            createdDate: DateTime.fromMillisecondsSinceEpoch(1678886400000),
            updatedBy: "UserB",
            updatedDate: DateTime.fromMillisecondsSinceEpoch(1678886400000),
          ),
        ],
      );

      final json = referenceType.toJson();

      expect(json["referenceDataTypeId"], 1);
      expect(json["name"], "Test Type");
      expect(json["description"], "Description of test type");
      expect(json["status"], "Active");
      expect(json["referenceDataList"], isNotNull);
      expect(json["referenceDataList"].length, 1);
      expect(json["referenceDataList"][0]["referenceDataListId"], 101);
      expect(json["referenceDataList"][0]["name"], "Ref 1");
    });

    test("fromJson handles null referenceDataList correctly", () {
      final Map<String, dynamic> json = {
        "referenceDataTypeId": 2,
        "name": "Another Type",
        "description": "No references",
        "status": "Inactive",
        "referenceDataList": null,
        "columnsInfo": null,
      };

      final referenceType = ReferenceType.fromJson(json);

      expect(referenceType.id, 2);
      expect(referenceType.references, isNull);
      expect(referenceType.columnsInformation, isNull);
    });

    test("fromJson handles empty referenceDataList correctly", () {
      final Map<String, dynamic> json = {
        "referenceDataTypeId": 3,
        "name": "Empty Type",
        "description": "Empty references",
        "status": "Active",
        "referenceDataList": [],
        "columnsInfo": "",
      };

      final referenceType = ReferenceType.fromJson(json);

      expect(referenceType.id, 3);
      expect(referenceType.references, isEmpty);
      expect(referenceType.columnsInformation, "");
    });
  });
}
