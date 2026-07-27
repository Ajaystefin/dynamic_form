import "package:dio/dio.dart";
import "package:wcas_frontend/core/services/api_service/api_manager.dart";
import "package:wcas_frontend/core/services/api_service/auth_interceptor.dart";
import "mock_connectivity.dart";

class MockAPIManager extends APIManager {
  MockAPIManager({super.dio}) : super(addDefaultInterceptors: false);

  static APIManager createWithMockConnectivity() {
    final dio = Dio();
    dio.interceptors.add(MockConnectionInterceptor());
    dio.interceptors.add(AuthInterceptor());
    return MockAPIManager(dio: dio);
  }
}
