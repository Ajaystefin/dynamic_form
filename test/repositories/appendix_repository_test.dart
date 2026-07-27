// dart/flutter test
import "dart:convert";
import "dart:typed_data";

import "package:dio/dio.dart"; // - use public dio import
import "package:file_picker/src/platform_file.dart";

import "package:test/test.dart";
import "package:wcas_frontend/core/constants/constants.dart";
import "package:wcas_frontend/core/services/api_service/api_manager.dart";
import "package:wcas_frontend/models/request/file_attachment/appendix.dart";
import "package:wcas_frontend/models/request/file_attachment/appendix_comment.dart";
import "package:wcas_frontend/models/request/file_attachment/appendix_image.dart";
import "package:wcas_frontend/models/request/file_attachment/business_segment_payload.dart";
import "package:wcas_frontend/models/request/file_attachment/group_corporate_structure_payload.dart";
import "package:wcas_frontend/repositories/appendix_repository.dart";

// ==================================================
// Lightweight Mock APIManager (sample style)
// - setMockResponse(): single response for all calls
// - setMockResponses(): per-method responses
// - callLog: verify endpoint/method/payload/file args
// ==================================================

class CallLogEntry {
  CallLogEntry({
    required this.method,
    required this.endpoint,
    this.body,
  });
  final String method; // 'post' | 'delete' | 'uploadFile' | 'downloadFile'
  final dynamic endpoint;
  final Map<String, dynamic>? body;
}

Matcher throwsExceptionWithMessage(String message) {
  return throwsA(
    isA<Exception>().having(
      (e) => e.toString(),
      "message",
      contains(message),
    ),
  );
}

class MockAPIManager implements APIManager {
  final List<CallLogEntry> callLog = [];

  AppResponse? _singleResponse;
  AppResponse? _postResponse;
  AppResponse? _deleteResponse;
  AppResponse? _uploadResponse;
  AppResponse? _downloadResponse;

  void reset() {
    callLog.clear();
    _singleResponse = null;
    _postResponse = null;
    _deleteResponse = null;
    _uploadResponse = null;
    _downloadResponse = null;
  }

  void setMockResponse(AppResponse resp) {
    _singleResponse = resp;
    _postResponse = resp;
    _deleteResponse = resp;
    _uploadResponse = resp;
    _downloadResponse = resp;
  }

  void setMockResponses({
    AppResponse? post,
    AppResponse? delete,
    AppResponse? uploadFile,
    AppResponse? downloadFile,
  }) {
    _singleResponse = null; // explicit per-method responses
    _postResponse = post ?? _postResponse;
    _deleteResponse = delete ?? _deleteResponse;
    _uploadResponse = uploadFile ?? _uploadResponse;
    _downloadResponse = downloadFile ?? _downloadResponse;
  }

  // ---------- Implement only what the repo uses ----------

  @override
  Future<AppResponse> post(
    String endPoint,
    Object? body, {
    Map<String, dynamic> additionalHeaders = const {},
    bool plainResponse = false,
  }) async {
    callLog.add(
      CallLogEntry(
        method: "post",
        endpoint: endPoint,
        body: body is Map<String, dynamic> ? body : null,
      ),
    );
    return (_postResponse ?? _singleResponse)!;
  }

  @override
  Future<AppResponse> delete(
    String endPoint,
    Map<String, dynamic> data, {
    Map<String, dynamic> additionalHeaders = const {},
  }) async {
    callLog.add(CallLogEntry(method: "delete", endpoint: endPoint, body: data));
    return (_deleteResponse ?? _singleResponse)!;
  }

  @override
  Future<AppResponse> uploadFile(
    String endPoint,
    String filePath, {
    String fieldName = "file",
    Map<String, dynamic> additionalHeaders = const {},
    Map<String, dynamic>? additionalData,
    Uint8List? fileBytes,
    String? fileNameOverride,
  }) async {
    callLog.add(
      CallLogEntry(
        method: "uploadFile",
        endpoint: endPoint,
      ),
    );
    return (_uploadResponse ?? _singleResponse)!;
  }

  @override
  Future<AppResponse> downloadFile(
    String endPoint,
    Object? body, {
    Map<String, dynamic> additionalHeaders = const {},
  }) async {
    callLog.add(
      CallLogEntry(
        method: "downloadFile",
        endpoint: endPoint,
        body: body is Map<String, dynamic> ? body : null,
      ),
    );
    return (_downloadResponse ?? _singleResponse)!;
  }

