import "dart:convert";
import "dart:typed_data";

import "package:dio/dio.dart";
import "package:easy_localization/easy_localization.dart";
import "package:file_picker/file_picker.dart";

import "package:wcas_frontend/core/env_config.dart";
import "package:wcas_frontend/core/services/api_service/auth_interceptor.dart";
import "package:wcas_frontend/core/services/api_service/connectivity_interceptor.dart";
import "package:wcas_frontend/core/services/api_service/mock_interceptor.dart";
import "package:wcas_frontend/core/utils/utils.dart";

enum ResponseStatus { success, error }

class AppResponse {
  AppResponse({required this.message, this.body, this.code, this.status});
  String message;
  dynamic body;
  int? code;
  ResponseStatus? status;
}

class APIManager {
  // Not a singleton, to allow multiple instances

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
      // _client.interceptors.add(PrettyDioLogger(
      //   enabled: EnvConfig.enableLogging,
      //   requestHeader: true,
      //   requestBody: true,
      //   responseBody: true,
      //   responseHeader: false,
      // ));
      _client.interceptors.add(ConnectionInterceptor());
      _client.interceptors.add(AuthInterceptor());
    }
  }
  late Dio _client;
  static APIManager get instance => APIManager();

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
    } catch (e) {
      return handleAPIException(e);
    }
  }

  Future<AppResponse> post(
    String endPoint,
    dynamic body, {
    Map<String, dynamic> additionalHeaders = const {},
    plainResponse = false,
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
    } catch (e) {
      return handleAPIException(e);
    }
  }

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
    } catch (e) {
      return handleAPIException(e);
    }
  }

  Future<AppResponse> patch(
    String endPoint,
    dynamic data, {
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
    } catch (e) {
      return handleAPIException(e);
    }
  }

  Future<AppResponse> put(
    String endPoint,
    dynamic data, {
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
    } catch (e) {
      return handleAPIException(e);
    }
  }

  // final response = await APIManager.instance.uploadFile(
  //   APIEndpoints.uploadDocument,
  //   file.path,
  //   fieldName: 'image',
  //   additionalData: {'userId': '123'},
  // );
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
    } catch (e) {
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
  /// - [envelope]: A Map<String, dynamic> that will be JSON-encoded and sent as
  /// the 'envelope' field
  /// - [files]: A list of PlatformFile objects to upload (from file_picker
  /// package)
  /// - [additionalHeaders]: Optional additional HTTP headers
  /// - [onSendProgress]: Optional callback to track upload progress
  ///
  /// Returns: Future<AppResponse> with the API response
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
    } catch (e) {
      return handleAPIException(e);
    }
  }

  /// Build success message using the backend response body.
  String buildUploadSuccessMessage(Map<String, dynamic> body) {
    final Map<String, dynamic> data =
        (body["responseData"] as Map<String, dynamic>?) ?? <String, dynamic>{};

    // Results list
    final List<Map<String, dynamic>> results =
        (data["results"] as List<dynamic>? ?? const <dynamic>[])
            .whereType<Map<String, dynamic>>()
            .toList();

    // Build per-file message lines
    final List<String> fileLines = <String>[];

    for (final Map<String, dynamic> r in results) {
      final String name =
          (Utils.shortenFileName(r["fileName"]) as String?)?.trim() ??
              "Unnamed file";

      final String status =
          (r["status"] as String?) == "CREATED" ? "Success" : "Fail";

      final String? err = (r["errorMessage"] as String?);

      if (status == "Fail" && err != null && err.isNotEmpty) {
        fileLines.add("$name - Fail ($err)");
      } else {
        fileLines.add("$name - $status");
      }
    }

    // Final message
    return [
      if (fileLines.isNotEmpty) "",
      ...fileLines,
    ].join("\n");
  }

  String buildDigitalUploadSuccessMessage(Map<String, dynamic>? response) {
    final results = response?["results"];

    if (results is! List || results.isEmpty) {
      return "";
    }

    final List<String> messages = results.map<String>((result) {
      if (result is! Map<String, dynamic>) {
        return "N/A - N/A - Failed";
      }

      final String rimNo = result["metadata"] is Map<String, dynamic>
          ? (result["metadata"]["RIMNo"] as String?) ?? "N/A"
          : "N/A";

      final String fileName =
          Utils.shortenFileName(result["fileName"] as String? ?? "N/A");

      final String overallStatus =
          (result["overall"] as String?) == "SUCCESS" ? "Success" : "Failed";

      return "$rimNo - $fileName - $overallStatus";
    }).toList();

    return messages.join("\n");
  }

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

  Future<AppResponse> downloadFile(
    String endPoint,
    dynamic body, {
    Map<String, dynamic> additionalHeaders = const {},
  }) async {
    try {
      final response = await _client.post(
        endPoint,
        data: body,
        options: Options(responseType: ResponseType.bytes),
      );
      return handleAPIResponse(response);
    } catch (e) {
      return handleAPIException(e);
    }
  }

  AppResponse handleAPIResponse(Response response) {
    return AppResponse(
      message: response.statusMessage ?? "",
      body: response.data ?? {},
      code: response.statusCode,
      status: ResponseStatus.success,
    );
  }

  AppResponse handleAPIException(e) {
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
