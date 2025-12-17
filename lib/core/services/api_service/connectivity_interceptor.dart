import 'package:dio/dio.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:easy_localization/easy_localization.dart';

abstract class ConnectivityWrapper {
  Future<List<ConnectivityResult>> checkConnectivity();
}

class DefaultConnectivityWrapper implements ConnectivityWrapper {
  final Connectivity _connectivity;

  DefaultConnectivityWrapper({Connectivity? connectivity})
      : _connectivity = connectivity ?? Connectivity();

  @override
  Future<List<ConnectivityResult>> checkConnectivity() async {
    return await _connectivity.checkConnectivity();
  }
}

class ConnectionInterceptor extends Interceptor {
  final ConnectivityWrapper _connectivityWrapper;

  ConnectionInterceptor({ConnectivityWrapper? connectivityWrapper})
      : _connectivityWrapper =
            connectivityWrapper ?? DefaultConnectivityWrapper();

  @override
  Future<void> onRequest(
      RequestOptions options, RequestInterceptorHandler handler) async {
    final connectivityResult = await _connectivityWrapper.checkConnectivity();
    if (!connectivityResult.contains(ConnectivityResult.mobile) &&
        !connectivityResult.contains(ConnectivityResult.wifi)) {
      return handler.reject(
        DioException(
            requestOptions: options,
            response: Response(
                requestOptions: options,
                data: {"message": "common.noInternet".tr()})),
      );
    }
    super.onRequest(options, handler);
  }
}