  // ---------- Unused in these tests: keep as stubs ----------

  @override
  Future<AppResponse> get(
    String endPoint, {
    Map<String, dynamic>? queryParams,
    Map<String, dynamic> additionalHeaders = const {},
  }) {
    throw UnimplementedError();
  }

  @override
  AppResponse handleAPIException(Object e) {
    throw UnimplementedError();
  }

  @override
  AppResponse handleAPIResponse(Response response) {
    throw UnimplementedError();
  }

  @override
  Future<AppResponse> patch(
    String endPoint,
    Object? data, {
    Map<String, dynamic> additionalHeaders = const {},
  }) {
    throw UnimplementedError();
  }

  @override
  Future<AppResponse> put(
    String endPoint,
    Object? data, {
    Map<String, dynamic> additionalHeaders = const {},
  }) {
    throw UnimplementedError();
  }

  @override
  Future<AppResponse> uploadMultipartFiles(
    String endPoint, {
    required Map envelope,
    required List<PlatformFile> files,
    Map<String, dynamic> additionalHeaders = const {},
    ProgressCallback? onSendProgress,
  }) {
    // implement uploadMultipartFiles
    throw UnimplementedError();
  }

  @override
  String buildUploadSuccessMessage(Map<String, dynamic>? body) {
    throw UnimplementedError();
  }

  @override
  String buildDigitalUploadSuccessMessage(Map<String, dynamic>? body) {
    throw UnimplementedError();
  }

  @override
  String extractFailedMessage(Map<String, dynamic> r) {
    throw UnimplementedError();
  }
}

// ==== Convenience builders for responses ====

AppResponse successResp({
  String message = "OK",
  Map<String, dynamic>? base,
  Object? responseData,
}) {
  return AppResponse(
    status: ResponseStatus.success,
    code: 200,
    message: message,
    body: <String, dynamic>{
      "baseResponse": <String, dynamic>{
        "status": <String, dynamic>{
          "statusCode": 0,
          "statusDescription": base?["statusDescription"] ?? message,
        },
      },
      if (responseData != null) "responseData": responseData,
    },
  );
}

AppResponse errorResp({
  String message = "Error",
  String? statusDescription,
  int code = 500,
}) {
  return AppResponse(
    status: ResponseStatus.error,
    code: code,
    message: message,
    body: <String, dynamic>{
      "baseResponse": <String, dynamic>{
        "status": <String, dynamic>{
          "statusCode": 99,
          if (statusDescription != null) "statusDescription": statusDescription,
        },
      },
    },
  );
}

