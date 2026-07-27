import "dart:io";
import "dart:typed_data";

import "package:dio/dio.dart";
import "package:easy_localization/easy_localization.dart";
import "package:file_picker/file_picker.dart";
import "package:flutter_test/flutter_test.dart";
import "package:mocktail/mocktail.dart";
import "package:wcas_frontend/core/env_config.dart";
import "package:wcas_frontend/core/services/api_service/api_manager.dart";

class MockDio extends Mock implements Dio {}

void main() {
  late MockDio mockDio;
  late BaseOptions baseOptions;
  late APIManager apiManager;
  late File tempFile;

  setUpAll(() async {
    TestWidgetsFlutterBinding.ensureInitialized();

    registerFallbackValue(RequestOptions());
    registerFallbackValue(Options());
    registerFallbackValue(FormData());

    await EnvConfig.setEnvironment();

    tempFile = File("api_manager_test_file.txt");
    await tempFile.writeAsString("hello world");
  });

  setUp(() {
    mockDio = MockDio();
    baseOptions = BaseOptions(headers: <String, dynamic>{"Base": "Header"});

    when(() => mockDio.options).thenReturn(baseOptions);
    when(() => mockDio.interceptors).thenReturn(Interceptors());

    apiManager = APIManager(
      dio: mockDio,
      addDefaultInterceptors: false,
    );
  });

  tearDownAll(() async {
    if (await tempFile.exists()) {
      await tempFile.delete();
    }
  });

  Response<dynamic> response({
    data,
    int? statusCode = 200,
    String? statusMessage = "OK",
  }) {
    return Response<dynamic>(
      requestOptions: RequestOptions(path: "/test"),
      data: data,
      statusCode: statusCode,
      statusMessage: statusMessage,
    );
  }

  DioException dioError({
    data,
    int statusCode = 400,
  }) {
    return DioException(
      requestOptions: RequestOptions(path: "/test"),
      response: Response<dynamic>(
        requestOptions: RequestOptions(path: "/test"),
        statusCode: statusCode,
        data: data,
      ),
      type: DioExceptionType.badResponse,
    );
  }

  group("constructor", () {
    test("adds default interceptors when enabled", () {
      final dio = MockDio();
      final interceptors = Interceptors();

      when(() => dio.options).thenReturn(BaseOptions());
      when(() => dio.interceptors).thenReturn(interceptors);

      APIManager(dio: dio);

      // Dio's own ImplyContentTypeInterceptor is present by default, plus
      // MockInterceptor, RequestLoggingInterceptor, ConnectionInterceptor,
      // and AuthInterceptor added by the constructor.
      expect(interceptors.length, 5);
    });

    test("does not add default interceptors when disabled", () {
      final dio = MockDio();
      final interceptors = Interceptors();

      when(() => dio.options).thenReturn(BaseOptions());
      when(() => dio.interceptors).thenReturn(interceptors);

      APIManager(dio: dio, addDefaultInterceptors: false);

      expect(interceptors.length, 1);
    });
  });

  group("GET", () {
    test("success", () async {
      when(
        () => mockDio.get<dynamic>(
          any(),
          queryParameters: any(named: "queryParameters"),
          options: any(named: "options"),
        ),
      ).thenAnswer(
        (_) async => response(data: {"data": "value"}),
      );

      final result = await apiManager.get(
        "/endpoint",
        queryParams: {"q": 1},
        additionalHeaders: {"X-Test": "yes"},
      );

      expect(result.status, ResponseStatus.success);
      expect(result.code, 200);
      expect(result.message, "OK");
      expect(result.body, {"data": "value"});
    });

    test("DioException returns parsed error", () async {
      when(
        () => mockDio.get<dynamic>(
          any(),
          queryParameters: any(named: "queryParameters"),
          options: any(named: "options"),
        ),
      ).thenThrow(
        dioError(
          data: {
            "status": {"errorDescription": "Get failed"},
          },
          statusCode: 404,
        ),
      );

      final result = await apiManager.get("/endpoint");

      expect(result.status, ResponseStatus.error);
      expect(result.code, 404);
      expect(result.message, "Get failed");
    });

    test("generic exception returns unexpected error", () async {
      when(
        () => mockDio.get<dynamic>(
          any(),
          queryParameters: any(named: "queryParameters"),
          options: any(named: "options"),
        ),
      ).thenThrow(Exception("boom"));

      final result = await apiManager.get("/endpoint");

      expect(result.status, ResponseStatus.error);
      expect(result.message, "common.unexpectedError".tr());
    });
  });

  group("POST", () {
    test("success", () async {
      when(
        () => mockDio.post<dynamic>(
          any(),
          data: any(named: "data"),
          options: any(named: "options"),
        ),
      ).thenAnswer(
        (_) async => response(data: {"created": true}),
      );

      final result = await apiManager.post(
        "/endpoint",
        {"a": 1},
        additionalHeaders: {"X-Test": "yes"},
      );

      expect(result.status, ResponseStatus.success);
      expect(result.body, {"created": true});
    });

    test("plainResponse true success", () async {
      when(
        () => mockDio.post<dynamic>(
          any(),
          data: any(named: "data"),
          options: any(named: "options"),
        ),
      ).thenAnswer(
        (_) async => response(data: "plain text"),
      );

      final result = await apiManager.post(
        "/endpoint",
        {"a": 1},
        plainResponse: true,
      );

      expect(result.status, ResponseStatus.success);
      expect(result.body, "plain text");
    });

    test("DioException returns error", () async {
      when(
        () => mockDio.post<dynamic>(
          any(),
          data: any(named: "data"),
          options: any(named: "options"),
        ),
      ).thenThrow(
        dioError(
          data: {
            "status": {"errorDescription": "Post failed"},
          },
        ),
      );

      final result = await apiManager.post("/endpoint", {});

      expect(result.status, ResponseStatus.error);
      expect(result.message, "Post failed");
    });

    test("generic exception returns unexpected error", () async {
      when(
        () => mockDio.post<dynamic>(
          any(),
          data: any(named: "data"),
          options: any(named: "options"),
        ),
      ).thenThrow(StateError("bad"));

      final result = await apiManager.post("/endpoint", null);

      expect(result.status, ResponseStatus.error);
      expect(result.message, "common.unexpectedError".tr());
    });
  });

  group("DELETE", () {
    test("success", () async {
      when(
        () => mockDio.delete<dynamic>(
          any(),
          data: any(named: "data"),
          options: any(named: "options"),
        ),
      ).thenAnswer(
        (_) async => response(data: {"deleted": true}),
      );

      final result = await apiManager.delete(
        "/endpoint",
        {"id": 1},
        additionalHeaders: {"X-Token": "abc"},
      );

      expect(result.status, ResponseStatus.success);
      expect(result.body, {"deleted": true});
    });

    test("DioException returns error", () async {
      when(
        () => mockDio.delete<dynamic>(
          any(),
          data: any(named: "data"),
          options: any(named: "options"),
        ),
      ).thenThrow(
        dioError(
          data: {
            "status": {"errorDescription": "Delete failed"},
          },
        ),
      );

      final result = await apiManager.delete("/endpoint", {});

      expect(result.status, ResponseStatus.error);
      expect(result.message, "Delete failed");
    });

    test("generic exception returns unexpected error", () async {
      when(
        () => mockDio.delete<dynamic>(
          any(),
          data: any(named: "data"),
          options: any(named: "options"),
        ),
      ).thenThrow(Exception("delete boom"));

      final result = await apiManager.delete("/endpoint", {});

      expect(result.status, ResponseStatus.error);
      expect(result.message, "common.unexpectedError".tr());
    });
  });

  group("PATCH", () {
    test("success", () async {
      when(
        () => mockDio.patch<dynamic>(
          any(),
          data: any(named: "data"),
          options: any(named: "options"),
        ),
      ).thenAnswer(
        (_) async => response(data: {"patched": true}),
      );

      final result = await apiManager.patch(
        "/endpoint",
        {"x": 1},
        additionalHeaders: {"X-Test": "yes"},
      );

      expect(result.status, ResponseStatus.success);
      expect(result.body, {"patched": true});
    });

    test("DioException returns error", () async {
      when(
        () => mockDio.patch<dynamic>(
          any(),
          data: any(named: "data"),
          options: any(named: "options"),
        ),
      ).thenThrow(
        dioError(
          data: {
            "status": {"errorDescription": "Patch failed"},
          },
        ),
      );

      final result = await apiManager.patch("/endpoint", {});

      expect(result.status, ResponseStatus.error);
      expect(result.message, "Patch failed");
    });

    test("generic exception returns unexpected error", () async {
      when(
        () => mockDio.patch<dynamic>(
          any(),
          data: any(named: "data"),
          options: any(named: "options"),
        ),
      ).thenThrow(Exception("patch boom"));

      final result = await apiManager.patch("/endpoint", null);

      expect(result.status, ResponseStatus.error);
      expect(result.message, "common.unexpectedError".tr());
    });
  });

  group("PUT", () {
    test("success", () async {
      when(
        () => mockDio.put<dynamic>(
          any(),
          data: any(named: "data"),
          options: any(named: "options"),
        ),
      ).thenAnswer(
        (_) async => response(data: {"put": true}),
      );

      final result = await apiManager.put(
        "/endpoint",
        {"x": 1},
        additionalHeaders: {"X-Test": "yes"},
      );

      expect(result.status, ResponseStatus.success);
      expect(result.body, {"put": true});
    });

    test("DioException returns error", () async {
      when(
        () => mockDio.put<dynamic>(
          any(),
          data: any(named: "data"),
          options: any(named: "options"),
        ),
      ).thenThrow(
        dioError(
          data: {
            "status": {"errorDescription": "Put failed"},
          },
        ),
      );

      final result = await apiManager.put("/endpoint", {});

      expect(result.status, ResponseStatus.error);
      expect(result.message, "Put failed");
    });

    test("generic exception returns unexpected error", () async {
      when(
        () => mockDio.put<dynamic>(
          any(),
          data: any(named: "data"),
          options: any(named: "options"),
        ),
      ).thenThrow(Exception("put boom"));

      final result = await apiManager.put("/endpoint", null);

      expect(result.status, ResponseStatus.error);
      expect(result.message, "common.unexpectedError".tr());
    });
  });

  group("uploadFile", () {
    test("success with bytes and filename override", () async {
      when(
        () => mockDio.post<dynamic>(
          any(),
          data: any(named: "data"),
          options: any(named: "options"),
        ),
      ).thenAnswer(
        (_) async => response(data: {"uploaded": true}),
      );

      final result = await apiManager.uploadFile(
        "/upload",
        "",
        fileBytes: Uint8List.fromList([1, 2, 3]),
        fileNameOverride: "file.xlsx",
        additionalData: {"type": "excel"},
        additionalHeaders: {"X-Test": "yes"},
      );

      expect(result.status, ResponseStatus.success);
      expect(result.body, {"uploaded": true});
    });

    test("success with bytes default filename", () async {
      when(
        () => mockDio.post<dynamic>(
          any(),
          data: any(named: "data"),
          options: any(named: "options"),
        ),
      ).thenAnswer(
        (_) async => response(data: {"ok": true}),
      );

      final result = await apiManager.uploadFile(
        "/upload",
        "",
        fileBytes: Uint8List.fromList([1]),
      );

      expect(result.status, ResponseStatus.success);
    });

    test("success with file path", () async {
      when(
        () => mockDio.post<dynamic>(
          any(),
          data: any(named: "data"),
          options: any(named: "options"),
        ),
      ).thenAnswer(
        (_) async => response(data: {"path": true}),
      );

      final result = await apiManager.uploadFile(
        "/upload",
        tempFile.path,
      );

      expect(result.status, ResponseStatus.success);
    });

    test("invalid file path returns error", () async {
      final result = await apiManager.uploadFile(
        "/upload",
        "does_not_exist_file.txt",
      );

      expect(result.status, ResponseStatus.error);
      expect(result.message, "common.unexpectedError".tr());
    });

    test("DioException returns error", () async {
      when(
        () => mockDio.post<dynamic>(
          any(),
          data: any(named: "data"),
          options: any(named: "options"),
        ),
      ).thenThrow(
        dioError(
          data: {
            "status": {"errorDescription": "Upload failed"},
          },
        ),
      );

      final result = await apiManager.uploadFile(
        "/upload",
        "",
        fileBytes: Uint8List.fromList([1]),
      );

      expect(result.status, ResponseStatus.error);
      expect(result.message, "Upload failed");
    });
  });

  group("uploadMultipartFiles", () {
    test("empty files returns error", () async {
      final result = await apiManager.uploadMultipartFiles(
        "/batch",
        envelope: {"a": 1},
        files: [],
      );

      expect(result.status, ResponseStatus.error);
      expect(result.message, "common.unexpectedError".tr());
    });

    test("success with bytes file", () async {
      when(
        () => mockDio.post<dynamic>(
          any(),
          data: any(named: "data"),
          onSendProgress: any(named: "onSendProgress"),
          options: any(named: "options"),
        ),
      ).thenAnswer(
        (_) async => response(data: {"uploaded": true}),
      );

      final result = await apiManager.uploadMultipartFiles(
        "/batch",
        envelope: {"meta": "data"},
        files: [
          PlatformFile(
            name: "a.pdf",
            size: 2,
            bytes: Uint8List.fromList([1, 2]),
          ),
        ],
        additionalHeaders: {"X-Test": "yes"},
        onSendProgress: (_, __) {},
      );

      expect(result.status, ResponseStatus.success);
    });

    test("success with path file", () async {
      when(
        () => mockDio.post<dynamic>(
          any(),
          data: any(named: "data"),
          onSendProgress: any(named: "onSendProgress"),
          options: any(named: "options"),
        ),
      ).thenAnswer(
        (_) async => response(data: {"uploaded": true}),
      );

      final result = await apiManager.uploadMultipartFiles(
        "/batch",
        envelope: {},
        files: [
          PlatformFile(
            name: "api_manager_test_file.txt",
            size: 11,
            path: tempFile.path,
          ),
        ],
      );

      expect(result.status, ResponseStatus.success);
    });

    test("file without path or bytes returns error", () async {
      final result = await apiManager.uploadMultipartFiles(
        "/batch",
        envelope: {},
        files: [
          PlatformFile(name: "empty.txt", size: 0),
        ],
      );

      expect(result.status, ResponseStatus.error);
    });

    test("DioException returns error", () async {
      when(
        () => mockDio.post<dynamic>(
          any(),
          data: any(named: "data"),
          onSendProgress: any(named: "onSendProgress"),
          options: any(named: "options"),
        ),
      ).thenThrow(
        dioError(
          data: {
            "status": {"errorDescription": "Payload too large"},
          },
          statusCode: 413,
        ),
      );

      final result = await apiManager.uploadMultipartFiles(
        "/batch",
        envelope: {},
        files: [
          PlatformFile(
            name: "big.pdf",
            size: 1,
            bytes: Uint8List.fromList([1]),
          ),
        ],
      );

      expect(result.status, ResponseStatus.error);
      expect(result.message, "Payload too large");
    });

    test("generic exception from Dio returns unexpected error", () async {
      when(
        () => mockDio.post<dynamic>(
          any(),
          data: any(named: "data"),
          onSendProgress: any(named: "onSendProgress"),
          options: any(named: "options"),
        ),
      ).thenThrow(Exception("upload boom"));

      final result = await apiManager.uploadMultipartFiles(
        "/batch",
        envelope: {},
        files: [
          PlatformFile(
            name: "file.pdf",
            size: 1,
            bytes: Uint8List.fromList([1]),
          ),
        ],
      );

      expect(result.status, ResponseStatus.error);
      expect(result.message, "common.unexpectedError".tr());
    });
  });

  group("downloadFile", () {
    test("success returns bytes", () async {
      final bytes = Uint8List.fromList([1, 2, 3]);

      when(
        () => mockDio.post<dynamic>(
          any(),
          data: any(named: "data"),
          options: any(named: "options"),
        ),
      ).thenAnswer(
        (_) async => response(data: bytes),
      );

      final result = await apiManager.downloadFile("/download", {"id": 1});

      expect(result.status, ResponseStatus.success);
      expect(result.body, bytes);
    });

    test("DioException returns error", () async {
      when(
        () => mockDio.post<dynamic>(
          any(),
          data: any(named: "data"),
          options: any(named: "options"),
        ),
      ).thenThrow(
        dioError(
          data: {
            "status": {"errorDescription": "Download failed"},
          },
        ),
      );

      final result = await apiManager.downloadFile("/download", {});

      expect(result.status, ResponseStatus.error);
      expect(result.message, "Download failed");
    });

    test("generic exception returns unexpected error", () async {
      when(
        () => mockDio.post<dynamic>(
          any(),
          data: any(named: "data"),
          options: any(named: "options"),
        ),
      ).thenThrow(Exception("download boom"));

      final result = await apiManager.downloadFile("/download", null);

      expect(result.status, ResponseStatus.error);
      expect(result.message, "common.unexpectedError".tr());
    });
  });

  group("handleAPIResponse and handleAPIException", () {
    test("handleAPIResponse handles null data and null statusMessage", () {
      final result = apiManager.handleAPIResponse(
        Response<dynamic>(
          requestOptions: RequestOptions(path: "/x"),
          statusCode: 201,
        ),
      );

      expect(result.message, "");
      expect(result.body, {});
      expect(result.code, 201);
      expect(result.status, ResponseStatus.success);
    });

    test("DioException status.errorDescription branch", () {
      final result = apiManager.handleAPIException(
        dioError(
          data: {
            "status": {"errorDescription": "Status error"},
          },
        ),
      );

      expect(result.message, "Status error");
      expect(result.status, ResponseStatus.error);
    });

    test("DioException baseResponse.status.errorDescription branch", () {
      final result = apiManager.handleAPIException(
        dioError(
          data: {
            "status": null,
            "baseResponse": {
              "status": {"errorDescription": "Base error"},
            },
          },
        ),
      );

      expect(result.message, "Base error");
      expect(result.status, ResponseStatus.error);
    });

    test("DioException unableToParse branch", () {
      final result = apiManager.handleAPIException(
        dioError(
          data: {
            "status": {"errorDescription": null},
            "baseResponse": {
              "status": {"errorDescription": null},
            },
          },
        ),
      );

      expect(result.message, "common.unableToParse".tr());
      expect(result.status, ResponseStatus.error);
    });

    test("DioException non-map data keeps common.error", () {
      final result = apiManager.handleAPIException(
        dioError(data: "plain error"),
      );

      expect(result.message, "common.error".tr());
      expect(result.status, ResponseStatus.error);
    });

    test("generic exception returns unexpected error", () {
      final result = apiManager.handleAPIException(Exception("boom"));

      expect(result.message, "common.unexpectedError".tr());
      expect(result.status, ResponseStatus.error);
    });
  });

  group("buildUploadSuccessMessage", () {
    test("null response returns empty", () {
      expect(apiManager.buildUploadSuccessMessage(null), "");
    });

    test("all success", () {
      final msg = apiManager.buildUploadSuccessMessage({
        "successCount": 2,
        "failureCount": 0,
        "results": [
          {"rimNo": "101", "fileName": "a.pdf", "status": "CREATED"},
          {"rimNo": "102", "fileName": "b.pdf", "status": "CREATED"},
        ],
      });

      expect(msg, contains("2 files have been uploaded successfully."));
      expect(msg, contains("101 - a.pdf - Success"));
      expect(msg, contains("102 - b.pdf - Success"));
    });

    test("all failed", () {
      final msg = apiManager.buildUploadSuccessMessage({
        "successCount": 0,
        "failureCount": 2,
        "results": [
          {"rimNo": "101", "fileName": "a.pdf", "status": "FAILED"},
          {"rimNo": "102", "fileName": "b.pdf", "status": "ERROR"},
        ],
      });

      expect(
        msg,
        contains(
          "2 files have been failed to upload. Please try upload again.",
        ),
      );
      expect(msg, contains("101 - a.pdf - Fail"));
    });

    test("partial success", () {
      final msg = apiManager.buildUploadSuccessMessage({
        "successCount": 1,
        "failureCount": 1,
        "results": [
          {"rimNo": "101", "fileName": "a.pdf", "status": "CREATED"},
          {"rimNo": "102", "fileName": "b.pdf", "status": "FAILED"},
        ],
      });

      expect(msg, contains("1 files have been uploaded successfully."));
      expect(
        msg,
        contains(
          "1 files have been failed to upload. Please try upload again.",
        ),
      );
    });

    test("missing values and non-map result", () {
      final msg = apiManager.buildUploadSuccessMessage({
        "results": [
          "bad result",
          {"fileName": null, "status": "FAILED"},
        ],
      });

      expect(msg, contains("N/A - N/A - Fail"));
    });
  });

  group("buildDigitalUploadSuccessMessage", () {
    test("null response returns empty", () {
      expect(apiManager.buildDigitalUploadSuccessMessage(null), "");
    });

    test("invalid shape returns empty", () {
      expect(apiManager.buildDigitalUploadSuccessMessage({}), "");
      expect(
        apiManager.buildDigitalUploadSuccessMessage({
          "perFileCounts": {},
          "results": "bad",
        }),
        "",
      );
    });

    test("all success", () {
      final msg = apiManager.buildDigitalUploadSuccessMessage({
        "perFileCounts": {"success": 1, "failed": 0},
        "results": [
          {
            "metadata": {"RIMNo": "123"},
            "fileName": "contract.pdf",
            "overall": "SUCCESS",
          },
        ],
      });

      expect(msg, contains("1 files have been uploaded successfully."));
      expect(msg, contains("123 - contract.pdf - Success"));
    });

    test("all failed", () {
      final msg = apiManager.buildDigitalUploadSuccessMessage({
        "perFileCounts": {"success": 0, "failed": 1},
        "results": [
          {
            "metadata": {"RIMNo": "999"},
            "fileName": "fail.pdf",
            "overall": "FAILED",
          },
        ],
      });

      expect(
        msg,
        contains(
          "1 files have been failed to upload. Please try upload again.",
        ),
      );
      expect(msg, contains("999 - fail.pdf - Fail"));
    });

    test("partial success and fallback values", () {
      final msg = apiManager.buildDigitalUploadSuccessMessage({
        "perFileCounts": {"success": 1, "failed": 1},
        "results": [
          "bad",
          {
            "metadata": null,
            "fileName": null,
            "overall": "FAILED",
          },
        ],
      });

      expect(msg, contains("1 files have been uploaded successfully."));
      expect(msg, contains("N/A - N/A - Fail"));
    });
  });

  group("extractFailedMessage", () {
    test("returns joined messages", () {
      final msg = apiManager.extractFailedMessage({
        "results": [
          {
            "metadata": {"RIMNo": "101"},
            "fileName": "a.pdf",
            "overall": "FAILED",
          },
          {
            "metadata": {"RIMNo": "102"},
            "fileName": "b.pdf",
            "overall": "SUCCESS",
          },
        ],
      });

      expect(msg, contains("101 - a.pdf - FAILED"));
      expect(msg, contains("102 - b.pdf - SUCCESS"));
    });

    test("empty results returns empty string", () {
      expect(apiManager.extractFailedMessage({"results": []}), "");
    });
  });
}
