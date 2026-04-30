import "package:connectivity_plus/connectivity_plus.dart";

class MockConnectivityService {
  static bool _isConnected = true;

  static void setConnectivity(bool isConnected) {
    _isConnected = isConnected;
  }

  static Future<ConnectivityResult> checkConnectivity() async {
    return _isConnected ? ConnectivityResult.wifi : ConnectivityResult.none;
  }

  static Stream<ConnectivityResult> get onConnectivityChanged {
    return Stream.value(
      _isConnected ? ConnectivityResult.wifi : ConnectivityResult.none,
    );
  }
}
