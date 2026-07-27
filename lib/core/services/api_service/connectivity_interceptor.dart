import "package:connectivity_plus/connectivity_plus.dart";
import "package:dio/dio.dart";
import "package:easy_localization/easy_localization.dart";

/// Connectivity Wrapper
///
/// Defines connectivity checking operations.
abstract class ConnectivityWrapper {
  /// Returns the current connectivity status.
  Future<List<ConnectivityResult>> checkConnectivity();
}

/// Default Connectivity Wrapper
///
/// Provides connectivity information using the Connectivity package.
class DefaultConnectivityWrapper implements ConnectivityWrapper {
  /// Creates a connectivity wrapper instance.
  DefaultConnectivityWrapper({Connectivity? connectivity})
      : _connectivity = connectivity ?? Connectivity();
  final Connectivity _connectivity;

  @override
  Future<List<ConnectivityResult>> checkConnectivity() async {
    return _connectivity.checkConnectivity();
  }
}

/// Connection Interceptor
///
/// Prevents API requests when no internet connection is available.
class ConnectionInterceptor extends Interceptor {
  /// Creates a connection interceptor.
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
