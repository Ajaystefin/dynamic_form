import "package:connectivity_plus/connectivity_plus.dart";

class MockConnectivityService {
  static bool _isConnected = true;

  // This helper intentionally uses a method instead of a setter so tests can
  // update connectivity using a named parameter for better readability.
  // ignore: use_setters_to_change_properties
  static void setConnectivity({required bool isConnected}) {
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
