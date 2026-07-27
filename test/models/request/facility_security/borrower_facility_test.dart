import "package:flutter_test/flutter_test.dart";
import "package:wcas_frontend/models/request/facility_security/borrower_facility.dart";

void main() {
  group("Borrower.fromJson", () {
    test("parses full, valid JSON payload correctly", () {
      final json = {
        "applicationBorrowerId": 123,
        "customerRimNo": 1023563,
        "appRefNo": "APP-001",
        "groupId": 77,
        "groupOwner": 88,
        "groupName": "Group A",
        "groupStatus": "Active",
        "firstName": "Pawan",
        "middleName": "K",
        "lastName": "Kumar",
        "preferredName": "PK",
        "customerStatus": "Good",
        "createdBy": "admin",
        "createdDate": "2025-11-01",
        "updatedBy": "system",
        "updatedDate": "2025-11-15",
      };

      final borrower = Borrower.fromJson(json);

      expect(borrower.applicationBorrowerId, 123);
      expect(borrower.customerRimNo, 1023563);
      expect(borrower.appRefNo, "APP-001");
      expect(borrower.groupId, 77);
      expect(borrower.groupOwner, 88);
      expect(borrower.groupName, "Group A");
      expect(borrower.groupStatus, "Active");
      expect(borrower.firstName, "Pawan");
      expect(borrower.middleName, "K");
      expect(borrower.lastName, "Kumar");
      expect(borrower.preferredName, "PK");
      expect(borrower.customerStatus, "Good");
      expect(borrower.createdBy, "admin");
      expect(borrower.createdDate, "2025-11-01");
      expect(borrower.updatedBy, "system");
      expect(borrower.updatedDate, "2025-11-15");
    });

    test("uses defaults when integer keys are missing and keeps others null",
        () {
      final json = {
        // 'applicationBorrowerId' missing -> default 0
        // 'customerRimNo' missing -> default 0
        "appRefNo": null,
        "groupId": null,
        "groupOwner": null,
        "groupName": null,
        "groupStatus": null,
        "firstName": null,
        "middleName": null,
        "lastName": null,
        "preferredName": null,
        "customerStatus": null,
        "createdBy": null,
        "createdDate": null,
        "updatedBy": null,
        "updatedDate": null,
      };

      final borrower = Borrower.fromJson(json);

      expect(borrower.applicationBorrowerId, 0);
      expect(borrower.customerRimNo, 0);
      expect(borrower.appRefNo, isNull);
      expect(borrower.groupId, isNull);
      expect(borrower.groupOwner, isNull);
      expect(borrower.groupName, isNull);
      expect(borrower.groupStatus, isNull);
      expect(borrower.firstName, isNull);
      expect(borrower.middleName, isNull);
      expect(borrower.lastName, isNull);
      expect(borrower.preferredName, isNull);
      expect(borrower.customerStatus, isNull);
      expect(borrower.createdBy, isNull);
      expect(borrower.createdDate, isNull);
      expect(borrower.updatedBy, isNull);
      expect(borrower.updatedDate, isNull);
    });

    test("throws TypeError when integers are provided as wrong types", () {
      final badJson = {
        "applicationBorrowerId": "123", // should be int
        "customerRimNo": "1023563", // should be int
      };

      expect(() => Borrower.fromJson(badJson), throwsA(isA<TypeError>()));
    });
  });

  group("Borrower.displayName", () {
    test(
        "returns preferredName when non-empty after"
        " trim (original value returned)", () {
      final borrower = Borrower(
        applicationBorrowerId: 1,
        customerRimNo: 999,
        preferredName: "  Pawan  ", // non-empty after trim
        lastName: "Kumar",
      );

      // Note: implementation returns the original preferredName (with spaces),
      // not the trimmed value.
      expect(borrower.displayName, "  Pawan  ");
    });

    test("returns lastName when preferredName is empty/whitespace", () {
      final borrower = Borrower(
        applicationBorrowerId: 2,
        customerRimNo: 888,
        preferredName: "   ", // empty after trim
        lastName: "Kumar",
      );

      expect(borrower.displayName, "Kumar");
    });

    test(
        'falls back to "RIM NO <rim>" when both preferredName and lastName are empty/missing',
        () {
      final borrower = Borrower(
        applicationBorrowerId: 3,
        customerRimNo: 1023563,
        lastName: "   ", // whitespace -> empty after trim
      );

      expect(borrower.displayName, "RIM NO 1023563");
    });

    test("fallback uses default rim when JSON left rim missing -> 0", () {
      // Simulate constructing from JSON with missing customerRimNo.
      final borrower = Borrower.fromJson({
        "applicationBorrowerId": 5,
        // customerRimNo missing -> default 0
        "preferredName": "",
        "lastName": "",
      });

      expect(borrower.customerRimNo, 0);
      expect(borrower.displayName, "RIM NO 0");
    });
  });
}