void main() {
  late MockAPIManager mockAPIManager;
  late AppendixRepository appendixRepository;

  setUp(() {
    mockAPIManager = MockAPIManager();
    appendixRepository = AppendixRepository(apiManager: mockAPIManager);
  });

  tearDown(() {
    mockAPIManager.reset();
  });

  // ========= extractAppendixXlsxAsMultipart =========
  test(
      "should return fallback message when statusDescription is"
      " missing (extractAppendixXlsxAsMultipart)", () async {
    // Arrange
    mockAPIManager
        .setMockResponse(successResp(message: "Fallback message", base: {}));

    // Act
    final result = await appendixRepository.extractAppendixXlsxAsMultipart(
      bytes: Uint8List.fromList([]),
      fileName: "x.xlsx",
      rimNumber: "RIM",
      userId: "UID",
      appRefNo: "APP",
    );

    // Assert
    expect(result, equals("Fallback message"));
    expect(mockAPIManager.callLog, hasLength(1));
  });

  // ========= fetchFiAppendixXlsx =========
  test(
      "should throw normalized "
      "message when "
      "API returns error (fetchFiAppendixXlsx)", () async {
    // Arrange
    mockAPIManager.setMockResponse(
      errorResp(message: "Generic fail", statusDescription: "Server error"),
    );

    // Act & Assert
    expect(
      () => appendixRepository.fetchFiAppendixXlsx("APP-1"),
      throwsExceptionWithMessage("Server error"),
    );
    expect(mockAPIManager.callLog, hasLength(1));
    expect(
      mockAPIManager.callLog.last.endpoint,
      APIEndpoints.fetchAppendixXlsx,
    );
  });

  test("should return list when responseData is List (fetchFiAppendixXlsx)",
      () async {
    mockAPIManager.setMockResponse(
      successResp(base: {"statusDescription": "OK"}, responseData: [1, 2, 3]),
    );

    final result = await appendixRepository.fetchFiAppendixXlsx("APP-2");
    expect(result, equals([1, 2, 3]));
    expect(mockAPIManager.callLog, hasLength(1));
  });

  test("should wrap non-list responseData into list (fetchFiAppendixXlsx)",
      () async {
    mockAPIManager.setMockResponse(
      successResp(base: {"statusDescription": "OK"}, responseData: {"k": "v"}),
    );

    final result = await appendixRepository.fetchFiAppendixXlsx("APP-3");
    expect(
      result,
      equals([
        {"k": "v"},
      ]),
    );
  });

  test("should return [] when responseData is null (fetchFiAppendixXlsx)",
      () async {
    mockAPIManager.setMockResponse(
      successResp(base: {"statusDescription": "OK"}),
    );

    final result = await appendixRepository.fetchFiAppendixXlsx("APP-4");
    expect(result, isEmpty);
  });

  // ========= deleteExtractAppendixXlsx =========
  test(
      "should throw ArgumentError when appendixXlsxId "
      "<= 0 (deleteExtractAppendixXlsx)", () async {
    expect(
      () => appendixRepository.deleteExtractAppendixXlsx(appendixXlsxId: 0),
      throwsA(isA<ArgumentError>()),
    );
  });

  test(
      "should return normalized message on success (deleteExtractAppendixXlsx)",
      () async {
    mockAPIManager.setMockResponse(
      successResp(base: {"statusDescription": "Deleted"}),
    );

    final msg =
        await appendixRepository.deleteExtractAppendixXlsx(appendixXlsxId: 99);
    expect(msg, "Deleted");
    expect(mockAPIManager.callLog, hasLength(1));
    expect(
      mockAPIManager.callLog.first.endpoint,
      APIEndpoints.deleteExtractAppendixXlsx,
    );
  });

  test("should throw normalized message on failure (deleteExtractAppendixXlsx)",
      () async {
    mockAPIManager.setMockResponse(
      errorResp(message: "generic", statusDescription: "Delete failed"),
    );

    expect(
      () => appendixRepository.deleteExtractAppendixXlsx(appendixXlsxId: 1),
      throwsExceptionWithMessage("Delete failed"),
    );
  });

  // ========= getAppendixImageBase64 =========
  test("should throw message when status != success (getAppendixImageBase64)",
      () async {
    mockAPIManager.setMockResponse(
      errorResp(message: "Not OK"),
    );

    expect(
      () => appendixRepository.getAppendixImageBase64(appRefNo: "APP"),
      throwsExceptionWithMessage("Not OK"),
    );
  });

  test(
      "should read base64 from Map responseData "
      "by known keys (getAppendixImageBase64)", () async {
    mockAPIManager.setMockResponse(
      successResp(
        base: {
          "statusDescription": "OK",
        },
        responseData: {
          "imageDataBase64": "QUJD", // "ABC"
        },
      ),
    );

    final b64 =
        await appendixRepository.getAppendixImageBase64(appRefNo: "APP");
    expect(b64, "QUJD");
  });

  test("should read first non-empty base64 from List (getAppendixImageBase64)",
      () async {
    mockAPIManager.setMockResponse(
      successResp(
        base: {
          "statusDescription": "OK",
        },
        responseData: [
          {"image": ""},
          {"contentBase64": "S0w="}, // "KL"
        ],
      ),
    );

    final b64 =
        await appendixRepository.getAppendixImageBase64(appRefNo: "APP");
    expect(b64, "S0w=");
  });

  test(
      "should return String when responseData "
      "is a String (getAppendixImageBase64)", () async {
    mockAPIManager.setMockResponse(
      successResp(base: {"statusDescription": "OK"}, responseData: "QUJD"),
    );

    final b64 =
        await appendixRepository.getAppendixImageBase64(appRefNo: "APP");
    expect(b64, "QUJD");
  });

  test(
      "should return null when no usable base64 found (getAppendixImageBase64)",
      () async {
    mockAPIManager.setMockResponse(
      successResp(base: {"statusDescription": "OK"}, responseData: {"x": "y"}),
    );

    final b64 =
        await appendixRepository.getAppendixImageBase64(appRefNo: "APP");
    expect(b64, isNull);
  });

  // ========= getAppendixImageBytes =========
  test(
      "should decode bytes from valid base64 "
      "branch first (getAppendixImageBytes)", () async {
    mockAPIManager.setMockResponses(
      post: successResp(
        base: {"statusDescription": "OK"},
        responseData: "AQID",
      ), // [1,2,3]
    );

    final bytes =
        await appendixRepository.getAppendixImageBytes(appRefNo: "APP");
    expect(bytes, Uint8List.fromList([1, 2, 3]));
    expect(mockAPIManager.callLog, hasLength(1));
    expect(mockAPIManager.callLog.first.method, "post");
    expect(
      mockAPIManager.callLog.first.endpoint,
      APIEndpoints.getAppendixImage,
    );
  });

  test(
      "should fallback to download bytes when "
      "base64 invalid (getAppendixImageBytes)", () async {
    mockAPIManager.setMockResponses(
      post: successResp(
        base: {"statusDescription": "OK"},
        responseData: "***INVALID***",
      ),
      downloadFile: AppResponse(
        status: ResponseStatus.success,
        code: 200,
        message: "OK",
        body: [10, 20, 30], // <= raw bytes path
      ),
    );

    final bytes =
        await appendixRepository.getAppendixImageBytes(appRefNo: "APP");
    expect(bytes, Uint8List.fromList([10, 20, 30]));
    expect(mockAPIManager.callLog.length, 2);
    expect(mockAPIManager.callLog[0].method, "post");
    expect(mockAPIManager.callLog[1].method, "downloadFile");
  });

  test(
      "should return null when download body is "
      "not List<int> (getAppendixImageBytes)", () async {
    mockAPIManager.setMockResponses(
      post: successResp(base: {"statusDescription": "OK"}),
      downloadFile: AppResponse(
        status: ResponseStatus.success,
        code: 200,
        message: "OK",
        body: {"x": "y"}, // not List<int>
      ),
    );

    final bytes =
        await appendixRepository.getAppendixImageBytes(appRefNo: "APP");
    expect(bytes, isNull);
  });

  // ========= saveAppendixBusinessSegmentPayload =========
  test(
      "should throw normalized message on failure "
      "(saveAppendixBusinessSegmentPayload)", () async {
    mockAPIManager.setMockResponse(
      errorResp(message: "generic", statusDescription: "Bad request"),
    );

    const p = BusinessSegmentPayload(
      appRefNo: "APP-TEST-001",
      rimNo: 12345,
      countryName: "Testland",
      populationText: "5,000,000",
      gdpText: "150 Billion USD",
      exportPartners: ["CountryA", "CountryB"],
      importPartners: ["CountryC", "CountryD"],
      strengths: ["Stable political environment", "Skilled labor force"],
      threats: ["High inflation", "Trade restrictions"],
      createdBy: "tester",
      // createdDate: "2024-01-01T00:00:00Z",
      updatedBy: "tester2",
      // updatedDate: '2024-01-15T00:00:00Z',
    );
    expect(
      () => appendixRepository.saveAppendixBusinessSegmentPayload(p),
      throwsExceptionWithMessage("Bad request"),
    );
  });

  test(
      "should return statusDescription on success "
      "(saveAppendixBusinessSegmentPayload)", () async {
    mockAPIManager.setMockResponse(
      successResp(base: {"statusDescription": "Saved"}),
    );

    const p = BusinessSegmentPayload(
      appRefNo: "APP-TEST-001",
      rimNo: 12345,
      countryName: "Testland",
      populationText: "5,000,000",
      gdpText: "150 Billion USD",
      exportPartners: ["CountryA", "CountryB"],
      importPartners: ["CountryC", "CountryD"],
      strengths: ["Stable political environment", "Skilled labor force"],
      threats: ["High inflation", "Trade restrictions"],
      createdBy: "tester",
      // createdDate: "2024-01-01T00:00:00Z",
      updatedBy: "tester2",
      // updatedDate: '2024-01-15T00:00:00Z',
    );
    final msg = await appendixRepository.saveAppendixBusinessSegmentPayload(p);
    expect(msg, "Saved");
    expect(mockAPIManager.callLog, hasLength(1));
    expect(
      mockAPIManager.callLog.first.endpoint,
      APIEndpoints.saveAppendixBusinnesSegment,
    );
  });

  // ========= fetchAppendixImages =========
  test(
      "should normalize response.message from "
      "statusDescription (fetchAppendixImages)", () async {
    mockAPIManager.setMockResponse(
      successResp(base: {"statusDescription": "Normalized"}, responseData: {}),
    );

    final resp = await appendixRepository.fetchAppendixImages("APP");
    expect(resp.message, "Normalized");
    expect(mockAPIManager.callLog, hasLength(1));
  });

  // ========= fetchAppendixImageItems =========
  test("should throw when status != success (fetchAppendixImageItems)",
      () async {
    mockAPIManager.setMockResponse(
      errorResp(message: "Fail"),
    );

    expect(
      () => appendixRepository.fetchAppendixImageItems("APP"),
      throwsExceptionWithMessage("Fail"),
    );
  });

  test(
      "should handle Map payload and return item "
      "when hasBase64 (fetchAppendixImageItems)", () async {
    mockAPIManager.setMockResponse(
      successResp(
        responseData: {
          "imageBase64": "QQ==", // "A"
        },
      ),
    );

    final items = await appendixRepository.fetchAppendixImageItems("APP");
    expect(items, isA<List<AppendixImageItem>>());
    expect(items.length, 1);
  });

  test(
      "should handle List payload and filter only "
      "items with base64 (fetchAppendixImageItems)", () async {
    mockAPIManager.setMockResponse(
      successResp(
        responseData: [
          {"image": ""},
          {"contentBase64": "QQ=="},
        ],
      ),
    );

    final items = await appendixRepository.fetchAppendixImageItems("APP");
    expect(items.length, 1);
  });

  test("should handle String payload (non-empty) (fetchAppendixImageItems)",
      () async {
    mockAPIManager.setMockResponse(
      successResp(responseData: "QQ=="),
    );

    final items = await appendixRepository.fetchAppendixImageItems("APP");
    expect(items.length, 1);
  });

  test("should return empty when responseData null (fetchAppendixImageItems)",
      () async {
    mockAPIManager.setMockResponse(
      successResp(),
    );

    final items = await appendixRepository.fetchAppendixImageItems("APP");
    expect(items, isEmpty);
  });

  // ========= saveAppendixImage =========
  test("should return statusDescription on success (saveAppendixImage)",
      () async {
    mockAPIManager.setMockResponse(
      successResp(base: {"statusDescription": "Saved image"}),
    );

    final msg = await appendixRepository.saveAppendixImage(
      appRefNo: "APP",
      customerType: "Bank",
      fileName: "f.png",
      imageType: "Financial",
      imageDataBase64: "QQ==",
    );
    expect(msg, "Saved image");
    expect(mockAPIManager.callLog, hasLength(1));
    expect(
      mockAPIManager.callLog.first.endpoint,
      APIEndpoints.saveAppendixImage,
    );
  });

  test("should throw message on failure (saveAppendixImage)", () async {
    mockAPIManager.setMockResponse(
      errorResp(message: "Save failed"),
    );

    expect(
      () => appendixRepository.saveAppendixImage(
        appRefNo: "APP",
        customerType: "Bank",
        fileName: "f.png",
        imageType: "Financial",
        imageDataBase64: "QQ==",
      ),
      throwsExceptionWithMessage("Save failed"),
    );
  });

  // ========= saveAppendixImageBytes =========
  test("should encode bytes to base64 and delegate (saveAppendixImageBytes)",
      () async {
    mockAPIManager.setMockResponse(
      successResp(base: {"statusDescription": "Saved bytes"}),
    );

    final msg = await appendixRepository.saveAppendixImageBytes(
      appRefNo: "APP",
      customerType: "Bank",
      fileName: "img.png",
      imageType: "Financial",
      bytes: Uint8List.fromList([1, 2, 3, 255]),
    );

    expect(msg, "Saved bytes");
    expect(mockAPIManager.callLog, hasLength(1));

    // Inspect body to ensure Encoded Base64 reached the API
    final body = mockAPIManager.callLog.first.body!;
    final Map<String, String> reqList =
        body["requestData"] as Map<String, String>;
    final Map<String, dynamic> sent = reqList as Map<String, dynamic>;
    expect(sent["imageData"], base64Encode([1, 2, 3, 255]));
  });

  // ========= deleteAppendixImage =========
  test("should throw normalized message on failure (deleteAppendixImage)",
      () async {
    mockAPIManager.setMockResponse(
      errorResp(message: "fallback", statusDescription: "Cannot delete"),
    );

    expect(
      () => appendixRepository.deleteAppendixImage(
        fileId: 10,
        appRefNo: "APP",
        customerType: "Bank",
      ),
      throwsExceptionWithMessage("Cannot delete"),
    );
  });

  test("should return normalized message on success (deleteAppendixImage)",
      () async {
    mockAPIManager.setMockResponse(
      successResp(base: {"statusDescription": "Deleted OK"}),
    );

    final msg = await appendixRepository.deleteAppendixImage(
      fileId: 11,
      appRefNo: "APP",
      customerType: "Bank",
    );
    expect(msg, "Deleted OK");
    expect(mockAPIManager.callLog, hasLength(1));
    expect(
      mockAPIManager.callLog.first.endpoint,
      APIEndpoints.deleteAppendixImage,
    );
  });

  // ========= getAppendixBusinessSegmentToModel =========
  test(
      "should throw normalized message on failure "
      "(getAppendixBusinessSegmentToModel)", () async {
    mockAPIManager.setMockResponse(
      errorResp(message: "generic", statusDescription: "Bad"),
    );

    expect(
      () => appendixRepository.getAppendixBusinessSegmentToModel(
        appRefNo: "APP",
        rimNo: 123,
      ),
      throwsExceptionWithMessage("Bad"),
    );
  });

  test(
      "should return null when responseData cannot be "
      "resolved to Map "
      "(getAppendixBusinessSegmentToModel)", () async {
    mockAPIManager.setMockResponse(
      successResp(),
    );

    final model = await appendixRepository.getAppendixBusinessSegmentToModel(
      appRefNo: "APP",
      rimNo: 1,
    );
    expect(model, isNull);
  });

  test(
      "should use countryOverView path when "
      "present (getAppendixBusinessSegmentToModel)", () async {
    mockAPIManager.setMockResponse(
      successResp(
        responseData: {
          "countryOverView": {"key": "value"},
        },
      ),
    );

    final model = await appendixRepository.getAppendixBusinessSegmentToModel(
      appRefNo: "APP",
      rimNo: 1,
    );
    expect(model, isA<Appendix>());
  });

  test(
      "should use flat path when no countryOverView (List<Map> "
      "payload) (getAppendixBusinessSegmentToModel)", () async {
    mockAPIManager.setMockResponse(
      successResp(
        responseData: [
          {"flat": "yes"},
        ],
      ),
    );

    final model = await appendixRepository.getAppendixBusinessSegmentToModel(
      appRefNo: "APP",
      rimNo: 1,
    );
    expect(model, isA<Appendix>());
  });

  // ========= deleteReview =========
  test("should throw ArgumentError for invalid type (deleteReview)", () async {
    expect(
      () => appendixRepository.deleteReview(appRefNo: "APP", type: "notes"),
      throwsA(isA<ArgumentError>()),
    );
  });

  test("should throw normalized on API failure (deleteReview)", () async {
    mockAPIManager.setMockResponse(
      errorResp(message: "fallback", statusDescription: "Bad type"),
    );

    expect(
      () => appendixRepository.deleteReview(appRefNo: "APP", type: "strengths"),
      throwsExceptionWithMessage("Bad type"),
    );
  });

  test("should normalize type and return message on success (deleteReview)",
      () async {
    mockAPIManager.setMockResponse(
      successResp(base: {"statusDescription": "Deleted"}),
    );

    final msg = await appendixRepository.deleteReview(
      appRefNo: "APP",
      type: "  ThReAtS  ",
    );
    expect(msg, "Deleted");
    expect(mockAPIManager.callLog, hasLength(1));

    // Verify normalized type in request body
    final body = mockAPIManager.callLog.first.body!;
    expect(body["requestData"]["type"], equals("threats"));
  });

  // ========= saveGroupCorporateStructureCommentList =========
  test(
      "should throw normalized on failure "
      "(saveGroupCorporateStructureCommentList)", () async {
    mockAPIManager.setMockResponse(
      errorResp(message: "fallback", statusDescription: "Bulk save error"),
    );

    final list = <GroupCorporateStructureCommentPayload>[
      const GroupCorporateStructureCommentPayload(
        appRefNo: "APP-TEST-001",
        createdBy: "",
        updatedBy: "",
      ),
    ];

    expect(
      () => appendixRepository.saveGroupCorporateStructureCommentList(list),
      throwsExceptionWithMessage("Bulk save error"),
    );
  });

  test(
      "should return normalized message on success "
      "(saveGroupCorporateStructureCommentList)", () async {
    mockAPIManager.setMockResponse(
      successResp(base: {"statusDescription": "Bulk saved"}),
    );

    final list = <GroupCorporateStructureCommentPayload>[
      const GroupCorporateStructureCommentPayload(
        appRefNo: "APP-TEST-001",
        createdBy: "",
        updatedBy: "",
      ),
    ];
    final msg =
        await appendixRepository.saveGroupCorporateStructureCommentList(list);
    expect(msg, "Bulk saved");
    expect(mockAPIManager.callLog, hasLength(1));
    expect(
      mockAPIManager.callLog.first.endpoint,
      APIEndpoints.saveAppendixComment,
    );
  });

  // ========= fetchAppendixComments =========
  test("should throw normalized on API failure (fetchAppendixComments)",
      () async {
    mockAPIManager.setMockResponse(
      errorResp(message: "old", statusDescription: "Fetch failed"),
    );

    expect(
      () => appendixRepository.fetchAppendixComments("APP"),
      throwsExceptionWithMessage("Fetch failed"),
    );
  });

  test(
      "should return empty list when responseData "
      "is not a List (fetchAppendixComments)", () async {
    mockAPIManager.setMockResponse(
      successResp(responseData: {"k": "v"}),
    );

    final res = await appendixRepository.fetchAppendixComments("APP");
    expect(res, isEmpty);
  });

  test("should parse list, support filter & sorting (fetchAppendixComments)",
      () async {
    final list = [
      {
        "appendixRemarkId": 2,
        "comments": "Test",
        "createdBy": "visa",
        "commentType": "Group Corporate Structure",
      },
      {
        "appendixRemarkId": 1,
        "commentType": "Other",
        "comments": "Test",
        "createdBy": "visa",
      },
      {
        // no id, sort by createdDate fallback
        "commentType": "Group Corporate Structure",
        "comments": "",
        "createdBy": "",
      },
    ];

    mockAPIManager.setMockResponse(
      successResp(responseData: list),
    );

    // No filter
    final all = await appendixRepository.fetchAppendixComments("APP");
    expect(all, isA<List<AppendixComment>>());
    expect(all.length, 3);
    // Sorted by appendixRemarkId asc, then createdDate asc
    expect(all.first.appendixRemarkId, 1);

    // With filter
    final onlyGcs = await appendixRepository.fetchAppendixComments(
      "APP",
      onlyGroupCorporateStructure: true,
    );
    expect(onlyGcs.length, 2);
    // Still sorted
    expect(onlyGcs.first.commentType, "Group Corporate Structure");
  });

  // ========= deleteAppendixComment =========
  test("should throw normalized on failure (deleteAppendixComment)", () async {
    mockAPIManager.setMockResponse(
      errorResp(message: "old", statusDescription: "Cannot delete comment"),
    );

    expect(
      () => appendixRepository.deleteAppendixComment(
        appRefNo: "APP",
        appendixRemarkId: 99,
      ),
      throwsExceptionWithMessage("Cannot delete comment"),
    );
  });

  test("should return normalized message on success (deleteAppendixComment)",
      () async {
    mockAPIManager.setMockResponse(
      successResp(base: {"statusDescription": "Comment deleted"}),
    );

    final msg = await appendixRepository.deleteAppendixComment(
      appRefNo: "APP",
      appendixRemarkId: 100,
    );
    expect(msg, "Comment deleted");
    expect(mockAPIManager.callLog, hasLength(1));
    expect(
      mockAPIManager.callLog.first.endpoint,
      APIEndpoints.deletAppendixComment,
    );
  });
}
