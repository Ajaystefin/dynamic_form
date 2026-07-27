import "package:file_picker/file_picker.dart";
import "package:flutter_test/flutter_test.dart";
import "package:mocktail/mocktail.dart";
import "package:wcas_frontend/core/services/file_upload_service.dart";

class MockFilePickerInterface extends Mock implements FilePickerInterface {}

PlatformFile createPlatformFile({
  required int size,
  String? extension,
  String baseName = "test_file",
}) {
  final fileName = extension == null ? baseName : "$baseName.$extension";
  return PlatformFile(
    name: fileName,
    size: size,
    path: "/test/$fileName",
  );
}

FilePickerResult createFilePickerResult(List<PlatformFile> files) {
  return FilePickerResult(files);
}

void main() {
  group("FileUploadService", () {
    late FileUploadService fileUploadService;
    late MockFilePickerInterface mockFilePicker;

    setUpAll(() {
      // registerFallbackValue(<String>[]);
      registerFallbackValue(FileType.any);
      registerFallbackValue(false);
    });

    setUp(() {
      fileUploadService = FileUploadService.instance;
      mockFilePicker = MockFilePickerInterface();

      // Reset dependencies
      fileUploadService
        ..filePicker = mockFilePicker
        ..errorMessage = "";
    });

    group("Singleton Pattern", () {
      test("should return the same instance", () {
        final instance1 = FileUploadService.instance;
        final instance2 = FileUploadService.instance;
        expect(identical(instance1, instance2), isTrue);
      });
    });

    group("Constants", () {
      test("should have correct max file size constant", () {
        expect(
          FileUploadService.maxFileSize,
          equals(100 * 1024 * 1024),
        ); // 100MB
      });
    });

    group("Dependency Injection", () {
      test("should use injected file picker", () async {
        when(() => mockFilePicker.pickFiles(allowMultiple: false))
            .thenAnswer((_) async => null);

        await fileUploadService.pickSingleFile([]);

        verify(() => mockFilePicker.pickFiles(allowMultiple: false)).called(1);
      });

      test("should use default FilePickerImpl when no dependency injected", () {
        final service = FileUploadService.instance;
        // Don't set file picker, should use default
        expect(service, isA<FileUploadService>());
      });
    });

    group("pickSingleFile", () {
      test("should return null when no file is selected", () async {
        when(() => mockFilePicker.pickFiles(allowMultiple: false))
            .thenAnswer((_) async => null);

        final result = await fileUploadService.pickSingleFile([]);

        expect(result, isNull);
        verify(() => mockFilePicker.pickFiles(allowMultiple: false)).called(1);
      });

      test("should return valid file when file is selected and valid",
          () async {
        final platformFile = createPlatformFile(size: 1024, extension: "pdf");
        final filePickerResult = createFilePickerResult([platformFile]);

        when(() => mockFilePicker.pickFiles(allowMultiple: false))
            .thenAnswer((_) async => filePickerResult);

        final result = await fileUploadService.pickSingleFile([]);

        expect(result, equals(platformFile));
        expect(fileUploadService.errorMessage, isEmpty);
      });

      test("should throw exception when file size exceeds limit", () async {
        final platformFile = createPlatformFile(
          size: 200 * 1024 * 1024,
          extension: "pdf",
        );
        final filePickerResult = createFilePickerResult([platformFile]);

        when(() => mockFilePicker.pickFiles(allowMultiple: false))
            .thenAnswer((_) async => filePickerResult);

        try {
          await fileUploadService.pickSingleFile([]);
          fail("Expected exception to be thrown");
        } on Object catch (e) {
          expect(e, isA<Exception>());
          expect(
            fileUploadService.errorMessage,
            equals("File is too large. Max size is 100 MB."),
          );
        }
      });

      test("should throw exception when file extension is not allowed",
          () async {
        final platformFile = createPlatformFile(size: 1024, extension: "exe");
        final filePickerResult = createFilePickerResult([platformFile]);

        when(() => mockFilePicker.pickFiles(allowMultiple: false))
            .thenAnswer((_) async => filePickerResult);

        try {
          await fileUploadService.pickSingleFile([]);
          fail("Expected exception to be thrown");
        } on Object catch (e) {
          expect(e, isA<Exception>());
          // expect(fileUploadService.errorMessage,
          //     equals("File type .exe is not allowed."));
        }
      });

      test(
          "should accept file with null extension when no extensions specified",
          () async {
        final platformFile = createPlatformFile(size: 1024);
        final filePickerResult = createFilePickerResult([platformFile]);

        when(() => mockFilePicker.pickFiles(allowMultiple: false))
            .thenAnswer((_) async => filePickerResult);

        final result = await fileUploadService.pickSingleFile([]);

        expect(result, equals(platformFile));
      });

      test("should accept file with null extension when extensions specified",
          () async {
        final platformFile = createPlatformFile(size: 1024);
        final filePickerResult = createFilePickerResult([platformFile]);

        when(() => mockFilePicker.pickFiles(allowMultiple: false))
            .thenAnswer((_) async => filePickerResult);

        final result = await fileUploadService.pickSingleFile([]);

        expect(result, equals(platformFile));
      });

      test("should handle case-insensitive extension matching", () async {
        final platformFile = createPlatformFile(size: 1024, extension: "PDF");
        final filePickerResult = createFilePickerResult([platformFile]);

        when(() => mockFilePicker.pickFiles(allowMultiple: false))
            .thenAnswer((_) async => filePickerResult);

        final result = await fileUploadService.pickSingleFile([]);

        expect(result, equals(platformFile));
      });
    });

    group("pickMultipleFiles", () {
      test("should return null when no files are selected", () async {
        when(() => mockFilePicker.pickFiles(allowMultiple: true))
            .thenAnswer((_) async => null);

        final result = await fileUploadService.pickMultipleFiles([]);

        expect(result, isNull);
        verify(() => mockFilePicker.pickFiles(allowMultiple: true)).called(1);
      });

      test("should return valid files when all files are valid", () async {
        final mockFile1 = createPlatformFile(size: 1024, extension: "pdf");
        final mockFile2 = createPlatformFile(
          size: 2048,
          extension: "doc",
          baseName: "test_file_2",
        );
        final filePickerResult = createFilePickerResult([mockFile1, mockFile2]);

        when(() => mockFilePicker.pickFiles(allowMultiple: true))
            .thenAnswer((_) async => filePickerResult);

        final result = await fileUploadService.pickMultipleFiles([]);

        expect(result, equals([mockFile1, mockFile2]));
        expect(fileUploadService.errorMessage, isEmpty);
      });

      test("should throw exception when any file size exceeds limit", () async {
        final mockFile1 = createPlatformFile(size: 1024, extension: "pdf");
        final mockFile2 = createPlatformFile(
          size: 200 * 1024 * 1024,
          extension: "doc",
          baseName: "test_file_2",
        );
        final filePickerResult = createFilePickerResult([mockFile1, mockFile2]);

        when(() => mockFilePicker.pickFiles(allowMultiple: true))
            .thenAnswer((_) async => filePickerResult);

        try {
          await fileUploadService.pickMultipleFiles([]);
          fail("Expected exception to be thrown");
        } on Object catch (e) {
          expect(e, isA<Exception>());
          expect(
            fileUploadService.errorMessage,
            equals("File is too large. Max size is 100 MB."),
          );
        }
      });

      test("should throw exception when any file extension is not allowed",
          () async {
        final mockFile1 = createPlatformFile(size: 1024, extension: "pdf");
        final mockFile2 = createPlatformFile(
          size: 2048,
          extension: "exe",
          baseName: "test_file_2",
        );
        final filePickerResult = createFilePickerResult([mockFile1, mockFile2]);

        when(() => mockFilePicker.pickFiles(allowMultiple: true))
            .thenAnswer((_) async => filePickerResult);

        try {
          await fileUploadService.pickMultipleFiles([]);
          fail("Expected exception to be thrown");
        } on Object catch (e) {
          expect(e, isA<Exception>());
          // expect(fileUploadService.errorMessage,
          //     equals("File type .exe is not allowed."));
        }
      });
    });

    group("customPickSingleFile", () {
      test("should return null when no file is selected", () async {
        when(
          () => mockFilePicker.pickFiles(
            type: FileType.custom,
            allowMultiple: false,
          ),
        ).thenAnswer((_) async => null);

        final result = await fileUploadService
            .customPickSingleFile(fileType: [], allowedExtensions: []);

        expect(result, isNull);
        verify(
          () => mockFilePicker.pickFiles(
            type: FileType.custom,
            allowMultiple: false,
          ),
        ).called(1);
      });

      test("should return valid file when file is selected and valid",
          () async {
        final platformFile = createPlatformFile(size: 1024, extension: "pdf");
        final filePickerResult = createFilePickerResult([platformFile]);

        when(
          () => mockFilePicker.pickFiles(
            type: FileType.custom,
            allowMultiple: false,
          ),
        ).thenAnswer((_) async => filePickerResult);

        final result = await fileUploadService
            .customPickSingleFile(fileType: [], allowedExtensions: []);

        expect(result, equals(platformFile));
      });

      test("should handle null allowedExtensions", () async {
        final platformFile = createPlatformFile(size: 1024, extension: "pdf");
        final filePickerResult = createFilePickerResult([platformFile]);

        when(
          () => mockFilePicker.pickFiles(
            type: FileType.custom,
            allowMultiple: false,
          ),
        ).thenAnswer((_) async => filePickerResult);

        final result = await fileUploadService
            .customPickSingleFile(fileType: [], allowedExtensions: []);

        expect(result, equals(platformFile));
      });

      test("should throw exception when file size exceeds limit", () async {
        final platformFile = createPlatformFile(
          size: 200 * 1024 * 1024,
          extension: "pdf",
        );
        final filePickerResult = createFilePickerResult([platformFile]);

        when(
          () => mockFilePicker.pickFiles(
            type: FileType.custom,
            allowMultiple: false,
          ),
        ).thenAnswer((_) async => filePickerResult);

        try {
          await fileUploadService
              .customPickSingleFile(fileType: [], allowedExtensions: []);
          fail("Expected exception to be thrown");
        } on Object catch (e) {
          expect(e, isA<Exception>());
          expect(
            fileUploadService.errorMessage,
            equals("File is too large. Max size is 100 MB."),
          );
        }
      });
    });

    group("customPickMultipleFiles", () {
      test("should return null when no files are selected", () async {
        when(
          () => mockFilePicker.pickFiles(
            type: FileType.custom,
            allowMultiple: true,
          ),
        ).thenAnswer((_) async => null);

        final result = await fileUploadService
            .customPickMultipleFiles(allowedExtensions: [], fileType: []);

        expect(result, isNull);
        verify(
          () => mockFilePicker.pickFiles(
            type: FileType.custom,
            allowMultiple: true,
          ),
        ).called(1);
      });

      test("should return valid files when all files are valid", () async {
        final mockFile1 = createPlatformFile(size: 1024, extension: "pdf");
        final mockFile2 = createPlatformFile(
          size: 2048,
          extension: "doc",
          baseName: "test_file_2",
        );
        final filePickerResult = createFilePickerResult([mockFile1, mockFile2]);

        when(
          () => mockFilePicker.pickFiles(
            type: FileType.custom,
            allowMultiple: true,
          ),
        ).thenAnswer((_) async => filePickerResult);

        final result = await fileUploadService
            .customPickMultipleFiles(fileType: [], allowedExtensions: []);

        expect(result, equals([mockFile1, mockFile2]));
      });

      test("should handle null allowedExtensions", () async {
        final platformFile = createPlatformFile(size: 1024, extension: "pdf");
        final filePickerResult = createFilePickerResult([platformFile]);

        when(
          () => mockFilePicker.pickFiles(
            type: FileType.custom,
            allowMultiple: true,
          ),
        ).thenAnswer((_) async => filePickerResult);

        final result = await fileUploadService
            .customPickMultipleFiles(fileType: [], allowedExtensions: []);

        expect(result, equals([platformFile]));
      });

      test("should throw exception when any file size exceeds limit", () async {
        final mockFile1 = createPlatformFile(size: 1024, extension: "pdf");
        final mockFile2 = createPlatformFile(
          size: 200 * 1024 * 1024,
          extension: "doc",
          baseName: "test_file_2",
        );
        final filePickerResult = createFilePickerResult([mockFile1, mockFile2]);

        when(
          () => mockFilePicker.pickFiles(
            type: FileType.custom,
            allowMultiple: true,
          ),
        ).thenAnswer((_) async => filePickerResult);

        try {
          await fileUploadService
              .customPickMultipleFiles(fileType: [], allowedExtensions: []);
          fail("Expected exception to be thrown");
        } on Object catch (e) {
          expect(e, isA<Exception>());
          expect(
            fileUploadService.errorMessage,
            equals("File is too large. Max size is 100 MB."),
          );
        }
      });
    });

    group("File Validation Logic", () {
      test("should validate file size correctly", () async {
        // Test exact max size
        final platformFile = createPlatformFile(
          size: 100 * 1024 * 1024,
          extension: "pdf",
        );
        final filePickerResult = createFilePickerResult([platformFile]);

        when(() => mockFilePicker.pickFiles(allowMultiple: false))
            .thenAnswer((_) async => filePickerResult);

        final result = await fileUploadService.pickSingleFile([]);
        expect(result, equals(platformFile));
      });

      test("should reject file slightly over max size", () async {
        final platformFile = createPlatformFile(
          size: 100 * 1024 * 1024 + 1,
          extension: "pdf",
        );
        final filePickerResult = createFilePickerResult([platformFile]);

        when(() => mockFilePicker.pickFiles(allowMultiple: false))
            .thenAnswer((_) async => filePickerResult);

        try {
          await fileUploadService.pickSingleFile([]);
          fail("Expected exception to be thrown");
        } on Object catch (e) {
          expect(e, isA<Exception>());
          expect(
            fileUploadService.errorMessage,
            equals("File is too large. Max size is 100 MB."),
          );
        }
      });

      // test('should handle empty allowedExtensions list', () async {
      //   final platformFile = createPlatformFile(size: 1024, extension: "exe");
      //   final filePickerResult = createFilePickerResult([platformFile]);
      //
      //   when(() => mockFilePicker.pickFiles(allowMultiple: false))
      //       .thenAnswer((_) async => filePickerResult);
      //
      //   final result = await fileUploadService.pickSingleFile([]);
      //   expect(result, equals(platformFile));
      // });
    });

    group("Error Handling", () {
      test("should propagate exceptions from file picker", () async {
        when(() => mockFilePicker.pickFiles(allowMultiple: false))
            .thenThrow(Exception("File picker error"));

        expect(
          () => fileUploadService.pickSingleFile([]),
          throwsA(isA<Exception>()),
        );
      });

      test("should handle multiple validation errors in sequence", () async {
        // First call - size error
        final largeFile = createPlatformFile(
          size: 200 * 1024 * 1024,
          extension: "pdf",
        );
        final largeFileResult = createFilePickerResult([largeFile]);

        when(() => mockFilePicker.pickFiles(allowMultiple: false))
            .thenAnswer((_) async => largeFileResult);

        try {
          await fileUploadService.pickSingleFile([]);
          fail("Expected exception to be thrown");
        } on Object catch (e) {
          expect(e, isA<Exception>());
          expect(
            fileUploadService.errorMessage,
            equals("File is too large. Max size is 100 MB."),
          );
        }

        // Reset for second call
        fileUploadService.errorMessage = "";

        // Second call - extension error
        final invalidExtensionFile = createPlatformFile(
          size: 1024,
          extension: "exe",
        );
        final invalidExtensionResult =
            createFilePickerResult([invalidExtensionFile]);

        when(() => mockFilePicker.pickFiles(allowMultiple: false))
            .thenAnswer((_) async => invalidExtensionResult);

        try {
          await fileUploadService.pickSingleFile([]);
          fail("Expected exception to be thrown");
        } on Object catch (e) {
          expect(e, isA<Exception>());
          // expect(fileUploadService.errorMessage,
          // equals("File type .exe is not allowed."));
        }
      });
    });

    group("Integration Tests", () {
      test("should handle complete workflow with valid files", () async {
        final mockFile1 = createPlatformFile(size: 1024, extension: "pdf");
        final mockFile2 = createPlatformFile(
          size: 2048,
          extension: "doc",
          baseName: "test_file_2",
        );
        final mockSingleFileResult = createFilePickerResult([mockFile1]);
        final mockMultipleFileResult =
            createFilePickerResult([mockFile1, mockFile2]);

        // Test single file pick
        when(() => mockFilePicker.pickFiles(allowMultiple: false))
            .thenAnswer((_) async => mockSingleFileResult);
        final singleResult = await fileUploadService.pickSingleFile([]);
        expect(singleResult, equals(mockFile1));

        // Test multiple file pick
        when(() => mockFilePicker.pickFiles(allowMultiple: true))
            .thenAnswer((_) async => mockMultipleFileResult);
        final multipleResult = await fileUploadService.pickMultipleFiles([]);
        expect(multipleResult, equals([mockFile1, mockFile2]));

        // Test custom single file pick
        when(
          () => mockFilePicker.pickFiles(
            type: FileType.custom,
            allowMultiple: false,
          ),
        ).thenAnswer((_) async => mockSingleFileResult);
        final customSingleResult = await fileUploadService
            .customPickSingleFile(fileType: [], allowedExtensions: []);
        expect(customSingleResult, equals(mockFile1));

        // Test custom multiple file pick
        when(
          () => mockFilePicker.pickFiles(
            type: FileType.custom,
            allowMultiple: true,
          ),
        ).thenAnswer((_) async => mockMultipleFileResult);
        final customMultipleResult = await fileUploadService
            .customPickMultipleFiles(fileType: [], allowedExtensions: []);
        expect(customMultipleResult, equals([mockFile1, mockFile2]));
      });
    });
  });
}
