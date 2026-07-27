import "dart:convert";
import "dart:typed_data";
import "package:dio/dio.dart";
import "package:easy_localization/easy_localization.dart";
import "package:file_picker/file_picker.dart";
import "package:wcas_frontend/core/env_config.dart";
import "package:wcas_frontend/core/services/api_service/auth_interceptor.dart";
import "package:wcas_frontend/core/services/api_service/connectivity_interceptor.dart";
import "package:wcas_frontend/core/services/api_service/mock_interceptor.dart";
import "package:wcas_frontend/core/services/api_service/request_logging_interceptor.dart";
import "package:wcas_frontend/core/utils/utils.dart";

/// Response Status
///
/// Represents the status of an API response.
enum ResponseStatus {
  /// Request completed successfully.
  success,

  /// Request completed with an error.
  error,
}

/// Application Response
///
/// Represents the standard response returned by the application.
class AppResponse {
  /// Creates an application response.
  AppResponse({
    required this.message,
    this.body,
    this.code,
    this.status,
  });

  /// Response message.
  String message;

  /// Response payload.
  dynamic body;

  /// HTTP or application response code.
  int? code;

  /// Response status.
  ResponseStatus? status;
}

/// API Manager
///
/// Provides HTTP communication, file upload/download, and
/// standardized API response handling.
class APIManager {
  /// Creates an API manager instance.
  ///
  /// Not a singleton to allow multiple instances

  APIManager({
    Dio? dio,
    bool addDefaultInterceptors = true,
  }) {
    _client = dio ??
        Dio(
          BaseOptions(
            baseUrl: EnvConfig.baseUrl,
            receiveTimeout: Duration(seconds: EnvConfig.requestTimeoutSeconds),
          ),
        );

    if (addDefaultInterceptors) {
      _client.interceptors.add(MockInterceptor());
      _client.interceptors.add(RequestLoggingInterceptor());
      _client.interceptors.add(ConnectionInterceptor());
      _client.interceptors.add(AuthInterceptor());
    }
  }

  /// Check once Analysis fix is done.-last update May19 visa
  late Dio _client;

  /// Shared API manager instance.
  static final APIManager instance = APIManager();

  /// Sends a GET request.
  Future<AppResponse> get(
    String endPoint, {
    Map<String, dynamic>? queryParams,
    Map<String, dynamic> additionalHeaders = const {},
  }) async {
    try {
      final response = await _client.get(
        endPoint,
        queryParameters: queryParams,
        options: Options(
          headers: {..._client.options.headers, ...additionalHeaders},
        ),
      );
      return handleAPIResponse(response);
    } on Object catch (e) {
      return handleAPIException(e);
    }
  }

  /// Sends a POST request.
  Future<AppResponse> post(
    String endPoint,
    Object? body, {
    Map<String, dynamic> additionalHeaders = const {},
    bool plainResponse = false,
  }) async {
    try {
      final response = await _client.post(
        endPoint,
        data: body,
        options: Options(
          headers: {..._client.options.headers, ...additionalHeaders},
          responseType: plainResponse ? ResponseType.plain : null,
        ),
      );
      return handleAPIResponse(response);
    } on Object catch (e) {
      return handleAPIException(e);
    }
  }

  /// Sends a DELETE request.
  Future<AppResponse> delete(
    String endPoint,
    Map<String, dynamic> data, {
    Map<String, dynamic> additionalHeaders = const {},
  }) async {
    try {
      final response = await _client.delete(
        endPoint,
        data: data,
        options: Options(
          headers: {..._client.options.headers, ...additionalHeaders},
        ),
      );
      return handleAPIResponse(response);
    } on Object catch (e) {
      return handleAPIException(e);
    }
  }

  /// Sends a PATCH request.
  Future<AppResponse> patch(
    String endPoint,
    Object? data, {
    Map<String, dynamic> additionalHeaders = const {},
  }) async {
    try {
      final response = await _client.patch(
        endPoint,
        data: data,
        options: Options(
          headers: {..._client.options.headers, ...additionalHeaders},
        ),
      );
      return handleAPIResponse(response);
    } on Object catch (e) {
      return handleAPIException(e);
    }
  }

  /// Sends a PUT request.
  Future<AppResponse> put(
    String endPoint,
    Object? data, {
    Map<String, dynamic> additionalHeaders = const {},
  }) async {
    try {
      final response = await _client.put(
        endPoint,
        data: data,
        options: Options(
          headers: {..._client.options.headers, ...additionalHeaders},
        ),
      );
      return handleAPIResponse(response);
    } on Object catch (e) {
      return handleAPIException(e);
    }
  }

