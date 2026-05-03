import "package:flutter_test/flutter_test.dart";
import "package:wcas_frontend/core/constants/_server_constants.dart";
import "package:wcas_frontend/core/globals.dart";
import "package:wcas_frontend/models/login/user.dart";
import "package:wcas_frontend/models/request/file_attachment/group_corporate_structure_payload.dart";

void main() {
  group("GroupCorporateStructureCommentPayload.toJson", () {
    test("serializes all fields when provided", () {
      final created = DateTime.utc(2024, 1, 2, 3, 4, 5);
      final updated = DateTime.utc(2024, 6, 7, 8, 9, 10);

      final payload = GroupCorporateStructureCommentPayload(
        appRefNo: "APP-123",
        commentType: "CUSTOM_TYPE",
        comments: "My comment",
        name: "John",
        notes: "Note info",
        createdBy: "creator",
        createdDate: created,
        updatedBy: "editor",
        updatedDate: updated,
        commentId: "CID-88",
        appendixRemarkId: 42,
      );

      final json = payload.toJson();

      expect(json["appRefNo"], "APP-123");
      expect(json["commentType"], "CUSTOM_TYPE");
      expect(json["comments"], "My comment");
      expect(json["name"], "John");
      expect(json["note"], "Note info");
      expect(json["createdBy"], "creator");
      expect(json["createdDate"], created.toIso8601String());
      expect(json["updatedBy"], "editor");
      expect(json["updatedDate"], updated.toIso8601String());
      expect(json["commentId"], "CID-88");
      expect(json["appendixRemarkId"], 42);
    });

    test("omits null optional fields", () {
      const payload = GroupCorporateStructureCommentPayload(
        appRefNo: "APP-1",
        createdBy: "u",
        updatedBy: "u",
      );

      final json = payload.toJson();

      expect(json.containsKey("comments"), false);
      expect(json.containsKey("name"), false);
      expect(json.containsKey("note"), false);
      expect(json.containsKey("commentId"), false);
      expect(json["appendixRemarkId"], null); // included even when null
    });
  });

  group("GroupCorporateStructureCommentPayload.fromContext", () {
    test("builds payload using Globals.user fallback when name is present", () {
      // Arrange: mock user with name
      Globals.user = User(name: "Alice");

      final payload = GroupCorporateStructureCommentPayload.fromContext(
        appRefNo: "APP-999",
        comments: "Hello",
        name: "Tester",
        notes: "Some notes",
        commentId: "CID-1",
        appendixRemarkId: 5,
      );

      // Assert basic fields
      expect(payload.appRefNo, "APP-999");
      expect(payload.commentType, ServerConstants.groupCorporateStucture);
      expect(payload.comments, "Hello");
      expect(payload.name, "Tester");
      expect(payload.notes, "Some notes");
      expect(payload.commentId, "CID-1");
      expect(payload.appendixRemarkId, 5);

      // Assert createdBy & updatedBy from Globals
      expect(payload.createdBy, "Alice");
      expect(payload.updatedBy, "Alice");

      // Dates must be non-null and UTC
      expect(payload.createdDate, isNotNull);
      expect(payload.updatedDate, isNotNull);
      expect(payload.createdDate!.isUtc, true);
      expect(payload.updatedDate!.isUtc, true);
    });

    test('falls back to "system" when Globals.user.name is null/empty', () {
      Globals.user = User(name: "system");

      final payload = GroupCorporateStructureCommentPayload.fromContext(
        appRefNo: "APP-100",
      );

      expect(payload.createdBy, "system");
      expect(payload.updatedBy, "system");
    });

    test("respects explicit commentType override", () {
      Globals.user = User(name: "Alice");

      final payload = GroupCorporateStructureCommentPayload.fromContext(
        appRefNo: "X",
        commentType: "OVERRIDE",
      );

      expect(payload.commentType, "OVERRIDE");
    });
  });
}
