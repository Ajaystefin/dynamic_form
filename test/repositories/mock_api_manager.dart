// Manual mock implementation for APIManager
import "dart:typed_data";

import "package:dio/src/options.dart";
import "package:file_picker/src/platform_file.dart";
import "package:wcas_frontend/core/services/api_service/api_manager.dart";
import "package:wcas_frontend/models/request/file_attachment/document.dart";

class MockAPIManager implements APIManager {
  AppResponse? _mockResponse;
  dynamic _mockException;
  final List<Map<String, dynamic>> _callLog = [];

  void setMockResponse(AppResponse response) {
    _mockResponse = response;
    _mockException = null;
  }

  void setMockException(dynamic exception) {
    _mockException = exception;
    _mockResponse = null;
  }

  List<Map<String, dynamic>> get callLog => _callLog;

  void clearCallLog() {
    _callLog.clear();
  }

  @override
  Future<AppResponse> post(
    String endPoint,
    dynamic body, {
    Map<String, dynamic> additionalHeaders = const {},
    plainResponse = false,
  }) async {
    _callLog.add({
      "method": "POST",
      "endpoint": endPoint,
      "body": body,
      "headers": additionalHeaders,
    });

    if (_mockException != null) {
      throw _mockException!;
    }

    return _mockResponse!;
  }

  @override
  Future<AppResponse> get(
    String endPoint, {
    Map<String, dynamic>? queryParams,
    Map<String, dynamic> additionalHeaders = const {},
  }) async {
    _callLog.add({
      "method": "GET",
      "endpoint": endPoint,
      "queryParams": queryParams,
      "headers": additionalHeaders,
    });

    if (_mockException != null) {
      throw _mockException!;
    }

    return _mockResponse!;
  }

  @override
  Future<AppResponse> delete(
    String endPoint,
    data, {
    Map<String, dynamic> additionalHeaders = const {},
  }) async {
    _callLog.add({
      "method": "DELETE",
      "endpoint": endPoint,
      "body": data,
      "headers": additionalHeaders,
    });

    if (_mockException != null) {
      throw _mockException!;
    }

    return _mockResponse!;
  }

  @override
  Future<AppResponse> patch(
    String endPoint,
    dynamic data, {
    Map<String, dynamic> additionalHeaders = const {},
  }) async {
    throw UnimplementedError();
  }

  @override
  Future<AppResponse> put(
    String endPoint,
    dynamic data, {
    Map<String, dynamic> additionalHeaders = const {},
  }) async {
    _callLog.add({
      "method": "PUT",
      "endpoint": endPoint,
      "body": data,
      "headers": additionalHeaders,
    });

    if (_mockException != null) {
      throw _mockException!;
    }

    return _mockResponse!;
  }

  @override
  Future<AppResponse> uploadFile(
    String endPoint,
    String filePath, {
    Map<String, dynamic>? additionalData,
    Map<String, dynamic> additionalHeaders = const {},
    String fieldName = "file",
    Uint8List? fileBytes, // <-- add this
    String? fileNameOverride, // <-- and this
  }) async {
    // You can log the call like other methods:
    _callLog.add({
      "method": "UPLOAD",
      "endpoint": endPoint,
      "filePath": filePath,
      "fieldName": fieldName,
      "headers": additionalHeaders,
      "additionalData": additionalData,
      "hasBytes": fileBytes != null,
      "fileNameOverride": fileNameOverride,
    });

    if (_mockException != null) {
      throw _mockException!;
    }

    // Return the pre-set mock response
    return _mockResponse!;
  }

  @override
  Future<AppResponse> downloadFile(
    String endPoint,
    dynamic data, {
    Map<String, dynamic> additionalHeaders = const {},
  }) async {
    _callLog.add({
      "method": "DOWNLOAD",
      "endpoint": endPoint,
      "body": data,
      "headers": additionalHeaders,
    });

    if (_mockException != null) {
      throw _mockException!;
    }

    return _mockResponse!;
  }

  @override
  AppResponse handleAPIResponse(dynamic response) {
    throw UnimplementedError();
  }

  @override
  AppResponse handleAPIException(dynamic e) {
    throw UnimplementedError();
  }

  Future<AppResponse> uploadDocsWithJson(
    String endPoint, {
    required Map<String, dynamic> baseRequest,
    required List<Document> mergedDocs,
    required List<Map<String, dynamic>> docs,
    String filesFieldName = "files",
    String jsonFieldName = "payload",
    bool sendJsonAsBinaryPart = true,
    Map<String, dynamic> additionalHeaders = const {},
    Map<String, dynamic>? extraFormFields,
    ProgressCallback? onSendProgress,
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
  }) async {
    return _mockResponse!;
  }

  @override
  String buildUploadSuccessMessage(Map<String, dynamic> body) {
    return "Upload success";
  }

  @override
  String buildDigitalUploadSuccessMessage(Map<String, dynamic>? body) {
    return "Upload success";
  }

  @override
  String extractFailedMessage(Map<String, dynamic> r) {
    return "Upload failed";
  }
}
