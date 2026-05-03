import "package:flutter_test/flutter_test.dart";
import "package:wcas_frontend/models/request/facility_security/project_list.dart";

void main() {
  group("ProjectListResponse Tests", () {
    test("Constructor assigns values correctly", () {
      const response = ProjectListResponse(["Project A", "Project B"]);
      expect(response.responseData.length, 2);
      expect(response.responseData[0], "Project A");
      expect(response.responseData[1], "Project B");
    });

    test("fromMap parses valid list of strings", () {
      final map = {
        "responseData": ["Project X", "Project Y"],
      };
      final response = ProjectListResponse.fromMap(map);
      expect(response.responseData.length, 2);
      expect(response.responseData.contains("Project X"), true);
      expect(response.responseData.contains("Project Y"), true);
    });

    test("fromMap filters out non-string values", () {
      final map = {
        "responseData": ["Project 1", 123, true, "Project 2", null],
      };
      final response = ProjectListResponse.fromMap(map);
      expect(response.responseData.length, 2);
      expect(response.responseData, ["Project 1", "Project 2"]);
    });

    test("fromMap handles null responseData gracefully", () {
      final map = {"responseData": null};
      final response = ProjectListResponse.fromMap(map);
      expect(response.responseData, isEmpty);
    });

    test("fromMap handles empty list", () {
      final map = {"responseData": []};
      final response = ProjectListResponse.fromMap(map);
      expect(response.responseData, isEmpty);
    });

    test("fromMap handles missing key (no responseData) gracefully => empty",
        () {
      final map = <String, dynamic>{};
      final response = ProjectListResponse.fromMap(map);
      expect(response.responseData, isEmpty);
    });

    test("fromMap throws when responseData is NOT a List (String)", () {
      final map = {"responseData": "not a list"};
      expect(() => ProjectListResponse.fromMap(map), throwsA(isA<TypeError>()));
    });

    test("fromMap throws when responseData is NOT a List (int)", () {
      final map = {"responseData": 42};
      expect(() => ProjectListResponse.fromMap(map), throwsA(isA<TypeError>()));
    });

    test("fromMap throws when responseData is NOT a List (Map)", () {
      final map = {
        "responseData": {"a": 1},
      };
      expect(() => ProjectListResponse.fromMap(map), throwsA(isA<TypeError>()));
    });
  });

  group("BorrowersMap Tests", () {
    test("Constructor assigns values correctly", () {
      const response = BorrowersMap(["Alice", "Bob"]);
      expect(response.responseData.length, 2);
      expect(response.responseData[0], "Alice");
      expect(response.responseData[1], "Bob");
    });

    test("fromMap parses valid list of strings", () {
      final map = {
        "responseData": ["Borrower X", "Borrower Y"],
      };
      final response = BorrowersMap.fromMap(map);
      expect(response.responseData.length, 2);
      expect(response.responseData.contains("Borrower X"), true);
      expect(response.responseData.contains("Borrower Y"), true);
    });

    test("fromMap filters out non-string values", () {
      final map = {
        "responseData": ["Borrower 1", 123, false, "Borrower 2", null],
      };
      final response = BorrowersMap.fromMap(map);
      expect(response.responseData.length, 2);
      expect(response.responseData, ["Borrower 1", "Borrower 2"]);
    });

    test("fromMap handles null responseData gracefully", () {
      final map = {"responseData": null};
      final response = BorrowersMap.fromMap(map);
      expect(response.responseData, isEmpty);
    });

    test("fromMap handles empty list", () {
      final map = {"responseData": []};
      final response = BorrowersMap.fromMap(map);
      expect(response.responseData, isEmpty);
    });

    test("fromMap handles missing key (no responseData) gracefully => empty",
        () {
      final map = <String, dynamic>{};
      final response = BorrowersMap.fromMap(map);
      expect(response.responseData, isEmpty);
    });

    test("fromMap throws when responseData is NOT a List (String)", () {
      final map = {"responseData": "not a list"};
      expect(() => BorrowersMap.fromMap(map), throwsA(isA<TypeError>()));
    });

    test("fromMap throws when responseData is NOT a List (int)", () {
      final map = {"responseData": 42};
      expect(() => BorrowersMap.fromMap(map), throwsA(isA<TypeError>()));
    });

    test("fromMap throws when responseData is NOT a List (Map)", () {
      final map = {
        "responseData": {"a": 1},
      };
      expect(() => BorrowersMap.fromMap(map), throwsA(isA<TypeError>()));
    });
  });
}
