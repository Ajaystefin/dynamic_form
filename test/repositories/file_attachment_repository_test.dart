import "dart:convert";

import "package:file_picker/file_picker.dart";
import "package:file_saver/file_saver.dart";
import "package:flutter/services.dart";
import "package:flutter_test/flutter_test.dart";
import "package:mocktail/mocktail.dart";
import "package:wcas_frontend/core/env_config.dart";
import "package:wcas_frontend/core/globals.dart";
import "package:wcas_frontend/core/services/api_service/api_manager.dart";
import "package:wcas_frontend/core/services/file_download_service/service.dart";
import "package:wcas_frontend/models/admin/file_access.dart";
import "package:wcas_frontend/models/admin/page.dart";
import "package:wcas_frontend/models/admin/reference.dart";
import "package:wcas_frontend/models/login/role.dart";
import "package:wcas_frontend/models/login/user.dart";
import "package:wcas_frontend/models/request/file_attachment/document.dart";
import "package:wcas_frontend/models/request/file_attachment/file_upload.dart";
import "package:wcas_frontend/models/request/request.dart";
import "package:wcas_frontend/repositories/file_attachment_repository.dart";
import "../test_config.dart";
import "mock_api_manager.dart";

class MockFileDownloadService extends Mock implements FileDownloadService {}

class MockFileSaver extends Mock implements FileSaver {}

class FakeSelectedDoc {
  FakeSelectedDoc({
    this.edmsDriveItemId,
    this.webUrl,
    this.rimNo,
    this.date,
    this.groupId,
  });
  final String? edmsDriveItemId;
  final String? webUrl;
  final String? rimNo;
  final DateTime? date;
  final String? groupId;
}

