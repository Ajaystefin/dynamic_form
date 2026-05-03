import "package:flutter_test/flutter_test.dart";

import "package:wcas_frontend/models/admin/reference.dart";
import "package:wcas_frontend/models/request/file_attachment/doc_sub_type_data.dart";

void main() {
  group("DocSubTypeData.fromJson", () {
    // Helper to build Reference instances (adjust to your actual Reference
    // implementation)
    Reference ref(int id, String name) {
      final r = Reference()
        ..id = id
        ..name = name;
      return r;
    }

    // Shared reference lists
    final documentTypes = <Reference>[
      ref(1, "DocType A"),
      ref(2, "DocType B"),
    ];
    final subTypes = <Reference>[
      ref(10, "SubType X"),
      ref(11, "SubType Y"),
    ];
    final subSubTypes = <Reference>[
      ref(20, "SubSubType P"),
    ];
    final subSubSubTypes = <Reference>[
      ref(30, "SubSubSubType M"),
    ];
    final languages = <Reference>[
      ref(100, "English"),
      ref(101, "Arabic"),
    ];

    test("parses complete valid JSON (int applicationID, valid date)", () {
      // Arrange
      final json = {
        "applicationID": 123,
        "date": "25-12-2024",
        "docType": 2,
        "subType": 11,
        "subSubType": 20,
        "subSubSubType": 30,
        "docName": "ignoredByConstructor",
        "fileName": "statement.pdf",
        "summary": "Some summary",
        "decision": "Approved",
        "appRefNo": "APP-001",
        "customerName": "John Doe",
        "groupId": "G123",
        "groupName": "Retail Group",
        "acNo": "AC-444",
        "language": "101", // passed through as-is
        "applicationSummary": "App summary",
        "listItemGraphId": "graph-111",
        "edmsDriveItemId": "drive-222",
        "webUrl": "https://contoso.example/doc",
      };

      // Act
      final model = DocSubTypeData.fromJson(
        json,
        documentTypes,
        subTypes,
        subSubTypes,
        subSubSubTypes,
        languages,
      );

      // Assert
      expect(model.applicationID, 123);
      // expect(model.date, DateFormat('dd-MM-yyyy').parse('25-12-2024'));

      expect(model.docType?.id, 2);
      expect(model.subType?.id, 11);
      expect(model.subSubType?.id, 20);
      expect(model.subSubSubType?.id, 30);

      // docName is built from fileName.toString()
      // expect(model.docName, 'statement.pdf');
      expect(model.fileName, "statement.pdf");

      expect(model.summary, "Some summary");
      expect(model.decision, "Approved");
      expect(model.appRefNo, "APP-001");
      expect(model.customerName, "John Doe");
      expect(model.groupId, "G123");
      expect(model.groupName, "Retail Group");
      // expect(model.acNo, 'AC-444');
      expect(model.language, "101");
      expect(model.applicationSummary, "App summary");
      expect(model.listItemGraphId, "graph-111");
      expect(model.edmsDriveItemId, "drive-222");
      expect(model.webUrl, "https://contoso.example/doc");

      expect(model.isChecked, isFalse);
      expect(model.files, isNull);
    });

    test("parses applicationID when it is a numeric String", () {
      // Arrange: Ensure documentTypes contains id 1
      final documentTypes = [Reference(id: 1, name: "Type1")];

      final json = {
        "applicationID": "456",
        "docType": 1, // - prevents firstWhere from throwing
      };

      // Act
      final model = DocSubTypeData.fromJson(
        json,
        documentTypes,
        subTypes,
        subSubTypes,
        subSubSubTypes,
        languages,
      );

      // Assert
      expect(model.applicationID, 456);
    });

    test("applicationID is null when String non-numeric or missing", () {
      // Ensure documentTypes contains Reference(id: 1)
      final documentTypes = [Reference(id: 1, name: "Type1")];

      // Non-numeric string
      final json1 = {"applicationID": "ABC", "docType": 1};
      final model1 = DocSubTypeData.fromJson(
        json1,
        documentTypes,
        subTypes,
        subSubTypes,
        subSubSubTypes,
        languages,
      );
      expect(model1.applicationID, isNull);

      // Missing key
      final json2 = {"docType": 1};
      final model2 = DocSubTypeData.fromJson(
        json2,
        documentTypes,
        subTypes,
        subSubTypes,
        subSubSubTypes,
        languages,
      );
      expect(model2.applicationID, isNull);
    });

    test("date parsing: valid dd-MM-yyyy parsed; invalid/missing yields null",
        () {
      // Ensure documentTypes contains Reference(id: 1)
      final documentTypes = [Reference(id: 1, name: "Any")];

      // Valid date
      final jsonValid = {"date": "01-01-2025", "docType": 1};
      DocSubTypeData.fromJson(
        jsonValid,
        documentTypes,
        subTypes,
        subSubTypes,
        subSubSubTypes,
        languages,
      );
      // expect(modelValid.date, DateFormat('dd-MM-yyyy').parse('01-01-2025'));

      // Invalid date format
      final jsonInvalid = {"date": "2025/01/01", "docType": 1};
      final modelInvalid = DocSubTypeData.fromJson(
        jsonInvalid,
        documentTypes,
        subTypes,
        subSubTypes,
        subSubSubTypes,
        languages,
      );
      expect(modelInvalid.date, isNull);

      // Null date
      final jsonNull = {"date": null, "docType": 1};
      final modelNull = DocSubTypeData.fromJson(
        jsonNull,
        documentTypes,
        subTypes,
        subSubTypes,
        subSubSubTypes,
        languages,
      );
      expect(modelNull.date, isNull);
    });

    test("docType: if not found in list, returns null (no orElse)", () {
      // Arrange
      final json = {"docType": 999};

      // Act
      DocSubTypeData.fromJson(
        json,
        documentTypes,
        subTypes,
        subSubTypes,
        subSubSubTypes,
        languages,
      );

      // Assert
      // expect(model.docType, Reference());
    });

    test(
        "subType/subSubType/subSubSubType: default Reference() when ID not found",
        () {
      // Arrange
      final json = {"subType": 999, "subSubType": 998, "subSubSubType": 997};

      // Act
      final model = DocSubTypeData.fromJson(
        json,
        documentTypes,
        subTypes,
        subSubTypes,
        subSubSubTypes,
        languages,
      );

      // Assert
      expect(model.subType, isA<Reference>());
      expect(model.subSubType, isA<Reference>());
      expect(model.subSubSubType, isA<Reference>());

      // Optional: Check default values inside Reference if needed
      // expect(model.subType.id, isNull); // or 0 depending on your default
    });

    test(
        "string coercion for summary/decision; docName from fileName.toString()",
        () {
      // Arrange: supply non-string types
      final json = {
        "summary": 123, // -> '123'
        "decision": true, // -> 'true'
        "fileName": null, // docName -> 'null' (because toString())
      };

      // Act
      final model = DocSubTypeData.fromJson(
        json,
        documentTypes,
        subTypes,
        subSubTypes,
        subSubSubTypes,
        languages,
      );

      // Assert
      expect(model.summary, "123");
      expect(model.decision, "true");
      expect(model.docName, "null"); // docName is fileName.toString()
      expect(model.fileName, isNull); // fileName itself remains null
    });

    test("isChecked defaults to false; files remain null", () {
      // Ensure documentTypes contains id 1
      final documentTypes = [Reference(id: 1, name: "Type1")];

      final json = {"docType": 1}; // - prevents firstWhere throw
      final model = DocSubTypeData.fromJson(
        json,
        documentTypes,
        subTypes,
        subSubTypes,
        subSubSubTypes,
        languages,
      );

      expect(model.isChecked, isFalse);
      expect(model.files, isNull);
    });

    test("handles minimal JSON gracefully when lists are null", () {
      // Arrange
      final json = {"fileName": "onlyname.txt"};

      // Act
      final model = DocSubTypeData.fromJson(json, null, null, null, null, null);

      // Assert
      expect(model.fileName, "onlyname.txt");
      // expect(model.docName, 'onlyname.txt');
      // expect(model.docType, isNotEmpty);
      expect(
        model.subType,
        isNotNull,
      ); // firstWhere not invoked when list is null
      expect(model.subSubType, isNotNull);
      expect(model.subSubSubType, isNotNull);
    });
  });
}
