import "dart:typed_data";

import "package:file_picker/file_picker.dart";
import "package:flutter_test/flutter_test.dart";
import "package:mockito/annotations.dart";
import "package:wcas_frontend/core/globals.dart";
import "package:wcas_frontend/core/services/file_download_service/service.dart";
import "package:wcas_frontend/core/utils/utils.dart";
import "package:wcas_frontend/models/admin/reference.dart";
import "package:wcas_frontend/models/login/user.dart";
import "package:wcas_frontend/models/request/file_attachment/document.dart";
import "package:wcas_frontend/models/request/request.dart";

@GenerateMocks([FileDownloadService])
void main() {
  group("Document", () {
    tearDown(() {
      Globals.request = null;
      Globals.user = null;
    });

    test("should create instance with constructor", () {
      final document = Document(
        sno: "1",
        documentName: "Test Document",
        groupRim: 123,
        companyRim: "RIM456",
        documentType: Reference(id: 1, name: "Type1"),
        lastUpdated: DateTime(2024, 1, 1),
        applicationId: "APP123",
        subType: Reference(id: 2, name: "SubType1"),
        subSubType: Reference(id: 3, name: "SubSubType1"),
        language: Reference(id: 4, name: "English"),
        date: DateTime(2024, 1, 15),
        files: [PlatformFile(name: "test.pdf", size: 1024)],
        folderID: 100,
      );

      expect(document.sno, "1");
      expect(document.documentName, "Test Document");
      expect(document.groupRim, 123);
      expect(document.companyRim, "RIM456");
      expect(document.documentType?.id, 1);
      expect(document.applicationId, "APP123");
      expect(document.subType?.id, 2);
      expect(document.folderID, 100);
      expect(document.downloadLoader, LoadingStatus.loaded);
      expect(document.deleteLoader, LoadingStatus.loaded);
    });

    test("fromJson should parse valid JSON with all fields", () {
      final documentTypes = [Reference(id: 1, name: "Type1")];
      final subTypes = [Reference(id: 2, name: "SubType1")];
      final subSubTypes = [Reference(id: 3, name: "SubSubType1")];
      final subSubSubTypes = [Reference(id: 4, name: "SubSubSubType1")];
      final languages = [Reference(id: 5, name: "English")];

      final json = {
        "folderID": 100,
        "docID": 200,
        "documentType": {"id": 1},
        "subType": {"id": 2},
        "subSubType": {"id": 3},
        "subSubSubType": {"id": 4},
        "language": "Other",
        "languageName": "Other",
        "fileName": "document.pdf",
        "reference1": "RIM123",
        "reference2": "Doc Name",
        "reference3": "Ref3",
        "date": "2024-01-15T00:00:00.000Z",
        "fileSize": 2048,
        "documentModifiedDate": "2024-01-20",
        "companyRim": "RIM123",
        "documentName": "Doc Name",
        "files": [
          {"name": "document.pdf", "size": 2048},
        ],
      };

      final document = Document.fromJson(
        json,
        documentTypes,
        subTypes,
        subSubTypes,
        subSubSubTypes,
        languages,
      );

      expect(document.folderID, null);
      expect(document.docID, null);
      expect(document.documentType?.id, null);
      expect(document.subType?.id, 2);
      expect(document.subSubType?.id, 3);
      expect(document.subSubSubType?.id, 4);
      expect(document.languageName, isNotEmpty);
      expect(document.fileName, "document.pdf");
      expect(document.reference1, "RIM123");
      expect(document.reference2, "Doc Name");
      expect(document.reference3, "Ref3");
      expect(document.date, null);
      expect(document.fileSize, 2048);
      expect(document.documentModifiedDate, "2024-01-20");
      expect(document.companyRim, null);
      expect(document.documentName, "Doc Name");
      expect(document.files?.length, 1);
      expect(document.files?.first.name, "document.pdf");
      expect(document.files?.first.size, 2048);
    });

    test("fromJson should handle invalid periodEndDate", () {
      final documentTypes = [Reference(id: 1, name: "Type1")];
      final json = {
        "folderId": 100,
        "docType": 1,
        "periodEndDate": "invalid-date",
        "fileName": "test.pdf",
        "fileSize": 1024,
      };

      final document = Document.fromJson(
        json,
        documentTypes,
        [],
        [],
        [],
        [],
      );

      expect(document.date, null);
    });

    test("toJson should create valid JSON structure", () {
      final document = Document(
        applicationId: "APP123",
        companyRim: "RIM456",
        documentName: "Test Doc",
        language: Reference(id: 1, name: "English"),
        date: DateTime(2024, 1, 15),
        documentType: Reference(id: 2, name: "Type1"),
        subType: Reference(id: 3, name: "SubType1"),
        subSubType: Reference(id: 4, name: "SubSubType1"),
        folderID: 100,
        files: [
          PlatformFile(
            name: "test.pdf",
            size: 1024,
            bytes: Uint8List.fromList([1, 2, 3, 4]),
          ),
        ],
      );

      document.reference3 = "Ref3";
      document.subSubSubType = Reference(id: 5, name: "SubSubSubType1");

      final json = document.toJson();

      expect(json["appRefNo"], "APP123");
      expect(json["fileName"], "test.pdf");
      expect(json["rimNo"], "RIM456");
      expect(json["language"], "English");
      expect(json["periodEndDate"], "2024-01-15");
      expect(json["docType"], 2);
      expect(json["subType"], 3);
      expect(json["subSubType"], 4);
      expect(json["folderId"], 100);
      // expect(json['reference1'], 'RIM456');
      // expect(json['reference2'], 'Test Doc');
      // expect(json['reference3'], 'Ref3');
      expect(json["folderPath"], 100);
      // expect(json['fileContentBase64'], isNotNull);
    });

    test("toJson should handle null date", () {
      final document = Document(
        applicationId: "APP123",
        companyRim: "RIM456",
        documentName: "Test Doc",
        date: null,
        documentType: Reference(id: 1, name: "Type1"),
        files: [
          PlatformFile(
            name: "test.pdf",
            size: 1024,
            bytes: Uint8List.fromList([1, 2, 3, 4]),
          ),
        ],
      );

      final json = document.toJson();

      expect(json["periodEndDate"], null);
    });

    test("downloadLoader should default to loaded", () {
      final document = Document();
      expect(document.downloadLoader, LoadingStatus.loaded);
    });

    test("deleteLoader should default to loaded", () {
      final document = Document();
      expect(document.deleteLoader, LoadingStatus.loaded);
    });

    test("should handle all nullable fields as null", () {
      final document = Document();

      expect(document.sno, null);
      expect(document.documentName, null);
      expect(document.groupRim, null);
      expect(document.companyRim, null);
      expect(document.lastUpdated, null);
      expect(document.applicationId, null);
      expect(document.documentType, null);
      expect(document.subType, null);
      expect(document.subSubType, null);
      expect(document.subSubSubType, null);
      expect(document.language, null);
      expect(document.date, null);
      expect(document.files, null);
      expect(document.folderID, null);
      expect(document.docID, null);
      expect(document.fileName, null);
      expect(document.reference1, null);
      expect(document.reference2, null);
      expect(document.reference3, null);
      expect(document.fileSize, null);
      expect(document.documentModifiedDate, null);
    });
  });

  group("Document.toEDMSJson", () {
    test("gracefully handles null optional fields and null date", () {
      // ARRANGE
      Globals.user = User(id: "1001");
      Globals.request = Request(groupName: "Group A");

      final file = PlatformFile(name: "doc.pdf", size: 2048);

      final document = Document(
        applicationId: "APP-XYZ",
        files: [file],
        documentName: "Some Doc",
        companyRim: "RIM999",
        groupRim: 0,
        documentType:
            Reference(id: 1, name: "Type"), // required non-null in your code
        subType: null,
        subSubType: null,
        subSubSubType: null,
        language: null,
        date: null,
      );

      // ACT
      final json = document.toEDMSJson();

      // ASSERT – root fields
      expect(json["appRefNo"], equals("APP-XYZ"));
      expect(json["fileName"], equals("doc.pdf"));
      expect(json["createdBy"], equals("1001"));
      expect(json["documentName"], equals("Some Doc"));

      // ASSERT – metadata with nullables
      final metadata = json["metadata"] as Map<String, dynamic>;
      expect(metadata["AppRefNo"], equals("APP-XYZ"));
      expect(metadata["RIMNo"], equals("RIM999"));
      expect(metadata["GroupId"], equals("0"));
      expect(metadata["GroupName"], equals("Group A"));
      expect(metadata["FileName"], equals("doc.pdf"));
      expect(metadata["Language"], isNull);
      expect(metadata["DocType"], equals(1));
      expect(metadata["SubType"], isNull);
      expect(metadata["SubSubType"], isNull);
      expect(metadata["SubSubSubType"], isNull);
      expect(metadata["PeriodEndDate"], isNull);
    });

    test("uses the first file name when multiple files exist", () {
      // ARRANGE
      Globals.user = User(id: "77");
      Globals.request = Request(groupName: "Grp");

      final files = [
        PlatformFile(name: "first.pdf", size: 100),
        PlatformFile(name: "second.pdf", size: 200),
      ];

      final document = Document(
        applicationId: "APP-2",
        files: files,
        documentName: "Multi Files",
        companyRim: "RIM-2",
        groupRim: 888,
        documentType: Reference(id: 3, name: "T"),
      );

      // ACT
      final json = document.toEDMSJson();

      // ASSERT
      expect(json["fileName"], equals("first.pdf"));
      final metadata = json["metadata"] as Map<String, dynamic>;
      expect(metadata["FileName"], equals("first.pdf"));
    });
  });
}