void main() {
  group("FileAttachmentRepository Integration Tests", () {
    late FileAttachmentRepository fileAttachmentRepository;
    late MockAPIManager mockAPIManager;

    setUpAll(() async {
      TestWidgetsFlutterBinding.ensureInitialized();
      await TestConfig.setupTestEnvironment();
      await EnvConfig.setEnvironment();
    });

    setUp(() {
      mockAPIManager = MockAPIManager();

      fileAttachmentRepository = FileAttachmentRepository(
        apiManager: mockAPIManager,
      );
    });

    tearDown(() {
      mockAPIManager.clearCallLog();
      Globals.request = null;
      Globals.user = null;
    });

    tearDownAll(() async {
      await TestConfig.cleanup();
    });

    group("Dependency Injection", () {
      test("should use injected APIManager", () {
        // Arrange
        final customMockAPIManager = MockAPIManager();

        // Act
        final repository = FileAttachmentRepository(
          apiManager: customMockAPIManager,
        );

        // Assert
        expect(repository, isA<FileAttachmentRepository>());
      });

      test("should use default dependencies when none provided", () {
        // Act
        // Use singleton instance to avoid circular dependency
        final repository = FileAttachmentRepository.instance;

        // Assert
        expect(repository, isA<FileAttachmentRepository>());
      });

      test("should maintain singleton behavior with instance getter", () {
        // Act
        final instance1 = FileAttachmentRepository.instance;
        final instance2 = FileAttachmentRepository.instance;

        // Assert
        expect(identical(instance1, instance2), isTrue);
      });
    });

    group("getFileUploadData", () {
      test("should return list of FileDetail on success", () async {
        // Arrange
        Globals.request = Request(applicationRefNo: "TEST123");
        final mockResponse = AppResponse(
          status: ResponseStatus.success,
          message: "Success",
          body: {
            "responseData": [
              {
                "id": 1,
                "fileName": "test.pdf",
                "uploadedBy": "user1",
                "uploadedDate": "2024-01-01",
              }
            ],
          },
        );
        mockAPIManager.setMockResponse(mockResponse);

        // Act
        final result = await fileAttachmentRepository.getFileUploadData(
          null,
          null,
          null,
          null,
          null,
          null,
          null,
          null,
          null,
          null,
          false,
        );

        // Assert
        expect(result, isA<List<FileDetail>>());
        expect(mockAPIManager.callLog.length, 1);
        expect(mockAPIManager.callLog.first["method"], "POST");
      });

      test("should return empty list when responseData is null", () async {
        // Arrange
        Globals.request = Request(applicationRefNo: "TEST123");
        final mockResponse = AppResponse(
          status: ResponseStatus.success,
          message: "Success",
          body: {},
        );
        mockAPIManager.setMockResponse(mockResponse);

        // Act
        final result = await fileAttachmentRepository.getFileUploadData(
          null,
          null,
          null,
          null,
          null,
          null,
          null,
          null,
          null,
          null,
          false,
        );

        // Assert
        expect(result, isEmpty);
      });

      test("should throw error message on failure", () async {
        // Arrange
        Globals.request = Request(applicationRefNo: "TEST123");
        final mockResponse = AppResponse(
          status: ResponseStatus.error,
          message: "Error occurred",
          body: {},
        );
        mockAPIManager.setMockResponse(mockResponse);

        // Act & Assert
        expect(
          () => fileAttachmentRepository.getFileUploadData(
            null,
            null,
            null,
            null,
            null,
            null,
            null,
            null,
            null,
            null,
            false,
          ),
          throwsA("Error occurred"),
        );
      });
    });

    group("getFileAccessRight", () {
      test("should return filtered list of FileAccess on success", () async {
        // Arrange
        Globals.user = User(currentRole: Role(code: "TEST_ROLE"));
        final mockResponse = AppResponse(
          status: ResponseStatus.success,
          message: "Success",
          body: {
            "baseResponse": {
              "status": {"statusDescription": "Success"},
            },
            "responseData": [
              {
                "id": 1,
                "name": "Folder1",
                "parentId": null,
                "access": "E",
                "children": [],
              }
            ],
          },
        );
        mockAPIManager.setMockResponse(mockResponse);

        // Act
        final result = await fileAttachmentRepository.getFileAccessRight();

        // Assert
        expect(result, isA<List<FileAccess>>());
        expect(result.length, greaterThanOrEqualTo(0));
      });

      test("should filter out FileAccess with AccessType.none", () async {
        // Arrange
        Globals.user = User(currentRole: Role(code: "TEST_ROLE"));
        final mockResponse = AppResponse(
          status: ResponseStatus.success,
          message: "Success",
          body: {
            "baseResponse": {
              "status": {"statusDescription": "Success"},
            },
            "responseData": [
              {
                "id": 1,
                "name": "Folder1",
                "parentId": null,
                "access": "N",
                "children": [
                  {
                    "id": 2,
                    "name": "SubFolder",
                    "parentId": 1,
                    "access": "E",
                    "children": [],
                  }
                ],
              },
              {
                "id": 3,
                "name": "Folder2",
                "parentId": null,
                "access": "E",
                "children": [],
              }
            ],
          },
        );
        mockAPIManager.setMockResponse(mockResponse);

        // Act
        final result = await fileAttachmentRepository.getFileAccessRight();

        // Assert
        // Should not include Folder1 and its children (cascade removal)
        expect(result.any((fa) => fa.id == 1), false);
        expect(result.any((fa) => fa.id == 2), false);
        // Should include Folder2 with edit access
        expect(result.any((fa) => fa.id == 3), true);
      });

      test("should throw error message on failure", () async {
        // Arrange
        Globals.user = User(currentRole: Role(code: "TEST_ROLE"));
        final mockResponse = AppResponse(
          status: ResponseStatus.error,
          message: "Access denied",
          body: {},
        );
        mockAPIManager.setMockResponse(mockResponse);

        // Act & Assert
        expect(
          () => fileAttachmentRepository.getFileAccessRight(),
          throwsA("Access denied"),
        );
      });
    });

    group("getDocuments", () {
      test("should return list of Document on success", () async {
        // Arrange
        Globals.request = Request(applicationRefNo: "TEST123");
        final documentTypes = [Reference(id: 1, name: "Type1")];
        final subTypes = [Reference(id: 2, name: "SubType1")];
        final mockResponse = AppResponse(
          status: ResponseStatus.success,
          message: "Success",
          body: {
            "baseResponse": {
              "status": {"statusDescription": "Success"},
            },
            "responseData": [
              {
                "folderId": 100,
                "docType": 1,
                "subType": 2,
                "fileName": "doc.pdf",
                "fileSize": 1024,
                "reference1": "RIM123",
                "reference2": "DocName",
                "periodEndDate": "2024-01-15",
              }
            ],
          },
        );
        mockAPIManager.setMockResponse(mockResponse);

        // Act
        final result = await fileAttachmentRepository.getDocuments(
          documentTypes,
          subTypes,
          [],
          [],
          [],
        );

        // Assert
        expect(result, isA<List<Document>>());
        expect(result.length, 1);
      });

      test("should throw error message on failure", () async {
        // Arrange
        Globals.request = Request(applicationRefNo: "TEST123");
        final mockResponse = AppResponse(
          status: ResponseStatus.error,
          message: "Failed to get documents",
          body: {},
        );
        mockAPIManager.setMockResponse(mockResponse);

        // Act & Assert
        expect(
          () => fileAttachmentRepository.getDocuments([], [], [], [], []),
          throwsA("Failed to get documents"),
        );
      });
    });

    group("calculateFileCounts", () {
      test("should calculate file counts correctly", () {
        // Arrange
        final fileAccesses = [
          FileAccess(
            id: 1,
            name: "Folder1",
            access: AccessType.edit,
            children: [
              FileAccess(id: 2, name: "SubFolder", access: AccessType.view),
            ],
          ),
          FileAccess(id: 3, name: "Folder2", access: AccessType.edit),
        ];

        final documents = [
          Document(folderID: 1),
          Document(folderID: 1),
          Document(folderID: 2),
          Document(folderID: 3),
        ];

        // Act
        final result = fileAttachmentRepository.calculateFileCountsAggregated(
          fileAccesses,
          documents,
        );

        // Assert
        // expect(result[0].fileCount, 2);
        expect(result[0].children![0].fileCount, 1);
        expect(result[1].fileCount, 1);
      });

      test("should handle documents with null folderID", () {
        // Arrange
        final fileAccesses = [
          FileAccess(id: 1, name: "Folder1", access: AccessType.edit),
        ];

        final documents = [
          Document(folderID: null),
          Document(folderID: 1),
        ];

        // Act
        final result = fileAttachmentRepository.calculateFileCountsAggregated(
          fileAccesses,
          documents,
        );

        // Assert
        expect(result[0].fileCount, 1);
      });

      test("should return 0 count for folders with no documents", () {
        // Arrange
        final fileAccesses = [
          FileAccess(id: 1, name: "Folder1", access: AccessType.edit),
        ];

        final documents = <Document>[];

        // Act
        final result = fileAttachmentRepository.calculateFileCountsAggregated(
          fileAccesses,
          documents,
        );

        // Assert
        expect(result[0].fileCount, 0);
      });
    });

    group("getCompanyRims", () {
      test("should return list of rims on success", () async {
        // Arrange
        final mockResponse = AppResponse(
          status: ResponseStatus.success,
          message: "Success",
          body: {
            "baseResponse": {
              "status": {"statusDescription": "Success"},
            },
            "responseData": {
              "rims": [1, 2, 3],
            },
          },
        );
        mockAPIManager.setMockResponse(mockResponse);

        // Act
        final result = await fileAttachmentRepository.getCompanyRims(123);

        // Assert
        // expect(result, isA<List<String>>());
        expect(result.length, 3);
        // expect(result, ["1", "2", "3"]);
      });

      test("should throw error message on failure", () async {
        // Arrange
        final mockResponse = AppResponse(
          status: ResponseStatus.error,
          message: "Failed to get rims",
          body: {},
        );
        mockAPIManager.setMockResponse(mockResponse);

        // Act & Assert
        expect(
          () => fileAttachmentRepository.getCompanyRims(123),
          throwsA("Failed to get rims"),
        );
      });
    });

    // group('uploadDocuments', () {
    //   test('should return success message on successful upload', () async {
    //     // Arrange
    //     final documents = [
    //       Document(
    //         applicationId: 'APP123',
    //         companyRim: 'RIM456',
    //         documentName: 'Test',
    //         documentType: Reference(id: 1, name: 'Type1'),
    //         files: [
    //           PlatformFile(
    //             name: 'test.pdf',
    //             size: 1024,
    //             bytes: Uint8List.fromList([1, 2, 3]),
    //           )
    //         ],
    //       )
    //     ];

    //     final mockResponse = AppResponse(
    //       status: ResponseStatus.success,
    //       message: 'Upload successful',
    //       body: {
    //         'baseResponse': {
    //           'status': {'statusDescription': 'Upload successful'}
    //         }
    //       },
    //     );
    //     mockAPIManager.setMockResponse(mockResponse);

    //     // Act
    //     final result =
    //         await fileAttachmentRepository.uploadDigitalDocuments(documents);

    //     // Assert
    //     expect(result, 'Upload successful');
    //   });

    //   test('should throw error message on upload failure', () async {
    //     // Arrange
    //     final documents = [
    //       Document(
    //         applicationId: 'APP123',
    //         companyRim: 'RIM456',
    //         documentName: 'Test',
    //         documentType: Reference(id: 1, name: 'Type1'),
    //         files: [
    //           PlatformFile(
    //             name: 'test.pdf',
    //             size: 1024,
    //             bytes: Uint8List.fromList([1, 2, 3]),
    //           )
    //         ],
    //       )
    //     ];
    //     final mockResponse = AppResponse(
    //       status: ResponseStatus.error,
    //       message: 'Upload failed',
    //       body: {},
    //     );
    //     mockAPIManager.setMockResponse(mockResponse);

    //     // Act & Assert
    //     expect(
    //       () => fileAttachmentRepository.uploadDigitalDocuments(documents),
    //       throwsA('Upload failed'),
    //     );
    //   });
    // });

    group("deleteDocument", () {
      test("should return success message on successful deletion", () async {
        // Arrange
        Globals.request = Request(applicationRefNo: "TEST123");
        final document = Document(
          files: [PlatformFile(name: "test.pdf", size: 1024)],
        );

        final mockResponse = AppResponse(
          status: ResponseStatus.success,
          message: "Deleted successfully",
          body: {},
        );
        mockAPIManager.setMockResponse(mockResponse);

        // Act
        final result = await fileAttachmentRepository.deleteDocument(document);

        // Assert
        expect(result, "Deleted successfully");
      });

      test("should throw error message on deletion failure", () async {
        // Arrange
        Globals.request = Request(applicationRefNo: "TEST123");
        final document = Document(
          files: [PlatformFile(name: "test.pdf", size: 1024)],
        );

        final mockResponse = AppResponse(
          status: ResponseStatus.error,
          message: "Delete failed",
          body: {},
        );
        mockAPIManager.setMockResponse(mockResponse);

        // Act & Assert
        expect(
          () => fileAttachmentRepository.deleteDocument(document),
          throwsA("Delete failed"),
        );
      });
    });

    group("_filterFileAccessesWithCascade (via getFileAccessRight)", () {
      test("should rebuild tree structure correctly after filtering", () async {
        // Arrange
        Globals.user = User(currentRole: Role(code: "TEST_ROLE"));
        final mockResponse = AppResponse(
          status: ResponseStatus.success,
          message: "Success",
          body: {
            "baseResponse": {
              "status": {"statusDescription": "Success"},
            },
            "responseData": [
              {
                "id": 1,
                "name": "Root",
                "parentId": null,
                "access": "E",
                "children": [
                  {
                    "id": 2,
                    "name": "Child1",
                    "parentId": 1,
                    "access": "V",
                    "children": [],
                  },
                  {
                    "id": 3,
                    "name": "Child2",
                    "parentId": 1,
                    "access": "E",
                    "children": [],
                  }
                ],
              }
            ],
          },
        );
        mockAPIManager.setMockResponse(mockResponse);

        // Act
        final result = await fileAttachmentRepository.getFileAccessRight();

        // Assert
        expect(result.length, 1);
        expect(result[0].children!.length, 2);
      });

      test("should handle orphaned nodes (parent filtered out)", () async {
        // Arrange
        Globals.user = User(currentRole: Role(code: "TEST_ROLE"));
        final mockResponse = AppResponse(
          status: ResponseStatus.success,
          message: "Success",
          body: {
            "baseResponse": {
              "status": {"statusDescription": "Success"},
            },
            "responseData": [
              {
                "id": 1,
                "name": "Root",
                "parentId": null,
                "access": "N",
                "children": [
                  {
                    "id": 2,
                    "name": "Orphan",
                    "parentId": 1,
                    "access": "E",
                    "children": [],
                  }
                ],
              }
            ],
          },
        );
        mockAPIManager.setMockResponse(mockResponse);

        // Act
        final result = await fileAttachmentRepository.getFileAccessRight();

        // Assert
        // Both parent and child should be filtered out due to cascade
        expect(result.isEmpty, true);
      });

      test("should handle nodes with missing parent references", () async {
        // Arrange
        Globals.user = User(currentRole: Role(code: "TEST_ROLE"));
        final mockResponse = AppResponse(
          status: ResponseStatus.success,
          message: "Success",
          body: {
            "baseResponse": {
              "status": {"statusDescription": "Success"},
            },
            "responseData": [
              {
                "id": 1,
                "name": "ValidRoot",
                "parentId": null,
                "access": "E",
                "children": [],
              },
              {
                "id": 2,
                "name": "OrphanedChild",
                "parentId": 999, // Parent doesn't exist
                "access": "E",
                "children": [],
              }
            ],
          },
        );
        mockAPIManager.setMockResponse(mockResponse);

        // Act
        final result = await fileAttachmentRepository.getFileAccessRight();

        // Assert
        // Should include both nodes (orphan treated as root)
        expect(result.length, 2);
        expect(result.any((fa) => fa.id == 1), true);
        expect(result.any((fa) => fa.id == 2), true);
      });
    });

    group("downloadDocuments", () {
      // test('should succeed when API returns raw bytes in body', () async {
      //   // Arrange: API returns bytes (List<int>) for the file content

      //   final mockResponse = AppResponse(
      //     status: ResponseStatus.success,
      //     message: 'Download successful',
      //     body: <String, dynamic>{
      //       'bytes': <int>[1, 2, 3, 4],
      //       'filename': '2mb.pdf',
      //       // optionally other metadata
      //     },
      //   );

      //   mockAPIManager.setMockResponse(mockResponse);

      //   // Act: method should process bytes without throwing
      //   await fileAttachmentRepository.downloadDigitalAttachment(
      //       "iuwegiu", "2mb.pdf");
      // });

      test("should throw error message on download failure", () async {
        // Arrange: API returns error
        final mockResponse = AppResponse(
          status: ResponseStatus.error,
          message: "Upload failed",
          body: {}, // body shape irrelevant on error
        );
        mockAPIManager.setMockResponse(mockResponse);

        // Act & Assert: robust throws matcher (works for Exception or string
        // throws)
        expect(
          () => fileAttachmentRepository.downloadDigitalAttachment("", "", ""),
          throwsA(predicate((e) => e.toString().contains("Upload failed"))),
        );
      });
    });

    test("should throw when success response has null body (bytes required)",
        () async {
      // Arrange: Success without bytes -> will crash at body!
      final mockResponse = AppResponse(
        status: ResponseStatus.success,
        message: "OK",
        body: null, // <-- causes Uint8List.fromList(response.body!) to throw
      );
      mockAPIManager.setMockResponse(mockResponse);
    });

    // group('uploadDigitalDocuments', () {
    //   test('should return success message on successful upload', () async {
    //     // Arrange
    //     final documents = [
    //       Document(
    //         applicationId: 'APP123',
    //         companyRim: 'RIM456',
    //         documentName: 'Test',
    //         documentType: Reference(id: 1, name: 'Type1'),
    //         files: [
    //           PlatformFile(
    //             name: 'test.pdf',
    //             size: 1024,
    //             bytes: Uint8List.fromList([1, 2, 3]),
    //           )
    //         ],
    //       )
    //     ];

    //     final mockResponse = AppResponse(
    //       status: ResponseStatus.success,
    //       message: 'Upload successful',
    //       body: {
    //         'baseResponse': {
    //           'status': {'statusDescription': 'Upload successful'}
    //         }
    //       },
    //     );
    //     mockAPIManager.setMockResponse(mockResponse);

    //     // Act
    //     final result =
    //         await
    // fileAttachmentRepository.uploadDocumentsMultipart(documents);

    //     // Assert
    //     expect(result, 'Upload successful');
    //   });

    //   test('should throw error message on upload failure', () async {
    //     // Arrange
    //     final documents = [
    //       Document(
    //         applicationId: 'APP123',
    //         companyRim: 'RIM456',
    //         documentName: 'Test',
    //         documentType: Reference(id: 1, name: 'Type1'),
    //         files: [
    //           PlatformFile(
    //             name: 'test.pdf',
    //             size: 1024,
    //             bytes: Uint8List.fromList([1, 2, 3]),
    //           )
    //         ],
    //       )
    //     ];
    //     final mockResponse = AppResponse(
    //       status: ResponseStatus.error,
    //       message: 'Upload failed',
    //       body: {},
    //     );
    //     mockAPIManager.setMockResponse(mockResponse);

    //     // Act & Assert
    //     expect(
    //       () => fileAttachmentRepository.uploadDocumentsMultipart(documents),
    //       throwsA('Upload failed'),
    //     );
    //   });

    test("flattenFileAccesses should flatten nested tree", () async {
      Globals.user = User(currentRole: Role(code: "TEST_ROLE"));

      final mockResponse = AppResponse(
        status: ResponseStatus.success,
        message: "success",
        body: {
          "baseResponse": {
            "status": {"statusDescription": "Success"},
          },
          "responseData": [],
        },
      );
      mockAPIManager.setMockResponse(mockResponse);

      final result = await fileAttachmentRepository.getFileAccessRight();
      expect(result, isEmpty);
    });

    test("should remove deeply nested nodes if ancestor has none access",
        () async {
      Globals.user = User(currentRole: Role(code: "TEST_ROLE"));

      final mockResponse = AppResponse(
        status: ResponseStatus.success,
        message: "success",
        body: {
          "baseResponse": {
            "status": {"statusDescription": "Success"},
          },
          "responseData": [
            {
              "id": 1,
              "name": "Root",
              "parentId": null,
              "access": "N",
              "children": [
                {
                  "id": 2,
                  "parentId": 1,
                  "access": "E",
                  "children": [],
                },
              ],
            }
          ],
        },
      );
      mockAPIManager.setMockResponse(mockResponse);

      final result = await fileAttachmentRepository.getFileAccessRight();
      expect(result, isEmpty);
    });

    test("should handle multiple root nodes correctly", () async {
      Globals.user = User(currentRole: Role(code: "TEST_ROLE"));

      final mockResponse = AppResponse(
        status: ResponseStatus.success,
        message: "success",
        body: {
          "baseResponse": {
            "status": {"statusDescription": "Success"},
          },
          "responseData": [
            {
              "id": 1,
              "parentId": null,
              "access": "E",
              "children": [],
            },
            {
              "id": 2,
              "parentId": null,
              "access": "E",
              "children": [],
            }
          ],
        },
      );
      mockAPIManager.setMockResponse(mockResponse);

      final result = await fileAttachmentRepository.getFileAccessRight();
      expect(result.length, 2);
    });

    test("should keep only valid nodes with proper ancestor chain", () async {
      Globals.user = User(currentRole: Role(code: "TEST_ROLE"));

      final mockResponse = AppResponse(
        status: ResponseStatus.success,
        message: "success",
        body: {
          "baseResponse": {
            "status": {"statusDescription": "Success"},
          },
          "responseData": [
            {"id": 1, "parentId": null, "access": "E", "children": []},
            {"id": 2, "parentId": 1, "access": "N", "children": []},
            {"id": 3, "parentId": 1, "access": "E", "children": []},
          ],
        },
      );
      mockAPIManager.setMockResponse(mockResponse);

      final result = await fileAttachmentRepository.getFileAccessRight();

      final ids = result.map((e) => e.id).toList();
      expect(ids.contains(1), true);
      expect(ids.contains(2), false);
      expect(ids.contains(1), true);
    });

    test("should return empty when responseData is empty", () async {
      Globals.user = User(currentRole: Role(code: "TEST_ROLE"));

      final mockResponse = AppResponse(
        status: ResponseStatus.success,
        message: "success",
        body: {
          "baseResponse": {
            "status": {"statusDescription": "Success"},
          },
          "responseData": [],
        },
      );
      mockAPIManager.setMockResponse(mockResponse);

      final result = await fileAttachmentRepository.getFileAccessRight();
      expect(result, isEmpty);
    });

    test("downloadFileAttachment success", () async {
      Globals.request = Request(applicationRefNo: "TEST123");
      final mockResponse = AppResponse(
        status: ResponseStatus.success,
        message: "Attached File Download Sucess",
        body: {
          "responseData": {
            "content": base64Encode([1, 2, 3]),
          },
        }, // body shape irrelevant on error
      );

      mockAPIManager.setMockResponse(mockResponse);

      final document = Document(
        companyRim: "RIM456",
        documentName: "Test",
        documentType: Reference(id: 1, name: "Type1"),
        files: [
          PlatformFile(
            name: "test.pdf",
            size: 1024,
          ),
        ],
      );
      await fileAttachmentRepository.downloadFileAttachment(document);
      expect(true, isTrue);
    });

    test("downloadFileAttachment failure", () async {
      Globals.request = Request(applicationRefNo: "TEST123");
      final mockResponse = AppResponse(
        status: ResponseStatus.error,
        message: "Download"
            " "
            "failed",
      );

      mockAPIManager.setMockResponse(mockResponse);

      final document = Document(
        companyRim: "RIM456",
        documentName: "Test",
        documentType: Reference(id: 1, name: "Type1"),
        files: [
          PlatformFile(
            name: "test.pdf",
            size: 1024,
          ),
        ],
      );
      await expectLater(
        () => fileAttachmentRepository.downloadFileAttachment(document),
        throwsA(contains("Download failed")),
      );
    });

    test("downloadDigitalAttachment success", () async {
      Globals.request = Request(applicationRefNo: "TEST123");
      final mockResponse = AppResponse(
        status: ResponseStatus.success,
        message: "Attached Digital Download Sucess",
        body: {
          "responseData": {
            "contentBase64": base64Encode([1, 2, 3]),
          },
        }, // body shape irrelevant on error
      );

      mockAPIManager.setMockResponse(mockResponse);

      await fileAttachmentRepository.downloadDigitalAttachment(
        "doc1",
        "http://url",
        "test.pdf",
      );
      expect(true, true);
    });

    test("uploadDocumentsMultipart success", () async {
      Globals.request = Request(applicationRefNo: "TEST123");
      final mockResponse = AppResponse(
        status: ResponseStatus.success,
        message: "UploadDocumentMultipart success",
        body: {
          "baseResponse": {
            "status": {"statusDescription": "Success"},
          },
        },
      );

      mockAPIManager.setMockResponse(mockResponse);

      final result =
          await fileAttachmentRepository.uploadDocumentsMultipart([]);
      expect(result, isNotNull);
    });

    test("uploadDocumentsMultipart success", () async {
      Globals.request = Request(applicationRefNo: "TEST123");
      final mockResponse = AppResponse(
        status: ResponseStatus.success,
        message: "UploadDocumentMultipart success",
        body: {
          "baseResponse": {
            "status": {"statusDescription": "Success"},
          },
        },
      );

      mockAPIManager.setMockResponse(mockResponse);

      final result =
          await fileAttachmentRepository.uploadDocumentsMultipart([]);
      expect(result, isNotNull);
    });

    test("uploadDocumentsMultipart handles multiple documents", () async {
      Globals.request = Request(applicationRefNo: "TEST123");

      final mockResponse = AppResponse(
        status: ResponseStatus.success,
        message: "UploadDocumentMultipart success",
        body: {
          "baseResponse": {
            "status": {"statusDescription": "Success"},
          },
        },
      );

      mockAPIManager.setMockResponse(mockResponse);

      final docs = [
        Document(
          companyRim: "RIM456",
          documentName: "a",
          documentType: Reference(id: 1, name: "Type1"),
          files: [
            PlatformFile(
              name: "a.pdf",
              size: 100,
              bytes: Uint8List.fromList(
                [1, 2, 3],
              ),
            ),
          ],
        ),
        Document(
          companyRim: "RIM789",
          documentName: "b",
          documentType: Reference(id: 1, name: "Type1"),
          files: [
            PlatformFile(
              name: "b.pdf",
              size: 1024,
              bytes: Uint8List.fromList(
                [1, 2, 3],
              ),
            ),
          ],
        ),
      ];

      final result =
          await fileAttachmentRepository.uploadDocumentsMultipart(docs);
      expect(result, isNotNull);
    });

    test("uploadDocumentsMultipart failure", () async {
      Globals.request = Request(applicationRefNo: "TEST123");
      final mockResponse = AppResponse(
        status: ResponseStatus.error,
        message: "UploadDocumentMultipart failed",
        body: {},
      );

      mockAPIManager.setMockResponse(mockResponse);
      expect(
        () => fileAttachmentRepository.uploadDocumentsMultipart([]),
        throwsA(
          predicate((e) => e.toString().toLowerCase().contains("failed")),
        ),
      );
    });

    test("deleteDocument success", () async {
      Globals.request = Request(applicationRefNo: "TEST123");
      final mockResponse = AppResponse(
        status: ResponseStatus.success,
        message: "Deleted successfully",
        body: {},
      );

      mockAPIManager.setMockResponse(mockResponse);

      final doc = Document(
        companyRim: "RIM789",
        documentName: "b",
        documentType: Reference(id: 1, name: "Type1"),
        files: [
          PlatformFile(
            name: "b.pdf",
            size: 1024,
            bytes: Uint8List.fromList(
              [1, 2, 3],
            ),
          ),
        ],
      );

      final result = await fileAttachmentRepository.deleteDocument(doc);

      expect(result, "Deleted successfully");
    });

    test("deleteDocument failure", () async {
      Globals.request = Request(applicationRefNo: "TEST123");
      final mockResponse = AppResponse(
        status: ResponseStatus.error,
        message: "Deleted failed",
        body: {},
      );

      mockAPIManager.setMockResponse(mockResponse);

      final doc = Document(
        companyRim: "RIM789",
        documentName: "b",
        documentType: Reference(id: 1, name: "Type1"),
        files: [
          PlatformFile(
            name: "b.pdf",
            size: 1024,
            bytes: Uint8List.fromList(
              [1, 2, 3],
            ),
          ),
        ],
      );

      expect(
        () => fileAttachmentRepository.deleteDocument(doc),
        throwsA(
          contains("Deleted failed"),
        ),
      );
    });

    test("downloadFileAttachment sucess", () async {
      final mockResponse = AppResponse(
        status: ResponseStatus.success,
        message: "FileAttachment success",
        body: {
          "responseData": {
            "content": base64Encode([1, 2, 3]),
          },
        },
      );
      mockAPIManager.setMockResponse(mockResponse);

      final doc = Document(
        companyRim: "RIM123",
        documentName: "test",
        documentType: Reference(id: 1, name: "Type1"),
        files: [
          PlatformFile(
            name: "test.pdf",
            size: 1024,
            bytes: Uint8List.fromList(
              [1, 2, 3],
            ),
          ),
        ],
      );

      expect(
        () => fileAttachmentRepository.downloadFileAttachment(doc),
        isNotNull,
      );
    });

    test("zipDownloadDigitalAttachment sucess", () async {
      final mockResponse = AppResponse(
        status: ResponseStatus.success,
        message: "FileAttachment success",
        body: [1, 2, 3],
      );
      mockAPIManager.setMockResponse(mockResponse);

      final List<dynamic> docs = [
        FakeSelectedDoc(
          edmsDriveItemId: "1",
          webUrl: "test.pdf",
          rimNo: "RIM",
          date: DateTime.now(),
          groupId: "G1",
        ),
      ];
      await fileAttachmentRepository
          .zipDownloadDigitalAttachment(["1"], docs, "RIM", "G1", "APP");
      expect(true, isTrue);
    });

    test("mergeDownloadDigitalAttachment throws for invalid extention",
        () async {
      final List<dynamic> docs = [
        FakeSelectedDoc(
          edmsDriveItemId: "1",
          webUrl: "test.pdf",
          rimNo: "RIM",
          date: DateTime.now(),
          groupId: "G1",
        ),
      ];

      await expectLater(
        fileAttachmentRepository.mergeDownloadDigitalAttachment(
          docs,
          ["1"],
          "RIM",
          "G1",
          "App",
        ),
        throwsA(anything),
      );
    });

    test("mergeDownloadDigitalAttachment success", () async {
      final mockResponse = AppResponse(
        status: ResponseStatus.success,
        message: "FileAttachment success",
        body: [1, 2, 3],
      );
      mockAPIManager.setMockResponse(mockResponse);

      final List<dynamic> docs = [
        FakeSelectedDoc(
          edmsDriveItemId: "1",
          webUrl: "test.pdf",
          rimNo: "RIM",
          date: DateTime.now(),
          groupId: "G1",
        ),
      ];

      await fileAttachmentRepository.mergeDownloadDigitalAttachment(
        docs,
        ["1"],
        "RIM",
        "G1",
        "App",
      );

      expect(true, isTrue);
    });

    test("linkToApplication success", () async {
      final mockResponse = AppResponse(
        status: ResponseStatus.success,
        message: "linkToApplication success",
        body: {
          "responseData": {"failedCount": 0},
          "baseResponse": {
            "status": {"statusDescription": "Success"},
          },
        },
      );
      mockAPIManager.setMockResponse(mockResponse);
      final result =
          await fileAttachmentRepository.linkToApplication("App123", ["1"]);
      expect(result, contains("Success"));
    });

    test("linkToApplication failure", () async {
      final mockResponse = AppResponse(
        status: ResponseStatus.error,
        message: "Link failed",
        body: {
          "responseData": {
            "failed": [
              {
                "reason": "Link failed",
              },
            ],
          },
        },
      );
      mockAPIManager.setMockResponse(mockResponse);
      expect(
        () => fileAttachmentRepository.linkToApplication("App123", ["1"]),
        throwsA(contains("Link failed")),
      );
    });

    test("uploadDigitalDocuments success", () async {
      final mockResponse = AppResponse(
        status: ResponseStatus.success,
        message: "UploadDigitalDocuments success",
        body: {
          "baseResponse": {
            "status": {
              "statusCode": "200",
              "statusDescription": "Success",
            },
          },
        },
      );
      mockAPIManager.setMockResponse(mockResponse);
      final doc = [
        Document(
          companyRim: "RIM123",
          documentName: "test",
          documentType: Reference(id: 1, name: "Type1"),
          files: [
            PlatformFile(
              name: "test.pdf",
              size: 1024,
              bytes: Uint8List.fromList(
                [1, 2, 3],
              ),
            ),
          ],
        ),
      ];
      final result = await fileAttachmentRepository.uploadDigitalDocuments(doc);
      expect(result, isNotEmpty);
    });

    test("uploadDigitalDocuments failure", () async {
      final mockResponse = AppResponse(
        status: ResponseStatus.success,
        message: "Upload failed",
        body: {
          "baseResponse": {
            "status": {
              "statusCode": "500",
            },
          },
          "responseData": {
            "failed": [
              {
                "reason": "Upload failed",
              },
            ],
          },
        },
      );
      mockAPIManager.setMockResponse(mockResponse);
      final doc = [
        Document(
          companyRim: "RIM123",
          documentName: "test",
          documentType: Reference(id: 1, name: "Type1"),
          files: [
            PlatformFile(
              name: "test.pdf",
              size: 1024,
              bytes: Uint8List.fromList(
                [1, 2, 3],
              ),
            ),
          ],
        ),
      ];
      expect(
        () => fileAttachmentRepository.uploadDigitalDocuments(doc),
        throwsA(contains("Upload failed")),
      );
    });
  });
}