  // final response = await APIManager.instance.uploadFile(
  //   APIEndpoints.uploadDocument,
  //   file.path,
  //   fieldName: 'image',
  //   additionalData: {'userId': '123'},
  // );

  /// Uploads a file using multipart/form-data.
  Future<AppResponse> uploadFile(
    String endPoint,
    String filePath, {
    String fieldName = "file",
    Map<String, dynamic> additionalHeaders = const {},
    Map<String, dynamic>? additionalData,
    Uint8List? fileBytes,
    String? fileNameOverride,
  }) async {
    try {
      late MultipartFile filePart;

      if (fileBytes != null) {
        filePart = MultipartFile.fromBytes(
          fileBytes,
          filename: fileNameOverride ?? "upload.xlsx",
        );
      } else {
        filePart = await MultipartFile.fromFile(
          filePath,
          filename: filePath.split("/").last,
        );
      }

      final formData = FormData.fromMap({
        fieldName: filePart,
        if (additionalData != null) ...additionalData,
      });

      final response = await _client.post(
        endPoint,
        data: formData,
        options: Options(
          headers: {
            ..._client.options.headers,
            ...additionalHeaders,
            "Content-Type": "multipart/form-data",
          },
        ),
      );

      return handleAPIResponse(response);
    } on Object catch (e) {
      return handleAPIException(e);
    }
  }

  /// Uploads multiple files with a JSON envelope in multipart/form-data format.
  ///
  /// This method is specifically designed for the EDMS batch document insertion
  /// endpoint.
  ///
  /// Parameters:
  /// - [endPoint]: The API endpoint (e.g.,
  /// '/api/edms/insertDocumentByRepositoryBatch/multipart')
  /// - [envelope]: A Map that will be JSON-encoded and sent as
  /// the 'envelope' field
  /// - [files]: A list of PlatformFile objects to upload (from file_picker
  /// package)
  /// - [additionalHeaders]: Optional additional HTTP headers
  /// - [onSendProgress]: Optional callback to track upload progress
  ///
  /// Returns: Future<> with the API response
  Future<AppResponse> uploadMultipartFiles(
    String endPoint, {
    required Map<dynamic, dynamic> envelope,
    required List<PlatformFile> files,
    Map<String, dynamic> additionalHeaders = const {},
    ProgressCallback? onSendProgress,
  }) async {
    try {
      // 1. Validate input
      if (files.isEmpty) {
        throw ArgumentError("files list cannot be empty.");
      }

      // 2. Convert envelope to JSON string
      final envelopeJson = jsonEncode(envelope);

      // 3. Prepare multipart files from PlatformFile objects
      final multipartFiles = await Future.wait(
        files.map((file) async {
          // Use bytes if available (web), otherwise use path (mobile/desktop)
          if (file.bytes != null) {
            return MultipartFile.fromBytes(
              file.bytes!,
              filename: file.name,
            );
          } else if (file.path != null) {
            return MultipartFile.fromFile(
              file.path!,
              filename: file.name,
            );
          } else {
            throw ArgumentError("PlatformFile must have either bytes or path");
          }
        }),
      );

      // 4. Construct FormData
      final formData = FormData();

      // Add envelope as a text field
      formData.fields.add(MapEntry("envelope", envelopeJson));

      // Add all files under 'files' field
      for (final file in multipartFiles) {
        formData.files.add(MapEntry("files", file));
      }

      _client.options.connectTimeout = const Duration(seconds: 60);
      _client.options.sendTimeout = const Duration(minutes: 5);
      _client.options.receiveTimeout = const Duration(seconds: 60);

      // 5. Send POST request
      final response = await _client.post(
        endPoint,
        data: formData,
        onSendProgress: onSendProgress,
        options: Options(
          headers: {
            ..._client.options.headers,
            ...additionalHeaders,
            "Content-Type": "multipart/form-data",
          },
        ),
      );

      return handleAPIResponse(response);
    } on Object catch (e) {
      return handleAPIException(e);
    }
  }

