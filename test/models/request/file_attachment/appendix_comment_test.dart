import "package:flutter_test/flutter_test.dart";
import "package:wcas_frontend/core/utils/date_time_utils.dart";
import "package:wcas_frontend/models/request/file_attachment/appendix_comment.dart";

void main() {
  group("AppendixComment.fromJson", () {
    test("parses full JSON correctly (including trimmed commentType and dates)",
        () {
      // Arrange
      final Map<String, dynamic> json = <String, dynamic>{
        "appRefNo": "APP-123",
        "commentType": "  REVIEW  ", // should be trimmed
        "comments": "Looks good",
        "name": "John Doe",
        "note": "Priority",
        "createdBy": "creatorUser",
        "createdDate": "2025-08-12T10:20:30Z",
        "updatedBy": "updUser",
        "updatedDate": "2025-08-13T11:22:33Z",
        "appendixRemarkId": 987,
      };

      // Act
      final model = AppendixComment.fromJson(json);

      // Assert (use the same util to avoid mismatch due to timezone/format specifics)
      final expectedCreated =
          DateTimeUtils.parseDateTime("2025-08-12T10:20:30Z");
      final expectedUpdated =
          DateTimeUtils.parseDateTime("2025-08-13T11:22:33Z");

      expect(model.appRefNo, "APP-123");
      expect(model.commentType, "REVIEW"); // trimmed + exact content
      expect(model.comments, "Looks good");
      expect(model.name, "John Doe");
      expect(model.note, "Priority");
      expect(model.createdBy, "creatorUser");
      expect(model.createdDate, expectedCreated);
      expect(model.updatedBy, "updUser");
      expect(model.updatedDate, expectedUpdated);
      expect(model.appendixRemarkId, 987);
    });

    test("handles nulls/missing values with safe defaults", () {
      // Arrange
      final Map<String, dynamic> json = <String, dynamic>{};

      // Act
      final model = AppendixComment.fromJson(json);

      // Assert
      expect(model.appRefNo, ""); // defaults to empty string via toString()
      expect(
        model.commentType,
        "",
      ); // defaults to empty string via toString().trim()
      expect(model.comments, ""); // defaults to empty string via toString()
      expect(model.name, isNull);
      expect(model.note, isNull);
      expect(model.createdBy, ""); // defaults to empty string via toString()
      expect(model.createdDate, isNull); // guarded with null check
      expect(model.updatedBy, isNull);
      expect(model.updatedDate, isNull);
      expect(model.appendixRemarkId, isNull);
    });

    test("coerces non-string values to strings where applicable", () {
      // Arrange: ints/numbers should be stringified by `.toString()`
      final Map<String, dynamic> json = <String, dynamic>{
        "appRefNo": 12345,
        "commentType": 777, // becomes "777" then trimmed (no spaces here)
        "comments": 9999,
        "createdBy": 0,
      };

      // Act
      final model = AppendixComment.fromJson(json);

      // Assert
      expect(model.appRefNo, "12345");
      expect(model.commentType, "777");
      expect(model.comments, "9999");
      expect(model.createdBy, "0");
    });

    test("commentType trimming works with whitespace", () {
      // Arrange
      final Map<String, dynamic> json = <String, dynamic>{
        "commentType": "   APPROVER  ",
      };

      // Act
      final model = AppendixComment.fromJson(json);

      // Assert
      expect(model.commentType, "APPROVER");
    });

    test("parses dates only when present; ignores null values", () {
      // Arrange
      final Map<String, dynamic> json = <String, dynamic>{
        "createdDate": "2024-01-02"
            " 13:45:59", // test with a non-ISO format your util supports
        "updatedDate": null,
      };

      // Act
      final model = AppendixComment.fromJson(json);

      // Assert
      // Use the same util to compute the expected interpretation
      final expectedCreated =
          DateTimeUtils.parseDateTime("2024-01-02 13:45:59");
      expect(model.createdDate, expectedCreated);
      expect(model.updatedDate, isNull);
    });

    test("appendixRemarkId can be any JSON scalar (left as-is)", () {
      // Arrange: sometimes backends return as String
      final Map<String, dynamic> json1 = <String, dynamic>{
        "appendixRemarkId": 123,
      };
      final Map<String, dynamic> json2 = <String, dynamic>{
        "appendixRemarkId": 123,
      };

      // Act
      final m1 = AppendixComment.fromJson(json1);
      final m2 = AppendixComment.fromJson(json2);

      // Assert
      expect(m1.appendixRemarkId, 123);
      expect(m2.appendixRemarkId, 123);
    });
  });
}
