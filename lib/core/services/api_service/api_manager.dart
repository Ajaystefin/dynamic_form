import 'package:dio/dio.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:pretty_dio_logger/pretty_dio_logger.dart';
import 'package:wcas_frontend/core/services/api_service/auth_interceptor.dart';
import 'package:wcas_frontend/core/services/api_service/connectivity_interceptor.dart';
import 'package:wcas_frontend/core/services/api_service/mock_interceptor.dart';
import 'package:wcas_frontend/core/env_config.dart';

enum ResponseStatus { success, error }

class AppResponse {
  String message;
  dynamic body;
  int? code;
  ResponseStatus? status;
  AppResponse({required this.message, this.body, this.code, this.status});
}

class APIManager {
  late Dio _client;
  static APIManager get instance =>
      APIManager(); // Not a singleton, to allow multiple instances

  APIManager({
    Dio? dio,
    bool addDefaultInterceptors = true,
  }) {
    _client = dio ??
        Dio(BaseOptions(
            baseUrl: EnvConfig.baseUrl,
            receiveTimeout:
                Duration(seconds: EnvConfig.requestTimeoutSeconds)));

    if (addDefaultInterceptors) {
      _client.interceptors.add(MockInterceptor());
      _client.interceptors.add(PrettyDioLogger(
        enabled: EnvConfig.enableLogging,
        requestHeader: true,
        requestBody: true,
        responseBody: true,
        responseHeader: false,
      ));
      _client.interceptors.add(ConnectionInterceptor());
      _client.interceptors.add(AuthInterceptor());
    }
  }

  Future<AppResponse> get(String endPoint,
      {Map<String, dynamic>? queryParams,
      Map<String, dynamic> additionalHeaders = const {}}) async {
    try {
      final response = await _client.get(
        endPoint,
        queryParameters: queryParams,
        options: Options(
            headers: {..._client.options.headers, ...additionalHeaders}),
      );
      return handleAPIResponse(response);
    } catch (e) {
      return handleAPIException(e);
    }
  }

  Future<AppResponse> post(String endPoint, dynamic body,
      {Map<String, dynamic> additionalHeaders = const {}}) async {
    try {
      final response = await _client.post(
        endPoint,
        data: body,
        options: Options(
            headers: {..._client.options.headers, ...additionalHeaders}),
      );
      return handleAPIResponse(response);
    } catch (e) {
      return handleAPIException(e);
    }
  }

  Future<AppResponse> delete(String endPoint, Map<String, dynamic> data,
      {Map<String, dynamic> additionalHeaders = const {}}) async {
    try {
      final response = await _client.delete(
        endPoint,
        data: data,
        options: Options(
            headers: {..._client.options.headers, ...additionalHeaders}),
      );
      return handleAPIResponse(response);
    } catch (e) {
      return handleAPIException(e);
    }
  }

  Future<AppResponse> patch(String endPoint, dynamic data,
      {Map<String, dynamic> additionalHeaders = const {}}) async {
    try {
      final response = await _client.patch(
        endPoint,
        data: data,
        options: Options(
            headers: {..._client.options.headers, ...additionalHeaders}),
      );
      return handleAPIResponse(response);
    } catch (e) {
      return handleAPIException(e);
    }
  }

  Future<AppResponse> put(String endPoint, dynamic data,
      {Map<String, dynamic> additionalHeaders = const {}}) async {
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
    String fieldName = 'file',
    Map<String, dynamic> additionalHeaders = const {},
    Map<String, dynamic>? additionalData,
  }) async {
    try {
      final file = await MultipartFile.fromFile(filePath,
          filename: filePath.split('/').last);

      final formData = FormData.fromMap({
        fieldName: file,
        if (additionalData != null) ...additionalData,
      });

      final response = await _client.post(
        endPoint,
        data: formData,
        options: Options(
          headers: {
            ..._client.options.headers,
            ...additionalHeaders,
            'Content-Type': 'multipart/form-data',
          },
        ),
      );

      return handleAPIResponse(response);
    } catch (e) {
      return handleAPIException(e);
    }
  }

  Future<AppResponse> downloadFile(String endPoint, dynamic body,
      {Map<String, dynamic> additionalHeaders = const {}}) async {
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
        status: ResponseStatus.success);
  }

  AppResponse handleAPIException(e) {
    if (e is DioException) {
      String message = "common.error".tr();

      if (e.response?.data is Map) {
        message = e.response?.data['status']
                ?['errorDescription'] ?? // to Handle error from API call
            e.response?.data['baseResponse']['status']
                ?['errorDescription'] ?? // To handle error from Dio
            "common.unableToParse".tr();
      }
      return AppResponse(
          message: message,
          body: e.response?.data ?? {},
          code: e.response?.statusCode,
          status: ResponseStatus.error);
    }
    return AppResponse(
        message: "common.unexpectedError".tr(), status: ResponseStatus.error);
  }
}