  /// Build success message using the backend response body.
  String buildUploadSuccessMessage(Map<String, dynamic>? responseData) {
    if (responseData == null) {
      return "";
    }

    final int success = responseData["successCount"] as int? ?? 0;
    final int failed = responseData["failureCount"] as int? ?? 0;

    final List<dynamic> results =
        responseData["results"] as List<dynamic>? ?? const [];

    // -------- Summary message (same logic & wording) --------
    String summaryMessage;

    if (success > 0 && failed == 0) {
      // All success
      summaryMessage = "$success files have been uploaded successfully.";
    } else if (success == 0 && failed > 0) {
      // All failed
      summaryMessage =
          "$failed files have been failed to upload. Please try upload again.";
    } else {
      // Partial success
      summaryMessage = "$success files have been uploaded successfully. "
          "$failed files have been failed to upload. Please try upload again.";
    }

    // -------- File-level lines (same format as other function) --------
    final List<String> fileLines = results.map<String>((result) {
      if (result is! Map<String, dynamic>) {
        return "N/A - N/A - Fail";
      }

      // RIM is not present in this API → N/A (by design)
      final String rimNo = result["rimNo"] ?? "N/A";

      final String fileName = Utils.shortenFileName(
        result["fileName"] as String? ?? "N/A",
      );

      final String status = result["status"] == "CREATED" ? "Success" : "Fail";

      return "$rimNo - $fileName - $status";
    }).toList();

    // -------- Final output (identical structure) --------
    return <String>[
      summaryMessage,
      "",
      ...fileLines,
    ].join("\n");
  }

  /// Builds a success message for digital filing uploads.
  String buildDigitalUploadSuccessMessage(Map<String, dynamic>? response) {
    if (response == null) {
      return "";
    }

    final Object? perFileCountsObj = response["perFileCounts"];
    final Object? resultsObj = response["results"];

    if (perFileCountsObj is! Map<String, dynamic> || resultsObj is! List) {
      return "";
    }

    final int success = (perFileCountsObj["success"] as int?) ?? 0;
    final int failed = (perFileCountsObj["failed"] as int?) ?? 0;

    String summaryMessage;

    if (success > 0 && failed == 0) {
      // All success
      summaryMessage = "$success files have been uploaded successfully.";
    } else if (success == 0 && failed > 0) {
      // All failed
      summaryMessage =
          "$failed files have been failed to upload. Please try upload again.";
    } else {
      // Partial success
      summaryMessage = "$success files have been uploaded successfully. "
          "$failed files have been failed to upload. Please try upload again.";
    }

    final List<String> fileStatusLines = resultsObj.map<String>((result) {
      if (result is! Map<String, dynamic>) {
        return "N/A - N/A - Fail";
      }

      final Object? metadataObj = result["metadata"];

      final String rimNo = metadataObj is Map<String, dynamic>
          ? (metadataObj["RIMNo"] as String?) ?? "N/A"
          : "N/A";

      final String fileName = Utils.shortenFileName(
        result["fileName"] as String? ?? "N/A",
      );

      final String status = result["overall"] == "SUCCESS" ? "Success" : "Fail";

      return "$rimNo - $fileName - $status";
    }).toList();

    return <String>[
      summaryMessage,
      "",
      ...fileStatusLines,
    ].join("\n");
  }

  /// Extracts failed upload details from the response.
  String? extractFailedMessage(Map<String, dynamic> r) {
    final List<Map<String, dynamic>> results = (r["results"] as List<dynamic>)
        .whereType<Map<String, dynamic>>()
        .toList();

    final List<String> messages = results.map((r) {
      final String rimNo = (r["metadata"]?["RIMNo"] as String?) ?? "N/A";
      final String fileName =
          (Utils.shortenFileName(r["fileName"]) as String?) ?? "Unknown file";
      final String overall = (r["overall"] as String?) ?? "N/A";

      return "$rimNo - $fileName - $overall";
    }).toList();
    return messages.join("\n");
  }

  /// Downloads a file from the server.
  Future<AppResponse> downloadFile(
    String endPoint,
    Object? body, {
    Map<String, dynamic> additionalHeaders = const {},
  }) async {
    try {
      final response = await _client.post(
        endPoint,
        data: body,
        options: Options(responseType: ResponseType.bytes),
      );
      return handleAPIResponse(response);
    } on Object catch (e) {
      return handleAPIException(e);
    }
  }

  /// Converts a successful HTTP response into an [AppResponse].
  AppResponse handleAPIResponse(Response response) {
    return AppResponse(
      message: response.statusMessage ?? "",
      body: response.data ?? {},
      code: response.statusCode,
      status: ResponseStatus.success,
    );
  }

  /// Converts an exception into an [AppResponse].
  AppResponse handleAPIException(Object e) {
    if (e is DioException) {
      String message = "common.error".tr();

      if (e.response?.data is Map) {
        message = e.response?.data["status"]
                ?["errorDescription"] ?? // to Handle error from API call
            e.response?.data["baseResponse"]["status"]
                ?["errorDescription"] ?? // To handle error from Dio
            "common.unableToParse".tr();
      }
      return AppResponse(
        message: message,
        body: e.response?.data ?? {},
        code: e.response?.statusCode,
        status: ResponseStatus.error,
      );
    }
    return AppResponse(
      message: "common.unexpectedError".tr(),
      status: ResponseStatus.error,
    );
  }
}
