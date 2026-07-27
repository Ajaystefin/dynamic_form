import "package:flutter_test/flutter_test.dart";
import "package:wcas_frontend/models/admin/file_access.dart";
import "package:wcas_frontend/models/admin/page.dart";

void main() {
  group("FileAccess", () {
    test("fromJson creates FileAccess object correctly", () {
      final Map<String, dynamic> json = {
        "id": "1",
        "name": "Test File",
        "parentId": 0,
        "access": "e",
        "children": [
          {
            "id": "2",
            "name": "Child File",
            "parentId": 1,
            "access": "v",
            "children": [],
          }
        ],
      };

      final fileAccess = FileAccess.fromJson(json);

      expect(fileAccess.id, 1);
      expect(fileAccess.name, "Test File");
      expect(fileAccess.parentId, 0);
      expect(fileAccess.access, AccessType.edit);
      expect(fileAccess.children, isNotNull);
      expect(fileAccess.children!.length, 1);
      expect(fileAccess.children![0].id, 2);
      expect(fileAccess.children![0].name, "Child File");
      expect(fileAccess.children![0].access, AccessType.view);
    });

    test("toJson converts FileAccess object to JSON correctly", () {
      final fileAccess = FileAccess(
        id: 1,
        name: "Test File",
        parentId: 0,
        access: AccessType.edit,
        children: [
          FileAccess(
            id: 2,
            name: "Child File",
            parentId: 1,
            access: AccessType.view,
            children: [],
          ),
        ],
      );

      final json = fileAccess.toJson();

      expect(json["referenceDataListId"], 1);
      expect(json["name"], "Test File");
      expect(json["parentId"], 0);
      expect(json["accessType"], "E");
      expect(json["children"], isNotNull);
      expect(json["children"].length, 1);
      expect(json["children"][0]["referenceDataListId"], 2);
      expect(json["children"][0]["name"], "Child File");
      expect(json["children"][0]["accessType"], "V");
    });

    test("fromJson handles null children correctly", () {
      final Map<String, dynamic> json = {
        "id": "3",
        "name": "No Children",
        "parentId": 0,
        "access": "n",
        "children": null,
      };

      final fileAccess = FileAccess.fromJson(json);

      expect(fileAccess.id, 3);
      expect(fileAccess.name, "No Children");
      expect(fileAccess.children, isEmpty);
    });

    test("fromJson handles empty children list correctly", () {
      final Map<String, dynamic> json = {
        "id": "4",
        "name": "Empty Children",
        "parentId": 0,
        "access": "v",
        "children": [],
      };

      final fileAccess = FileAccess.fromJson(json);

      expect(fileAccess.id, 4);
      expect(fileAccess.name, "Empty Children");
      expect(fileAccess.children, isEmpty);
    });

    test("fromJson handles invalid id gracefully", () {
      final Map<String, dynamic> json = {
        "id": "invalid",
        "name": "Invalid ID",
        "parentId": 0,
        "access": "v",
        "children": [],
      };

      final fileAccess = FileAccess.fromJson(json);

      expect(fileAccess.id, 0); // Expect 0 if parsing fails
      expect(fileAccess.name, "Invalid ID");
    });
  });
}
