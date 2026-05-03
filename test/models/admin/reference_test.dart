import "package:flutter_test/flutter_test.dart";
import "package:wcas_frontend/models/admin/reference.dart";

void main() {
  group("Reference", () {
    test(
        "fromJson creates Reference object correctly with"
        " milliseconds since epoch dates", () {
      final Map<String, dynamic> json = {
        "referenceDataListId": 1,
        "name": "Test Ref",
        "description": "Description",
        "status": "Active",
        "reference1": "Ref1",
        "reference2": "Ref2",
        "reference3": "Ref3",
        "reference4": "Ref4",
        "reference5": "Ref5",
        "createdBy": "UserA",
        "createdDate": 1678886400000, // March 15, 2023 12:00:00 PM GMT
        "updatedBy": "UserB",
        "updatedDate": 1678886400000,
      };

      final reference = Reference.fromJson(json);

      expect(reference.id, 1);
      expect(reference.name, "Test Ref");
      expect(reference.description, "Description");

      expect(reference.reference1, "Ref1");
      expect(reference.reference2, "Ref2");
      expect(reference.reference3, "Ref3");
      expect(reference.reference4, "Ref4");
      expect(reference.reference5, "Ref5");
    });

    test("fromJson creates Reference object correctly with string dates", () {
      final Map<String, dynamic> json = {
        "referenceDataListId": 2,
        "name": "Test Ref 2",
        "description": "Description 2",
        "status": "Inactive",
        "createdBy": "UserC",
        "createdDate": "2023-03-16T10:00:00.000Z",
        "updatedBy": "UserD",
        "updatedDate": "2023-03-17T11:00:00.000Z",
      };

      final reference = Reference.fromJson(json);

      expect(reference.id, 2);
    });

    test("fromJson handles null dates correctly", () {
      final Map<String, dynamic> json = {
        "referenceDataListId": 3,
        "name": "Test Ref 3",
        "description": "Description 3",
        "status": "Active",
        "createdBy": "UserE",
        "createdDate": null,
        "updatedBy": "UserF",
        "updatedDate": null,
      };

      final reference = Reference.fromJson(json);

      expect(reference.id, 3);
      expect(reference.createdDate, isNull);
      expect(reference.updatedDate, isNull);
    });
  });
}
