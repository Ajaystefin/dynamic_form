import "dart:typed_data";
import "package:dio/dio.dart";
import "package:file_saver/file_saver.dart";
import "package:flutter_test/flutter_test.dart";
import "package:mocktail/mocktail.dart";
import "package:wcas_frontend/core/services/api_service/api_manager.dart";
import "package:wcas_frontend/core/services/file_download_service/service.dart";

class MockDio extends Mock implements Dio {}

class MockResponse extends Mock implements Response<List<int>> {}

void main() {
  group("FileDownloadService", () {
    late MockDio mockDio;
    late MockResponse mockResponse;

    setUpAll(() {
      // Register fallback values for mocktail
      registerFallbackValue(Uint8List(0));
      registerFallbackValue(MimeType.other);
      registerFallbackValue(Options());
    });

    setUp(() {
      mockDio = MockDio();
      mockResponse = MockResponse();
    });

    group("Constructor and Instance", () {
      test("should create instance with default dependencies", () {
        final service = FileDownloadService.instance;
        expect(service, isNotNull);
      });

      test("should create instance with custom Dio", () {
        final customDio = MockDio();
        final service = FileDownloadService(dio: customDio);
        expect(service, isNotNull);
      });

      test("should create instance with custom FileSaver", () {
        final service = FileDownloadService(
          fileSaver: (bytes, fileName) async => "custom-path",
        );
        expect(service, isNotNull);
      });

      test("should create instance with both custom dependencies", () {
        final customDio = MockDio();
        final service = FileDownloadService(
          dio: customDio,
          fileSaver: (bytes, fileName) async => "custom-path",
        );
        expect(service, isNotNull);
      });

      test("should create new instance each time from instance getter", () {
        final instance1 = FileDownloadService.instance;
        final instance2 = FileDownloadService.instance;
        // Unlike a true singleton, this creates new instances
        expect(identical(instance1, instance2), isFalse);
      });
    });

    group("downloadFile - Success Cases", () {
      test("should successfully download file and return success response",
          () async {
        // Arrange
        final mockBytes = Uint8List.fromList([1, 2, 3, 4, 5]);
        const endpoint = "https://example.com/api/files/download";
        const fileName = "test.pdf";
        String? savedFileName;

        when(() => mockResponse.statusCode).thenReturn(200);
        when(() => mockResponse.statusMessage).thenReturn("OK");
        when(() => mockResponse.data).thenReturn(mockBytes);

        when(
          () => mockDio.get(
            endpoint,
            queryParameters: null,
            options: any(named: "options"),
          ),
        ).thenAnswer((_) async => mockResponse);

        final service = FileDownloadService(
          dio: mockDio,
          fileSaver: (bytes, name) async {
            savedFileName = name;
            return name;
          },
        );

        // Act
        final result = await service.downloadFile(endpoint, fileName);

        // Assert
        expect(result.status, equals(ResponseStatus.success));
        expect(result.code, equals(200));
        expect(result.body["fileName"], equals(fileName));
        expect(result.body["size"], equals(mockBytes.length));
        expect(savedFileName, equals(fileName));
        verify(
          () => mockDio.get(
            endpoint,
            queryParameters: null,
            options: any(named: "options"),
          ),
        ).called(1);
      });

      test("should download file with query parameters", () async {
        // Arrange
        final mockBytes = Uint8List.fromList([1, 2, 3]);
        const endpoint = "https://example.com/api/files/download";
        const fileName = "report.pdf";
        final queryParams = {"documentId": "123", "version": "2"};

        when(() => mockResponse.statusCode).thenReturn(200);
        when(() => mockResponse.statusMessage).thenReturn("OK");
        when(() => mockResponse.data).thenReturn(mockBytes);

        when(
          () => mockDio.get(
            endpoint,
            queryParameters: queryParams,
            options: any(named: "options"),
          ),
        ).thenAnswer((_) async => mockResponse);

        final service = FileDownloadService(
          dio: mockDio,
          fileSaver: (bytes, name) async => name,
        );

        // Act
        final result = await service.downloadFile(
          endpoint,
          fileName,
          queryParams: queryParams,
        );

        // Assert
        expect(result.status, equals(ResponseStatus.success));
        expect(result.code, equals(200));
        verify(
          () => mockDio.get(
            endpoint,
            queryParameters: queryParams,
            options: any(named: "options"),
          ),
        ).called(1);
      });

      test("should download file with additional headers", () async {
        // Arrange
        final mockBytes = Uint8List.fromList([7, 8, 9]);
        const endpoint = "https://example.com/api/files/download";
        const fileName = "document.xlsx";
        final additionalHeaders = {"Authorization": "Bearer token123"};

        when(() => mockResponse.statusCode).thenReturn(200);
        when(() => mockResponse.statusMessage).thenReturn("OK");
        when(() => mockResponse.data).thenReturn(mockBytes);

        when(
          () => mockDio.get(
            endpoint,
            queryParameters: null,
            options: any(named: "options"),
          ),
        ).thenAnswer((_) async => mockResponse);

        final service = FileDownloadService(
          dio: mockDio,
          fileSaver: (bytes, name) async => name,
        );

        // Act
        final result = await service.downloadFile(
          endpoint,
          fileName,
          additionalHeaders: additionalHeaders,
        );

        // Assert
        expect(result.status, equals(ResponseStatus.success));
        expect(result.code, equals(200));
      });

      test("should download file with both query params and headers", () async {
        // Arrange
        final mockBytes = Uint8List.fromList([10, 11, 12, 13]);
        const endpoint = "https://example.com/api/files/download";
        const fileName = "data.json";
        final queryParams = {"id": "456"};
        final additionalHeaders = {"X-Custom-Header": "CustomValue"};

        when(() => mockResponse.statusCode).thenReturn(200);
        when(() => mockResponse.statusMessage).thenReturn("OK");
        when(() => mockResponse.data).thenReturn(mockBytes);

        when(
          () => mockDio.get(
            endpoint,
            queryParameters: queryParams,
            options: any(named: "options"),
          ),
        ).thenAnswer((_) async => mockResponse);

        final service = FileDownloadService(
          dio: mockDio,
          fileSaver: (bytes, name) async => name,
        );

        // Act
        final result = await service.downloadFile(
          endpoint,
          fileName,
          queryParams: queryParams,
          additionalHeaders: additionalHeaders,
        );

        // Assert
        expect(result.status, equals(ResponseStatus.success));
        expect(result.code, equals(200));
        expect(result.body["fileName"], equals(fileName));
      });

      test("should handle large file downloads", () async {
        // Arrange
        final largeBytes = Uint8List(10 * 1024 * 1024); // 10MB
        const endpoint = "https://example.com/api/files/download";
        const fileName = "large_file.zip";

        when(() => mockResponse.statusCode).thenReturn(200);
        when(() => mockResponse.statusMessage).thenReturn("OK");
        when(() => mockResponse.data).thenReturn(largeBytes);

        when(
          () => mockDio.get(
            endpoint,
            queryParameters: null,
            options: any(named: "options"),
          ),
        ).thenAnswer((_) async => mockResponse);

        final service = FileDownloadService(
          dio: mockDio,
          fileSaver: (bytes, name) async => name,
        );

        // Act
        final result = await service.downloadFile(endpoint, fileName);

        // Assert
        expect(result.status, equals(ResponseStatus.success));
        expect(result.body["size"], equals(largeBytes.length));
      });

      test("should handle empty file downloads", () async {
        // Arrange
        final emptyBytes = Uint8List(0);
        const endpoint = "https://example.com/api/files/download";
        const fileName = "empty.txt";

        when(() => mockResponse.statusCode).thenReturn(200);
        when(() => mockResponse.statusMessage).thenReturn("OK");
        when(() => mockResponse.data).thenReturn(emptyBytes);

        when(
          () => mockDio.get(
            endpoint,
            queryParameters: null,
            options: any(named: "options"),
          ),
        ).thenAnswer((_) async => mockResponse);

        final service = FileDownloadService(
          dio: mockDio,
          fileSaver: (bytes, name) async => name,
        );

        // Act
        final result = await service.downloadFile(endpoint, fileName);

        // Assert
        expect(result.status, equals(ResponseStatus.success));
        expect(result.body["size"], equals(0));
      });

      test("should handle null status message", () async {
        // Arrange
        final mockBytes = Uint8List.fromList([1, 2, 3]);
        const endpoint = "https://example.com/api/files/download";
        const fileName = "test.pdf";

        when(() => mockResponse.statusCode).thenReturn(200);
        when(() => mockResponse.statusMessage).thenReturn(null);
        when(() => mockResponse.data).thenReturn(mockBytes);

        when(
          () => mockDio.get(
            endpoint,
            queryParameters: null,
            options: any(named: "options"),
          ),
        ).thenAnswer((_) async => mockResponse);

        final service = FileDownloadService(
          dio: mockDio,
          fileSaver: (bytes, name) async => name,
        );

        // Act
        final result = await service.downloadFile(endpoint, fileName);

        // Assert
        expect(result.status, equals(ResponseStatus.success));
        expect(result.message, equals(""));
      });
    });

    group("downloadFile - Error Cases", () {
      test("should handle 404 Not Found error", () async {
        // Arrange
        const endpoint = "https://example.com/api/files/download";
        const fileName = "missing.pdf";

        when(() => mockResponse.statusCode).thenReturn(404);
        when(() => mockResponse.statusMessage).thenReturn("Not Found");

        when(
          () => mockDio.get(
            endpoint,
            queryParameters: null,
            options: any(named: "options"),
          ),
        ).thenAnswer((_) async => mockResponse);

        final service = FileDownloadService(dio: mockDio);

        // Act
        final result = await service.downloadFile(endpoint, fileName);

        // Assert
        expect(result.status, equals(ResponseStatus.error));
        expect(result.code, equals(404));
        expect(result.message, contains("Failed to download file"));
        expect(result.message, contains("Not Found"));
      });

      test("should handle 500 Internal Server Error", () async {
        // Arrange
        const endpoint = "https://example.com/api/files/download";
        const fileName = "error.pdf";

        when(() => mockResponse.statusCode).thenReturn(500);
        when(() => mockResponse.statusMessage)
            .thenReturn("Internal Server Error");

        when(
          () => mockDio.get(
            endpoint,
            queryParameters: null,
            options: any(named: "options"),
          ),
        ).thenAnswer((_) async => mockResponse);

        final service = FileDownloadService(dio: mockDio);

        // Act
        final result = await service.downloadFile(endpoint, fileName);

        // Assert
        expect(result.status, equals(ResponseStatus.error));
        expect(result.code, equals(500));
        expect(result.message, contains("Failed to download file"));
      });

      test("should handle 401 Unauthorized error", () async {
        // Arrange
        const endpoint = "https://example.com/api/files/download";
        const fileName = "secure.pdf";

        when(() => mockResponse.statusCode).thenReturn(401);
        when(() => mockResponse.statusMessage).thenReturn("Unauthorized");

        when(
          () => mockDio.get(
            endpoint,
            queryParameters: null,
            options: any(named: "options"),
          ),
        ).thenAnswer((_) async => mockResponse);

        final service = FileDownloadService(dio: mockDio);

        // Act
        final result = await service.downloadFile(endpoint, fileName);

        // Assert
        expect(result.status, equals(ResponseStatus.error));
        expect(result.code, equals(401));
      });

      test("should handle 403 Forbidden error", () async {
        // Arrange
        const endpoint = "https://example.com/api/files/download";
        const fileName = "forbidden.pdf";

        when(() => mockResponse.statusCode).thenReturn(403);
        when(() => mockResponse.statusMessage).thenReturn("Forbidden");

        when(
          () => mockDio.get(
            endpoint,
            queryParameters: null,
            options: any(named: "options"),
          ),
        ).thenAnswer((_) async => mockResponse);

        final service = FileDownloadService(dio: mockDio);

        // Act
        final result = await service.downloadFile(endpoint, fileName);

        // Assert
        expect(result.status, equals(ResponseStatus.error));
        expect(result.code, equals(403));
      });

      test("should handle network exceptions", () async {
        // Arrange
        const endpoint = "https://example.com/api/files/download";
        const fileName = "network_error.pdf";

        when(
          () => mockDio.get(
            endpoint,
            queryParameters: null,
            options: any(named: "options"),
          ),
        ).thenThrow(
          DioException(
            requestOptions: RequestOptions(path: endpoint),
            type: DioExceptionType.connectionTimeout,
            message: "Connection timeout",
          ),
        );

        final service = FileDownloadService(dio: mockDio);

        // Act
        final result = await service.downloadFile(endpoint, fileName);

        // Assert
        expect(result.status, equals(ResponseStatus.error));
      });

      test("should handle general exceptions", () async {
        // Arrange
        const endpoint = "https://example.com/api/files/download";
        const fileName = "exception.pdf";

        when(
          () => mockDio.get(
            endpoint,
            queryParameters: null,
            options: any(named: "options"),
          ),
        ).thenThrow(Exception("Unexpected error"));

        final service = FileDownloadService(dio: mockDio);

        // Act
        final result = await service.downloadFile(endpoint, fileName);

        // Assert
        expect(result.status, equals(ResponseStatus.error));
      });
    });

    group("File Saving", () {
      test("should save file with correct bytes", () async {
        // Arrange
        final expectedBytes = Uint8List.fromList([10, 20, 30, 40, 50]);
        const endpoint = "https://example.com/api/files/download";
        const fileName = "bytes_test.pdf";
        Uint8List? savedBytes;

        when(() => mockResponse.statusCode).thenReturn(200);
        when(() => mockResponse.statusMessage).thenReturn("OK");
        when(() => mockResponse.data).thenReturn(expectedBytes);

        when(
          () => mockDio.get(
            endpoint,
            queryParameters: null,
            options: any(named: "options"),
          ),
        ).thenAnswer((_) async => mockResponse);

        final service = FileDownloadService(
          dio: mockDio,
          fileSaver: (bytes, name) async {
            savedBytes = bytes;
            return name;
          },
        );

        // Act
        await service.downloadFile(endpoint, fileName);

        // Assert
        expect(savedBytes, isNotNull);
        expect(savedBytes, equals(expectedBytes));
      });

      test("should save file with correct name", () async {
        // Arrange
        final mockBytes = Uint8List.fromList([1, 2, 3]);
        const endpoint = "https://example.com/api/files/download";
        const fileName = "custom_name_file.xlsx";
        String? savedName;

        when(() => mockResponse.statusCode).thenReturn(200);
        when(() => mockResponse.statusMessage).thenReturn("OK");
        when(() => mockResponse.data).thenReturn(mockBytes);

        when(
          () => mockDio.get(
            endpoint,
            queryParameters: null,
            options: any(named: "options"),
          ),
        ).thenAnswer((_) async => mockResponse);

        final service = FileDownloadService(
          dio: mockDio,
          fileSaver: (bytes, name) async {
            savedName = name;
            return name;
          },
        );

        // Act
        await service.downloadFile(endpoint, fileName);

        // Assert
        expect(savedName, equals(fileName));
      });

      test("should use default FileSaver when no custom saver provided",
          () async {
        // Arrange
        final mockBytes = Uint8List.fromList([1, 2, 3]);
        const endpoint = "https://example.com/api/files/download";
        const fileName = "default_saver.pdf";

        when(() => mockResponse.statusCode).thenReturn(200);
        when(() => mockResponse.statusMessage).thenReturn("OK");
        when(() => mockResponse.data).thenReturn(mockBytes);

        when(
          () => mockDio.get(
            endpoint,
            queryParameters: null,
            options: any(named: "options"),
          ),
        ).thenAnswer((_) async => mockResponse);

        final service = FileDownloadService(dio: mockDio);

        // Act & Assert
        // This will use the real FileSaver.instance, which we can't easily mock
        // but we can at least verify it doesn't throw
        expect(
          () => service.downloadFile(endpoint, fileName),
          returnsNormally,
        );
      });
    });

    group("Response Body Validation", () {
      test("should include fileName in response body", () async {
        // Arrange
        final mockBytes = Uint8List.fromList([1, 2, 3]);
        const endpoint = "https://example.com/api/files/download";
        const fileName = "response_test.pdf";

        when(() => mockResponse.statusCode).thenReturn(200);
        when(() => mockResponse.statusMessage).thenReturn("OK");
        when(() => mockResponse.data).thenReturn(mockBytes);

        when(
          () => mockDio.get(
            endpoint,
            queryParameters: null,
            options: any(named: "options"),
          ),
        ).thenAnswer((_) async => mockResponse);

        final service = FileDownloadService(
          dio: mockDio,
          fileSaver: (bytes, name) async => name,
        );

        // Act
        final result = await service.downloadFile(endpoint, fileName);

        // Assert
        expect(result.body, isNotNull);
        expect(result.body, isA<Map>());
        expect(result.body["fileName"], equals(fileName));
      });

      test("should include correct file size in response body", () async {
        // Arrange
        final mockBytes = Uint8List.fromList([1, 2, 3, 4, 5, 6, 7, 8, 9, 10]);
        const endpoint = "https://example.com/api/files/download";
        const fileName = "size_test.pdf";

        when(() => mockResponse.statusCode).thenReturn(200);
        when(() => mockResponse.statusMessage).thenReturn("OK");
        when(() => mockResponse.data).thenReturn(mockBytes);

        when(
          () => mockDio.get(
            endpoint,
            queryParameters: null,
            options: any(named: "options"),
          ),
        ).thenAnswer((_) async => mockResponse);

        final service = FileDownloadService(
          dio: mockDio,
          fileSaver: (bytes, name) async => name,
        );

        // Act
        final result = await service.downloadFile(endpoint, fileName);

        // Assert
        expect(result.body["size"], equals(10));
      });
    });
  });
}
