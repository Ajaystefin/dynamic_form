import "package:flutter_test/flutter_test.dart";
import "package:wcas_frontend/models/home/audit.dart";

void main() {
  group("Audit", () {
    test("fromJson creates Audit object correctly", () {
      final Map<String, dynamic> json = {
        "auditId": 1,
        "auditName": "Test Audit",
        "auditDescription": "Description of Test Audit",
        "auditStatus": "Active",
        "auditType": "Type A",
        "auditCategory": "Category X",
        "auditStartDate": 20230101,
        "auditEndDate": 20230131,
        "auditor": "John Doe",
        "auditResult": "Pass",
        "auditScore": 95.5,
        "findings": [
          {"findingId": 101, "description": "Finding 1"},
          {"findingId": 102, "description": "Finding 2"},
        ],
        "recommendations": [
          {"recommendationId": 201, "description": "Recommendation 1"},
          {"recommendationId": 202, "description": "Recommendation 2"},
        ],
        "actionItems": [
          {"actionItemId": 301, "description": "Action Item 1"},
          {"actionItemId": 302, "description": "Action Item 2"},
        ],
        "relatedDocuments": ["doc1.pdf", "doc2.pdf"],
        "createdBy": "Admin",
        "createdDate": 20221201,
        "updatedBy": "Admin",
        "updatedDate": 20230201,
      };

      final audit = Audit.fromJson(json);

      expect(audit.pageId, isNull);
    });

    test("fromJson handles null and missing fields gracefully", () {
      final Map<String, dynamic> json = {};

      final audit = Audit.fromJson(json);

      expect(audit.pageId, isNull);
    });

    test("toJson handles null fields gracefully", () {
      final audit = Audit();
      final json = audit.toJson();

      expect(json["auditId"], isNull);
      expect(json["auditName"], isNull);
      expect(json["auditDescription"], isNull);
      expect(json["auditStatus"], isNull);
      expect(json["auditType"], isNull);
      expect(json["auditCategory"], isNull);
      expect(json["auditStartDate"], isNull);
      expect(json["auditEndDate"], isNull);
      expect(json["auditor"], isNull);
      expect(json["auditResult"], isNull);
      expect(json["auditScore"], isNull);
      expect(json["findings"], isNull);
      expect(json["recommendations"], isNull);
      expect(json["actionItems"], isNull);
      expect(json["relatedDocuments"], isNull);
      expect(json["createdBy"], isNull);
      expect(json["createdDate"], isNull);
      expect(json["updatedBy"], isNull);
      expect(json["updatedDate"], isNull);
    });
  });
}
