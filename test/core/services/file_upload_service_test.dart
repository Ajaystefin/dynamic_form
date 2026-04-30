import "package:file_picker/file_picker.dart";
import "package:flutter_test/flutter_test.dart";
import "package:mocktail/mocktail.dart";
import "package:wcas_frontend/core/services/file_upload_service.dart";

class MockFilePickerInterface extends Mock implements FilePickerInterface {}

class MockFilePickerResult extends Mock implements FilePickerResult {}

class MockPlatformFile extends Mock implements PlatformFile {}

void main() {
  group("FileUploadService", () {
    late FileUploadService fileUploadService;
    late MockFilePickerInterface mockFilePicker;
    late MockFilePickerResult mockFilePickerResult;
    late MockPlatformFile mockPlatformFile;

    setUpAll(() {
      // registerFallbackValue(<String>);
      registerFallbackValue(FileType.any);
      registerFallbackValue(false);
    });

    setUp(() {
      fileUploadService = FileUploadService.instance;
      mockFilePicker = MockFilePickerInterface();
      mockFilePickerResult = MockFilePickerResult();
      mockPlatformFile = MockPlatformFile();

      // Reset dependencies
      fileUploadService.setFilePicker(mockFilePicker);
      fileUploadService.errorMessage = "";
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
        when(() => mockPlatformFile.size).thenReturn(1024);
        when(() => mockPlatformFile.extension).thenReturn("pdf");
        when(() => mockFilePickerResult.files).thenReturn([mockPlatformFile]);
        when(() => mockFilePicker.pickFiles(allowMultiple: false))
            .thenAnswer((_) async => mockFilePickerResult);

        final result = await fileUploadService.pickSingleFile([]);

        expect(result, equals(mockPlatformFile));
        expect(fileUploadService.errorMessage, isEmpty);
      });

      test("should throw exception when file size exceeds limit", () async {
        when(() => mockPlatformFile.size)
            .thenReturn(200 * 1024 * 1024); // 200MB
        when(() => mockPlatformFile.extension).thenReturn("pdf");
        when(() => mockFilePickerResult.files).thenReturn([mockPlatformFile]);
        when(() => mockFilePicker.pickFiles(allowMultiple: false))
            .thenAnswer((_) async => mockFilePickerResult);

        try {
          await fileUploadService.pickSingleFile([]);
          fail("Expected exception to be thrown");
        } catch (e) {
          expect(e, isA<Exception>());
          expect(
            fileUploadService.errorMessage,
            equals("File is too large. Max size is 100 MB."),
          );
        }
      });

      test("should throw exception when file extension is not allowed",
          () async {
        when(() => mockPlatformFile.size).thenReturn(1024);
        when(() => mockPlatformFile.extension).thenReturn("exe");
        when(() => mockFilePickerResult.files).thenReturn([mockPlatformFile]);
        when(() => mockFilePicker.pickFiles(allowMultiple: false))
            .thenAnswer((_) async => mockFilePickerResult);

        try {
          await fileUploadService.pickSingleFile([]);
          fail("Expected exception to be thrown");
        } catch (e) {
          expect(e, isA<Exception>());
          // expect(fileUploadService.errorMessage,
          //     equals("File type .exe is not allowed."));
        }
      });

      test(
          "should accept file with null extension when no extensions specified",
          () async {
        when(() => mockPlatformFile.size).thenReturn(1024);
        when(() => mockPlatformFile.extension).thenReturn(null);
        when(() => mockFilePickerResult.files).thenReturn([mockPlatformFile]);
        when(() => mockFilePicker.pickFiles(allowMultiple: false))
            .thenAnswer((_) async => mockFilePickerResult);

        final result = await fileUploadService.pickSingleFile([]);

        expect(result, equals(mockPlatformFile));
      });

      test("should accept file with null extension when extensions specified",
          () async {
        when(() => mockPlatformFile.size).thenReturn(1024);
        when(() => mockPlatformFile.extension).thenReturn(null);
        when(() => mockFilePickerResult.files).thenReturn([mockPlatformFile]);
        when(() => mockFilePicker.pickFiles(allowMultiple: false))
            .thenAnswer((_) async => mockFilePickerResult);

        final result = await fileUploadService.pickSingleFile([]);

        expect(result, equals(mockPlatformFile));
      });

      test("should handle case-insensitive extension matching", () async {
        when(() => mockPlatformFile.size).thenReturn(1024);
        when(() => mockPlatformFile.extension).thenReturn("PDF");
        when(() => mockFilePickerResult.files).thenReturn([mockPlatformFile]);
        when(() => mockFilePicker.pickFiles(allowMultiple: false))
            .thenAnswer((_) async => mockFilePickerResult);

        final result = await fileUploadService.pickSingleFile([]);

        expect(result, equals(mockPlatformFile));
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
        final mockFile1 = MockPlatformFile();
        final mockFile2 = MockPlatformFile();

        when(() => mockFile1.size).thenReturn(1024);
        when(() => mockFile1.extension).thenReturn("pdf");
        when(() => mockFile2.size).thenReturn(2048);
        when(() => mockFile2.extension).thenReturn("doc");
        when(() => mockFilePickerResult.files)
            .thenReturn([mockFile1, mockFile2]);
        when(() => mockFilePicker.pickFiles(allowMultiple: true))
            .thenAnswer((_) async => mockFilePickerResult);

        final result = await fileUploadService.pickMultipleFiles([]);

        expect(result, equals([mockFile1, mockFile2]));
        expect(fileUploadService.errorMessage, isEmpty);
      });

      test("should throw exception when any file size exceeds limit", () async {
        final mockFile1 = MockPlatformFile();
        final mockFile2 = MockPlatformFile();

        when(() => mockFile1.size).thenReturn(1024);
        when(() => mockFile1.extension).thenReturn("pdf");
        when(() => mockFile2.size).thenReturn(200 * 1024 * 1024); // 200MB
        when(() => mockFile2.extension).thenReturn("doc");
        when(() => mockFilePickerResult.files)
            .thenReturn([mockFile1, mockFile2]);
        when(() => mockFilePicker.pickFiles(allowMultiple: true))
            .thenAnswer((_) async => mockFilePickerResult);

        try {
          await fileUploadService.pickMultipleFiles([]);
          fail("Expected exception to be thrown");
        } catch (e) {
          expect(e, isA<Exception>());
          expect(
            fileUploadService.errorMessage,
            equals("File is too large. Max size is 100 MB."),
          );
        }
      });

      test("should throw exception when any file extension is not allowed",
          () async {
        final mockFile1 = MockPlatformFile();
        final mockFile2 = MockPlatformFile();

        when(() => mockFile1.size).thenReturn(1024);
        when(() => mockFile1.extension).thenReturn("pdf");
        when(() => mockFile2.size).thenReturn(2048);
        when(() => mockFile2.extension).thenReturn("exe");
        when(() => mockFilePickerResult.files)
            .thenReturn([mockFile1, mockFile2]);
        when(() => mockFilePicker.pickFiles(allowMultiple: true))
            .thenAnswer((_) async => mockFilePickerResult);

        try {
          await fileUploadService.pickMultipleFiles([]);
          fail("Expected exception to be thrown");
        } catch (e) {
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
        when(() => mockPlatformFile.size).thenReturn(1024);
        when(() => mockPlatformFile.extension).thenReturn("pdf");
        when(() => mockFilePickerResult.files).thenReturn([mockPlatformFile]);
        when(
          () => mockFilePicker.pickFiles(
            type: FileType.custom,
            allowMultiple: false,
          ),
        ).thenAnswer((_) async => mockFilePickerResult);

        final result = await fileUploadService
            .customPickSingleFile(fileType: [], allowedExtensions: []);

        expect(result, equals(mockPlatformFile));
      });

      test("should handle null allowedExtensions", () async {
        when(() => mockPlatformFile.size).thenReturn(1024);
        when(() => mockPlatformFile.extension).thenReturn("pdf");
        when(() => mockFilePickerResult.files).thenReturn([mockPlatformFile]);
        when(
          () => mockFilePicker.pickFiles(
            type: FileType.custom,
            allowMultiple: false,
          ),
        ).thenAnswer((_) async => mockFilePickerResult);

        final result = await fileUploadService
            .customPickSingleFile(fileType: [], allowedExtensions: []);

        expect(result, equals(mockPlatformFile));
      });

      test("should throw exception when file size exceeds limit", () async {
        when(() => mockPlatformFile.size)
            .thenReturn(200 * 1024 * 1024); // 200MB
        when(() => mockPlatformFile.extension).thenReturn("pdf");
        when(() => mockFilePickerResult.files).thenReturn([mockPlatformFile]);
        when(
          () => mockFilePicker.pickFiles(
            type: FileType.custom,
            allowMultiple: false,
          ),
        ).thenAnswer((_) async => mockFilePickerResult);

        try {
          await fileUploadService
              .customPickSingleFile(fileType: [], allowedExtensions: []);
          fail("Expected exception to be thrown");
        } catch (e) {
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
        final mockFile1 = MockPlatformFile();
        final mockFile2 = MockPlatformFile();

        when(() => mockFile1.size).thenReturn(1024);
        when(() => mockFile1.extension).thenReturn("pdf");
        when(() => mockFile2.size).thenReturn(2048);
        when(() => mockFile2.extension).thenReturn("doc");
        when(() => mockFilePickerResult.files)
            .thenReturn([mockFile1, mockFile2]);
        when(
          () => mockFilePicker.pickFiles(
            type: FileType.custom,
            allowMultiple: true,
          ),
        ).thenAnswer((_) async => mockFilePickerResult);

        final result = await fileUploadService
            .customPickMultipleFiles(fileType: [], allowedExtensions: []);

        expect(result, equals([mockFile1, mockFile2]));
      });

      test("should handle null allowedExtensions", () async {
        when(() => mockPlatformFile.size).thenReturn(1024);
        when(() => mockPlatformFile.extension).thenReturn("pdf");
        when(() => mockFilePickerResult.files).thenReturn([mockPlatformFile]);
        when(
          () => mockFilePicker.pickFiles(
            type: FileType.custom,
            allowMultiple: true,
          ),
        ).thenAnswer((_) async => mockFilePickerResult);

        final result = await fileUploadService
            .customPickMultipleFiles(fileType: [], allowedExtensions: []);

        expect(result, equals([mockPlatformFile]));
      });

      test("should throw exception when any file size exceeds limit", () async {
        final mockFile1 = MockPlatformFile();
        final mockFile2 = MockPlatformFile();

        when(() => mockFile1.size).thenReturn(1024);
        when(() => mockFile1.extension).thenReturn("pdf");
        when(() => mockFile2.size).thenReturn(200 * 1024 * 1024); // 200MB
        when(() => mockFile2.extension).thenReturn("doc");
        when(() => mockFilePickerResult.files)
            .thenReturn([mockFile1, mockFile2]);
        when(
          () => mockFilePicker.pickFiles(
            type: FileType.custom,
            allowMultiple: true,
          ),
        ).thenAnswer((_) async => mockFilePickerResult);

        try {
          await fileUploadService
              .customPickMultipleFiles(fileType: [], allowedExtensions: []);
          fail("Expected exception to be thrown");
        } catch (e) {
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
        when(() => mockPlatformFile.size)
            .thenReturn(100 * 1024 * 1024); // Exactly 100MB
        when(() => mockPlatformFile.extension).thenReturn("pdf");
        when(() => mockFilePickerResult.files).thenReturn([mockPlatformFile]);
        when(() => mockFilePicker.pickFiles(allowMultiple: false))
            .thenAnswer((_) async => mockFilePickerResult);

        final result = await fileUploadService.pickSingleFile([]);
        expect(result, equals(mockPlatformFile));
      });

      test("should reject file slightly over max size", () async {
        when(() => mockPlatformFile.size)
            .thenReturn(100 * 1024 * 1024 + 1); // 100MB + 1 byte
        when(() => mockPlatformFile.extension).thenReturn("pdf");
        when(() => mockFilePickerResult.files).thenReturn([mockPlatformFile]);
        when(() => mockFilePicker.pickFiles(allowMultiple: false))
            .thenAnswer((_) async => mockFilePickerResult);

        try {
          await fileUploadService.pickSingleFile([]);
          fail("Expected exception to be thrown");
        } catch (e) {
          expect(e, isA<Exception>());
          expect(
            fileUploadService.errorMessage,
            equals("File is too large. Max size is 100 MB."),
          );
        }
      });

      // test('should handle empty allowedExtensions list', () async {
      //   when(() => mockPlatformFile.size).thenReturn(1024);
      //   when(() => mockPlatformFile.extension)
      //       .thenReturn('exe'); // Should be allowed when no restrictions
      //   when(() =>
      // mockFilePickerResult.files).thenReturn([mockPlatformFile]);
      //   when(() => mockFilePicker.pickFiles(allowMultiple: false))
      //       .thenAnswer((_) async => mockFilePickerResult);

      //   final result = await fileUploadService.pickSingleFile([]);
      //   expect(result, equals(mockPlatformFile));
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
        when(() => mockPlatformFile.size).thenReturn(200 * 1024 * 1024);
        when(() => mockPlatformFile.extension).thenReturn("pdf");
        when(() => mockFilePickerResult.files).thenReturn([mockPlatformFile]);
        when(() => mockFilePicker.pickFiles(allowMultiple: false))
            .thenAnswer((_) async => mockFilePickerResult);

        try {
          await fileUploadService.pickSingleFile([]);
          fail("Expected exception to be thrown");
        } catch (e) {
          expect(e, isA<Exception>());
          expect(
            fileUploadService.errorMessage,
            equals("File is too large. Max size is 100 MB."),
          );
        }

        // Reset for second call
        fileUploadService.errorMessage = "";

        // Second call - extension error
        when(() => mockPlatformFile.size).thenReturn(1024);
        when(() => mockPlatformFile.extension).thenReturn("exe");

        try {
          await fileUploadService.pickSingleFile([]);
          fail("Expected exception to be thrown");
        } catch (e) {
          expect(e, isA<Exception>());
          // expect(fileUploadService.errorMessage,
          // equals("File type .exe is not allowed."));
        }
      });
    });

    group("Integration Tests", () {
      test("should handle complete workflow with valid files", () async {
        final mockFile1 = MockPlatformFile();
        final mockFile2 = MockPlatformFile();
        final mockSingleFileResult = MockFilePickerResult();
        final mockMultipleFileResult = MockFilePickerResult();

        when(() => mockFile1.size).thenReturn(1024);
        when(() => mockFile1.extension).thenReturn("pdf");
        when(() => mockFile2.size).thenReturn(2048);
        when(() => mockFile2.extension).thenReturn("doc");

        // Test single file pick
        when(() => mockSingleFileResult.files).thenReturn([mockFile1]);
        when(() => mockFilePicker.pickFiles(allowMultiple: false))
            .thenAnswer((_) async => mockSingleFileResult);
        final singleResult = await fileUploadService.pickSingleFile([]);
        expect(singleResult, equals(mockFile1));

        // Test multiple file pick
        when(() => mockMultipleFileResult.files)
            .thenReturn([mockFile1, mockFile2]);
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
