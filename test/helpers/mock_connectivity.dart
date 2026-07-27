import "package:connectivity_plus/connectivity_plus.dart";
import "package:wcas_frontend/core/services/api_service/connectivity_interceptor.dart";

class MockConnectivityWrapper implements ConnectivityWrapper {
  MockConnectivityWrapper({List<ConnectivityResult>? connectivityResult})
      : _connectivityResult = connectivityResult ?? [ConnectivityResult.wifi];
  final List<ConnectivityResult> _connectivityResult;

  @override
  Future<List<ConnectivityResult>> checkConnectivity() async {
    return _connectivityResult;
  }
}

class MockConnectionInterceptor extends ConnectionInterceptor {
  MockConnectionInterceptor({List<ConnectivityResult>? connectivityResult})
      : super(
          connectivityWrapper: MockConnectivityWrapper(
            connectivityResult: connectivityResult,
          ),
        );
}
