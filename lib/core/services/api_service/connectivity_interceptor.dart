import "package:connectivity_plus/connectivity_plus.dart";
import "package:dio/dio.dart";
import "package:easy_localization/easy_localization.dart";

abstract class ConnectivityWrapper {
  Future<List<ConnectivityResult>> checkConnectivity();
}

class DefaultConnectivityWrapper implements ConnectivityWrapper {
  DefaultConnectivityWrapper({Connectivity? connectivity})
      : _connectivity = connectivity ?? Connectivity();
  final Connectivity _connectivity;

  @override
  Future<List<ConnectivityResult>> checkConnectivity() async {
    return _connectivity.checkConnectivity();
  }
}

class ConnectionInterceptor extends Interceptor {
  ConnectionInterceptor({ConnectivityWrapper? connectivityWrapper})
      : _connectivityWrapper =
            connectivityWrapper ?? DefaultConnectivityWrapper();
  final ConnectivityWrapper _connectivityWrapper;

  @override
  Future<void> onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    final connectivityResult = await _connectivityWrapper.checkConnectivity();
    if (!connectivityResult.contains(ConnectivityResult.mobile) &&
        !connectivityResult.contains(ConnectivityResult.wifi)) {
      return handler.reject(
        DioException(
          requestOptions: options,
          response: Response(
            requestOptions: options,
            data: {"message": "common.noInternet".tr()},
          ),
        ),
      );
    }
    super.onRequest(options, handler);
  }
}
