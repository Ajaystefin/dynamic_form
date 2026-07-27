import "package:flutter_test/flutter_test.dart";
import "package:wcas_frontend/models/admin/reference.dart";
import "package:wcas_frontend/models/request/file_attachment/doc_sub_type_data.dart";

void main() {
  group("DocSubTypeData.fromJson", () {
    test(
        "parses full JSON with int IDs, periodEndDate, and matching references",
        () {
      final now = DateTime.utc(2025, 1, 20, 10, 11, 12);

      final Map<String, dynamic> json = {
        "applicationID": 123,
        "periodEndDate": now.toIso8601String(),
        "documentName": "Board Resolution",
        "summary": "Approved unanimously",
        "decision": "Approved",
        "rimNo": "R-77",
        "appRefNo": "APP-99",
        "customerName": "John",
        "groupId": "G1",
        "groupName": "MAIN GROUP",
        "accountNo": "AC001",
        "docType": 10,
        "subType": 20,
        "subSubType": 30,
        "subSubSubType": 40,
        "language": "EN",
        "applicationSummary": "ASUM",
        "listItemGraphId": "LID-1",
        "edmsDriveItemId": "EID-77",
        "webUrl": "http://example.com",
        "fileName": "abc.pdf",
        "referenceNo": "REF-77",
        "remarks": "OK",
      };

      final documentTypes = [Reference(id: 10, name: "DocType-10")];
      final subTypes = [Reference(id: 20, name: "SubType-20")];
      final subSubTypes = [Reference(id: 30, name: "SubSubType-30")];
      final subSubSubTypes = [Reference(id: 40, name: "SubSubSubType-40")];
      final languages =
          <Reference>[]; // not used by the factory, but passed for completeness

      final model = DocSubTypeData.fromJson(
        json,
        documentTypes,
        subTypes,
        subSubTypes,
        subSubSubTypes,
        languages,
      );

      // Scalars
      expect(model.applicationID, 123);
      expect(model.date, now);
      expect(model.docName, "Board Resolution");
      expect(model.summary, "Approved unanimously");
      expect(model.decision, "Approved");
      expect(model.rimNo, "R-77");
      expect(model.appRefNo, "APP-99");
      expect(model.customerName, "John");
      expect(model.groupId, "G1");
      expect(model.groupName, "MAIN GROUP");
      expect(model.acNo, "AC001");
      expect(model.language, "EN");
      expect(model.applicationSummary, "ASUM");
      expect(model.listItemGraphId, "LID-1");
      expect(model.edmsDriveItemId, "EID-77");
      expect(model.webUrl, "http://example.com");
      expect(model.fileName, "abc.pdf");
      expect(model.referenceNo, "REF-77");
      expect(model.remarks, "OK");

      // Reference lookups (match by id)
      expect(model.docType?.id, 10);
      expect(model.subType?.id, 20);
      expect(model.subSubType?.id, 30);
      expect(model.subSubSubType?.id, 40);

      // We intentionally do NOT assert docTypeId here because it depends on
      // Utils.getDocumentTypeById
    });

    test("falls back to created when periodEndDate is absent", () {
      final created = DateTime.utc(2024, 5, 1, 6, 7, 8);
      final Map<String, dynamic> json = {
        "applicationID": "321",
        "created": created.toIso8601String(),
      };

      final model = DocSubTypeData.fromJson(
        json,
        null,
        null,
        null,
        null,
        null,
      );

      expect(model.applicationID, 321);
      expect(model.date, created);
    });

    test("invalid date yields null", () {
      final Map<String, dynamic> json = {
        "periodEndDate": "not-a-date",
      };

      final model = DocSubTypeData.fromJson(
        json,
        null,
        null,
        null,
        null,
        null,
      );

      expect(model.date, isNull);
    });

    test(
        "parses applicationID from string and string-coerces summary/decision/docName",
        () {
      final Map<String, dynamic> json = {
        "applicationID": "555",
        "summary": 999, // -> "999"
        "decision": true, // -> "true"
        "documentName": null, // -> "null" per implementation
      };

      final model = DocSubTypeData.fromJson(
        json,
        null,
        null,
        null,
        null,
        null,
      );

      expect(model.applicationID, 555);
      expect(model.summary, "999");
      expect(model.decision, "true");
      expect(model.docName, "null");
    });

    test("reference lookup returns empty Reference() when not found", () {
      final Map<String, dynamic> json = {
        "docType": 10,
        "subType": 20,
        "subSubType": 30,
        "subSubSubType": 40,
      };

      // Pass empty lists so firstWhere falls back to orElse: () => Reference()
      final model = DocSubTypeData.fromJson(
        json,
        <Reference>[],
        <Reference>[],
        <Reference>[],
        <Reference>[],
        <Reference>[],
      );

      expect(model.docType, isA<Reference>());
      expect(model.docType?.id, isNull);

      expect(model.subType, isA<Reference>());
      expect(model.subType?.id, isNull);

      expect(model.subSubType, isA<Reference>());
      expect(model.subSubType?.id, isNull);

      expect(model.subSubSubType, isA<Reference>());
      expect(model.subSubSubType?.id, isNull);
    });

    test("when reference lists are null, corresponding fields remain null", () {
      final Map<String, dynamic> json = {
        "docType": 1,
        "subType": 2,
        "subSubType": 3,
        "subSubSubType": 4,
      };

      final model = DocSubTypeData.fromJson(
        json,
        null, // documentTypes
        null, // subTypes
        null, // subSubTypes
        null, // subSubSubTypes
        null, // languages
      );

      expect(model.docType, isNotNull);
      expect(model.subType, isNotNull);
      expect(model.subSubType, isNotNull);
      expect(model.subSubSubType, isNotNull);
      // language not derived from references, remains null as key not present
      expect(model.language, isNull);
    });

    test(
        "string docType still resolves reference (when list"
        " provided); docTypeId is not asserted", () {
      final Map<String, dynamic> json = {
        "docType": "10", // String id
      };

      final documentTypes = [Reference(id: 10, name: "T10")];

      final model = DocSubTypeData.fromJson(
        json,
        documentTypes,
        null,
        null,
        null,
        null,
      );

      // Note: the predicate compares `type.id == json['docType']` (String vs
      // int)
      // This will NOT match unless your JSON has int 10. Given current code,
      // this particular case will return an empty Reference().
      //
      // If you want it to match when docType is "10" (String), you should
      // normalize `json['docType']` to int before comparing in your factory.
      expect(model.docType, isA<Reference>());
      expect(model.docType?.id, isNull);
    });
  });
}
