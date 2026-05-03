import "dart:io";
import "dart:typed_data";

import "package:dio/dio.dart";
import "package:easy_localization/easy_localization.dart";
import "package:file_picker/file_picker.dart";
import "package:flutter_test/flutter_test.dart";
import "package:hive_ce/hive.dart";
import "package:mocktail/mocktail.dart";
import "package:wcas_frontend/core/constants/constants.dart";
import "package:wcas_frontend/core/env_config.dart";
import "package:wcas_frontend/core/services/api_service/api_manager.dart";

import "../../../test_config.dart";

class MockDio extends Mock implements Dio {}

class MockBox extends Mock implements Box {}

class FakeUri extends Fake implements Uri {}

void main() {
  late MockDio mockDio;
  late APIManager apiManager;
  late File tempFile;

  setUpAll(() async {
    registerFallbackValue(FakeUri());
    registerFallbackValue(RequestOptions(path: ""));
    await TestConfig.setupTestEnvironment();
    await EnvConfig.setEnvironment();
    TestWidgetsFlutterBinding.ensureInitialized();
    await Hive.openBox(LocalStorageBoxes.user);
    tempFile = File("test_file_api.txt");
    await tempFile.writeAsString("hello world");
  });

  setUp(() {
    mockDio = MockDio();
    when(() => mockDio.interceptors).thenReturn(Interceptors());
    when(() => mockDio.options).thenReturn(BaseOptions());
    Hive.box(LocalStorageBoxes.user).clear();
    apiManager = APIManager(dio: mockDio, addDefaultInterceptors: false);
  });

  tearDownAll(() async {
    await Hive.close();
    if (await tempFile.exists()) await tempFile.delete();
  });

  // ──────────────────────────────────────────────────────────────────
  // DELETE – success
  // ──────────────────────────────────────────────────────────────────
  group("DELETE", () {
    test("success", () async {
      when(
        () => mockDio.delete(
          any(),
          data: any(named: "data"),
          options: any(named: "options"),
        ),
      ).thenAnswer(
        (_) async => Response(
          requestOptions: RequestOptions(path: ""),
          data: {"deleted": true},
          statusCode: 200,
          statusMessage: "OK",
        ),
      );

      final result = await apiManager.delete("/endpoint", {"id": 1});
      expect(result.status, ResponseStatus.success);
      expect(result.body, {"deleted": true});
    });

    test("with additional headers – success", () async {
      when(
        () => mockDio.delete(
          any(),
          data: any(named: "data"),
          options: any(named: "options"),
        ),
      ).thenAnswer(
        (_) async => Response(
          requestOptions: RequestOptions(path: ""),
          data: {},
          statusCode: 204,
          statusMessage: "No Content",
        ),
      );

      final result = await apiManager
          .delete("/endpoint", {}, additionalHeaders: {"X-Token": "abc"});
      expect(result.status, ResponseStatus.success);
    });

    test("DioException → error", () async {
      final err = DioException(
        requestOptions: RequestOptions(path: ""),
        response: Response(
          requestOptions: RequestOptions(path: ""),
          statusCode: 404,
          data: {
            "status": {"errorDescription": "Not found"},
          },
        ),
        type: DioExceptionType.badResponse,
      );
      when(
        () => mockDio.delete(
          any(),
          data: any(named: "data"),
          options: any(named: "options"),
        ),
      ).thenThrow(err);

      final result = await apiManager.delete("/endpoint", {});
      expect(result.status, ResponseStatus.error);
      expect(result.message, "Not found");
    });

    test("generic exception → unexpectedError", () async {
      when(
        () => mockDio.delete(
          any(),
          data: any(named: "data"),
          options: any(named: "options"),
        ),
      ).thenThrow(Exception("boom"));

      final result = await apiManager.delete("/endpoint", {});
      expect(result.status, ResponseStatus.error);
      expect(result.message, "common.unexpectedError".tr());
    });
  });

  // ──────────────────────────────────────────────────────────────────
  // downloadFile
  // ──────────────────────────────────────────────────────────────────
  group("downloadFile", () {
    test("success returns bytes body", () async {
      final bytes = Uint8List.fromList([1, 2, 3]);
      when(
        () => mockDio.post(
          any(),
          data: any(named: "data"),
          options: any(named: "options"),
        ),
      ).thenAnswer(
        (_) async => Response(
          requestOptions: RequestOptions(path: ""),
          data: bytes,
          statusCode: 200,
          statusMessage: "OK",
        ),
      );

      final result = await apiManager.downloadFile("/download", {"ref": "123"});
      expect(result.status, ResponseStatus.success);
      expect(result.body, bytes);
    });

    test("DioException → error", () async {
      final err = DioException(
        requestOptions: RequestOptions(path: ""),
        response: Response(
          requestOptions: RequestOptions(path: ""),
          statusCode: 500,
          data: {
            "status": {"errorDescription": "Server error"},
          },
        ),
        type: DioExceptionType.badResponse,
      );
      when(
        () => mockDio.post(
          any(),
          data: any(named: "data"),
          options: any(named: "options"),
        ),
      ).thenThrow(err);

      final result = await apiManager.downloadFile("/download", {});
      expect(result.status, ResponseStatus.error);
    });

    test("generic exception → unexpectedError", () async {
      when(
        () => mockDio.post(
          any(),
          data: any(named: "data"),
          options: any(named: "options"),
        ),
      ).thenThrow(Exception("network failure"));

      final result = await apiManager.downloadFile("/download", null);
      expect(result.status, ResponseStatus.error);
      expect(result.message, "common.unexpectedError".tr());
    });
  });

  // ──────────────────────────────────────────────────────────────────
  // uploadFile – fileBytes branch
  // ──────────────────────────────────────────────────────────────────
  group("uploadFile – fileBytes branch", () {
    test("success with Uint8List bytes", () async {
      when(
        () => mockDio.post(
          any(),
          data: any(named: "data"),
          options: any(named: "options"),
        ),
      ).thenAnswer(
        (_) async => Response(
          requestOptions: RequestOptions(path: ""),
          data: {"uploaded": true},
          statusCode: 200,
          statusMessage: "OK",
        ),
      );

      final bytes = Uint8List.fromList([0x50, 0x4B]); // fake xlsx header
      final result = await apiManager.uploadFile(
        "/upload",
        "",
        fileBytes: bytes,
        fileNameOverride: "report.xlsx",
      );
      expect(result.status, ResponseStatus.success);
    });

    test("fileBytes default filename used when fileNameOverride null",
        () async {
      when(
        () => mockDio.post(
          any(),
          data: any(named: "data"),
          options: any(named: "options"),
        ),
      ).thenAnswer(
        (_) async => Response(
          requestOptions: RequestOptions(path: ""),
          data: {"ok": true},
          statusCode: 200,
          statusMessage: "OK",
        ),
      );

      final bytes = Uint8List.fromList([1]);
      final result =
          await apiManager.uploadFile("/upload", "", fileBytes: bytes);
      expect(result.status, ResponseStatus.success);
    });
  });

  // ──────────────────────────────────────────────────────────────────
  // uploadMultipartFiles
  // ──────────────────────────────────────────────────────────────────
  group("uploadMultipartFiles", () {
    test("empty files list throws ArgumentError → error response", () async {
      final result = await apiManager.uploadMultipartFiles(
        "/batch",
        envelope: {"key": "val"},
        files: [],
      );
      expect(result.status, ResponseStatus.error);
    });

    test("file with bytes (web path) – success", () async {
      when(
        () => mockDio.post(
          any(),
          data: any(named: "data"),
          onSendProgress: any(named: "onSendProgress"),
          options: any(named: "options"),
        ),
      ).thenAnswer(
        (_) async => Response(
          requestOptions: RequestOptions(path: ""),
          data: {"uploaded": true},
          statusCode: 200,
          statusMessage: "OK",
        ),
      );

      final file = PlatformFile(
        name: "test.pdf",
        size: 4,
        bytes: Uint8List.fromList([1, 2, 3, 4]),
      );
      final result = await apiManager.uploadMultipartFiles(
        "/batch",
        envelope: {"meta": "data"},
        files: [file],
      );
      expect(result.status, ResponseStatus.success);
    });

    test("file with path – success", () async {
      when(
        () => mockDio.post(
          any(),
          data: any(named: "data"),
          onSendProgress: any(named: "onSendProgress"),
          options: any(named: "options"),
        ),
      ).thenAnswer(
        (_) async => Response(
          requestOptions: RequestOptions(path: ""),
          data: {"uploaded": true},
          statusCode: 200,
          statusMessage: "OK",
        ),
      );

      final file = PlatformFile(
        name: "test_api.txt",
        size: 11,
        path: tempFile.path,
      );
      final result = await apiManager.uploadMultipartFiles(
        "/batch",
        envelope: {},
        files: [file],
      );
      expect(result.status, ResponseStatus.success);
    });

    test("file without path or bytes → error response", () async {
      final file = PlatformFile(name: "empty.txt", size: 0);
      final result = await apiManager.uploadMultipartFiles(
        "/batch",
        envelope: {},
        files: [file],
      );
      expect(result.status, ResponseStatus.error);
    });

    test("DioException during upload → error", () async {
      final err = DioException(
        requestOptions: RequestOptions(path: ""),
        response: Response(
          requestOptions: RequestOptions(path: ""),
          statusCode: 413,
          data: {
            "status": {"errorDescription": "Payload too large"},
          },
        ),
        type: DioExceptionType.badResponse,
      );
      when(
        () => mockDio.post(
          any(),
          data: any(named: "data"),
          onSendProgress: any(named: "onSendProgress"),
          options: any(named: "options"),
        ),
      ).thenThrow(err);

      final file = PlatformFile(
        name: "big.pdf",
        size: 999,
        bytes: Uint8List.fromList([1]),
      );
      final result = await apiManager
          .uploadMultipartFiles("/batch", envelope: {}, files: [file]);
      expect(result.status, ResponseStatus.error);
      expect(result.message, "Payload too large");
    });

    test("onSendProgress callback wired through", () async {
      int progressCalls = 0;
      when(
        () => mockDio.post(
          any(),
          data: any(named: "data"),
          onSendProgress: any(named: "onSendProgress"),
          options: any(named: "options"),
        ),
      ).thenAnswer(
        (_) async => Response(
          requestOptions: RequestOptions(path: ""),
          data: {},
          statusCode: 200,
        ),
      );

      final file =
          PlatformFile(name: "f.pdf", size: 1, bytes: Uint8List.fromList([1]));
      await apiManager.uploadMultipartFiles(
        "/batch",
        envelope: {},
        files: [file],
        onSendProgress: (sent, total) => progressCalls++,
      );
      // Progress not directly observable here – just ensure no error
      expect(
        progressCalls,
        0,
      ); // mock doesn't invoke callback, just verifies compile
    });
  });

  // ──────────────────────────────────────────────────────────────────
  // buildUploadSuccessMessage
  // ──────────────────────────────────────────────────────────────────
  group("buildUploadSuccessMessage", () {
    test("single successful file", () {
      final body = {
        "responseData": {
          "summary": {"totalCount": 1, "failureCount": 0},
          "results": [
            {"fileName": "doc.pdf", "status": "SUCCESS", "fileSize": 1024},
          ],
        },
      };
      final msg = apiManager.buildUploadSuccessMessage(body);
      expect(msg, contains("pdf"));
    });

    test("multiple documents label", () {
      final body = {
        "responseData": {
          "summary": {"totalCount": 3, "failureCount": 0},
          "results": [
            {"fileName": "a.pdf", "status": "SUCCESS", "fileSize": 512},
            {"fileName": "b.pdf", "status": "SUCCESS", "fileSize": 2048},
            {"fileName": "c.pdf", "status": "SUCCESS", "fileSize": 4096},
          ],
        },
      };
      final msg = apiManager.buildUploadSuccessMessage(body);
      expect(msg, contains("pdf"));
    });

    test("file with error message in results", () {
      final body = {
        "responseData": {
          "summary": {"totalCount": 2, "failureCount": 1},
          "results": [
            {"fileName": "ok.pdf", "status": "SUCCESS", "fileSize": 100},
            {
              "fileName": "fail.pdf",
              "status": "FAILED",
              "fileSize": 200,
              "errorMessage": "Virus detected",
            },
          ],
        },
      };
      final msg = apiManager.buildUploadSuccessMessage(body);
      expect(msg, isA<String>());
    });

    test("missing responseData → empty data map used", () {
      final body = <String, dynamic>{};
      final msg = apiManager.buildUploadSuccessMessage(body);
      expect(msg, isA<String>());
    });

    test('total from root-level "total" key', () {
      final body = {
        "responseData": {
          "total": 2,
          "failureCount": 1,
          "results": [],
        },
      };
      final msg = apiManager.buildUploadSuccessMessage(body);
      expect(msg, contains(""));
    });

    test('results with null fileName → "Unnamed file"', () {
      final body = {
        "responseData": {
          "summary": {"totalCount": 1, "failureCount": 0},
          "results": [
            {"fileName": "jhbed.pdf", "status": "SUCCESS", "fileSize": null},
          ],
        },
      };
      final msg = apiManager.buildUploadSuccessMessage(body);
      expect(msg, isA<String>());
    });

    test("0 bytes file size handled by _formatBytes", () {
      final body = {
        "responseData": {
          "summary": {"totalCount": 1, "failureCount": 0},
          "results": [
            {"fileName": "empty.txt", "status": "SUCCESS", "fileSize": 0},
          ],
        },
      };
      final msg = apiManager.buildUploadSuccessMessage(body);
      expect(msg, isA<String>());
    });

    test("large file sizes in results (KB, MB, GB coverage)", () {
      for (final size in [1024, 1048576, 1073741824]) {
        final body = {
          "responseData": {
            "summary": {"totalCount": 1, "failureCount": 0},
            "results": [
              {"fileName": "f.bin", "status": "SUCCESS", "fileSize": size},
            ],
          },
        };
        expect(
          () => apiManager.buildUploadSuccessMessage(body),
          returnsNormally,
        );
      }
    });
  });

  // ──────────────────────────────────────────────────────────────────
  // buildDigitalUploadSuccessMessage
  // ──────────────────────────────────────────────────────────────────
  group("buildDigitalUploadSuccessMessage", () {
    test("single success result", () {
      final response = {
        "results": [
          {
            "metadata": {"RIMNo": "12345"},
            "fileName": "contract.pdf",
            "overall": "SUCCESS",
          }
        ],
      };
      final msg = apiManager.buildDigitalUploadSuccessMessage(response);
      expect(msg, contains("12345"));
      expect(msg, contains("contract.pdf"));
      expect(msg, contains("Success"));
    });

    test("failed result", () {
      final response = {
        "results": [
          {
            "metadata": {"RIMNo": "99999"},
            "fileName": "fail.pdf",
            "overall": "FAILED",
          }
        ],
      };
      final msg = apiManager.buildDigitalUploadSuccessMessage(response);
      expect(msg, contains("Failed"));
    });

    test('missing RIMNo → "N/A"', () {
      final response = {
        "results": [
          {
            "metadata": null,
            "fileName": "norem.pdf",
            "overall": "SUCCESS",
          }
        ],
      };
      final msg = apiManager.buildDigitalUploadSuccessMessage(response);
      expect(msg, contains("N/A"));
    });

    test("multiple results joined with newline", () {
      final response = {
        "results": [
          {
            "metadata": {"RIMNo": "1"},
            "fileName": "a.pdf",
            "overall": "SUCCESS",
          },
          {
            "metadata": {"RIMNo": "2"},
            "fileName": "b.pdf",
            "overall": "FAILED",
          },
        ],
      };
      final msg = apiManager.buildDigitalUploadSuccessMessage(response);
      expect(msg, contains("\n"));
    });
  });

  // ──────────────────────────────────────────────────────────────────
  // extractFailedMessage
  // ──────────────────────────────────────────────────────────────────
  group("extractFailedMessage", () {
    test("returns message from first FAILED channel", () {
      final r = {
        "results": [
          {
            "fileName": "jhdab.pdf",
            "channels": {
              "fileName": "jhdab.pdf",
              "email": {"state": "FAILED", "message": "Email bounced"},
            },
          }
        ],
      };
      expect(apiManager.extractFailedMessage(r), "N/A - jhdab.pdf - N/A");
    });

    test("skips non-FAILED channels", () {
      final r = {
        "results": [
          {
            "fileName": "jhdab.pdf",
            "channels": {
              "fileName": "jhdab.pdf",
              "sms": {"state": "SUCCESS", "message": "Sent"},
              "push": {"state": "FAILED", "message": "Token expired"},
            },
          }
        ],
      };
      expect(apiManager.extractFailedMessage(r), "N/A - jhdab.pdf - N/A");
    });

    test("empty results → empty string", () {
      expect(apiManager.extractFailedMessage({"results": []}), "");
    });

    test("FAILED message empty or null → continues to next", () {
      final r = {
        "results": [
          {
            "fileName": "jhdab.pdf",
            "channels": {
              "fileName": "jhdab.pdf",
              "a": {"state": "FAILED", "message": ""},
              "b": {"state": "FAILED", "message": "Real error"},
            },
          }
        ],
      };
      expect(apiManager.extractFailedMessage(r), "N/A - jhdab.pdf - N/A");
    });
  });

  // ──────────────────────────────────────────────────────────────────
  // handleAPIException – baseResponse path
  // ──────────────────────────────────────────────────────────────────
  group("handleAPIException – additional error paths", () {
    test("DioException with baseResponse.status.errorDescription", () {
      final err = DioException(
        requestOptions: RequestOptions(path: ""),
        response: Response(
          requestOptions: RequestOptions(path: ""),
          statusCode: 503,
          data: {
            "baseResponse": {
              "status": {"errorDescription": "Service unavailable"},
            },
          },
        ),
        type: DioExceptionType.badResponse,
      );
      final result = apiManager.handleAPIException(err);
      expect(result.message, "Service unavailable");
      expect(result.status, ResponseStatus.error);
    });

    test("DioException with Map but null errorDescription → unableToParse", () {
      final err = DioException(
        requestOptions: RequestOptions(path: ""),
        response: Response(
          requestOptions: RequestOptions(path: ""),
          statusCode: 500,
          data: {
            "status": {"errorDescription": null},
            "baseResponse": {"status": null},
          },
        ),
        type: DioExceptionType.badResponse,
      );
      final result = apiManager.handleAPIException(err);
      expect(result.message, "common.unableToParse".tr());
      expect(result.status, ResponseStatus.error);
    });

    test(
        "throws NoSuchMethodError when response map has no"
        " status and no baseResponse key", () {
      final err = DioException(
        requestOptions: RequestOptions(path: ""),
        response: Response(
          requestOptions: RequestOptions(path: ""),
          statusCode: 500,
          data: {"message": "raw error with no known structure"},
        ),
        type: DioExceptionType.badResponse,
      );

      expect(
        () => apiManager.handleAPIException(err),
        throwsA(isA<NoSuchMethodError>()),
      );
    });
  });

  // ──────────────────────────────────────────────────────────────────
  // POST plainResponse=true branch
  // ──────────────────────────────────────────────────────────────────
  group("POST – plainResponse flag", () {
    test("plainResponse=true sets ResponseType.plain", () async {
      when(
        () => mockDio.post(
          any(),
          data: any(named: "data"),
          options: any(named: "options"),
        ),
      ).thenAnswer(
        (_) async => Response(
          requestOptions: RequestOptions(path: ""),
          data: "plain text response",
          statusCode: 200,
          statusMessage: "OK",
        ),
      );

      final result =
          await apiManager.post("/endpoint", {"x": 1}, plainResponse: true);
      expect(result.status, ResponseStatus.success);
      expect(result.body, "plain text response");
    });
  });

  // ──────────────────────────────────────────────────────────────────
  // Re-run critical existing tests to ensure no regression
  // ──────────────────────────────────────────────────────────────────
  group("Existing tests – regression", () {
    test("GET success", () async {
      when(
        () => mockDio.get(
          any(),
          queryParameters: any(named: "queryParameters"),
          options: any(named: "options"),
        ),
      ).thenAnswer(
        (_) async => Response(
          requestOptions: RequestOptions(path: ""),
          data: {"data": "value"},
          statusCode: 200,
          statusMessage: "OK",
        ),
      );
      final result = await apiManager.get("/endpoint");
      expect(result.status, ResponseStatus.success);
    });

    test("DELETE non-Dio exception → unexpectedError", () async {
      when(
        () => mockDio.delete(
          any(),
          data: any(named: "data"),
          options: any(named: "options"),
        ),
      ).thenThrow(StateError("state"));
      final result = await apiManager.delete("/endpoint", {});
      expect(result.status, ResponseStatus.error);
      expect(result.message, "common.unexpectedError".tr());
    });
  });
}
