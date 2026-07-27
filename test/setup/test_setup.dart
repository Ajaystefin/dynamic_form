import "package:connectivity_plus/connectivity_plus.dart";
import "package:flutter_test/flutter_test.dart";
import "package:wcas_frontend/core/env_config.dart";
import "package:wcas_frontend/core/services/api_service/connectivity_interceptor.dart";

class TestSetup {
  static Future<void> initialize() async {
    TestWidgetsFlutterBinding.ensureInitialized();
    await EnvConfig.setEnvironment();

    // Mock connectivity to avoid plugin issues
    _setupMockConnectivity();
  }

  static void _setupMockConnectivity() {
    // This is a workaround to avoid connectivity plugin issues in tests
    // In a real scenario, you would want to properly mock the connectivity
    // but for now, we'll just ensure the tests don't fail due to connectivity
  }
}

// Mock connectivity wrapper for tests
class TestConnectivityWrapper implements ConnectivityWrapper {
  @override
  Future<List<ConnectivityResult>> checkConnectivity() async {
    // Always return wifi to avoid connectivity issues in tests
    return [ConnectivityResult.wifi];
  }
}

// Test connection interceptor that doesn't require real connectivity
class TestConnectionInterceptor extends ConnectionInterceptor {
  TestConnectionInterceptor()
      : super(connectivityWrapper: TestConnectivityWrapper());
}
