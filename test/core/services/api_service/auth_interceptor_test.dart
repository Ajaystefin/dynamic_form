import "dart:io";

import "package:dio/dio.dart";
import "package:flutter_test/flutter_test.dart";
import "package:mocktail/mocktail.dart";
import "package:wcas_frontend/core/constants/constants.dart";
import "package:wcas_frontend/core/env_config.dart";
import "package:wcas_frontend/core/globals.dart";
import "package:wcas_frontend/core/services/api_service/auth_interceptor.dart";
import "package:wcas_frontend/core/services/local_storage_service.dart";
import "package:wcas_frontend/models/login/role.dart";
import "package:wcas_frontend/models/login/user.dart";
import "package:wcas_frontend/repositories/auth_repository.dart";

import "../../../test_config.dart";

class MockRequestInterceptorHandler extends Mock
    implements RequestInterceptorHandler {}

class MockErrorInterceptorHandler extends Mock
    implements ErrorInterceptorHandler {}

class MockLocalStorageService extends Mock implements LocalStorageService {}

class MockAuthRepository extends Mock implements AuthRepository {}

class MockStorageInterface extends Mock implements StorageInterface {}

void main() {
  late AuthInterceptor authInterceptor;
  late MockRequestInterceptorHandler mockRequestHandler;
  late MockErrorInterceptorHandler mockErrorHandler;
  late MockLocalStorageService mockLocalStorageService;
  late MockAuthRepository mockAuthRepository;
  late MockStorageInterface mockStorageInterface;

  setUpAll(() async {
    await TestConfig.setupTestEnvironment();

    // Set up environment variables for testing
    TestWidgetsFlutterBinding.ensureInitialized();

    // Set up EnvConfig with test environment
    await EnvConfig.setEnvironment();

    // Initialize Globals.user with test data
    Globals.user = User(
      id: "test_user_id",
      name: "Test User",
      email: "test@example.com",
      currentRole: Role(id: 1, name: "Test Role"),
      availableRoles: [Role(id: 1, name: "Test Role")],
    );
    Globals.currentRoute = "/dashboard";

    // Register fallback values
    registerFallbackValue(RequestOptions(path: ""));
    registerFallbackValue(
      DioException(
        requestOptions: RequestOptions(path: ""),
        type: DioExceptionType.badResponse,
      ),
    );
  });

  setUp(() {
    mockRequestHandler = MockRequestInterceptorHandler();
    mockErrorHandler = MockErrorInterceptorHandler();
    mockLocalStorageService = MockLocalStorageService();
    mockAuthRepository = MockAuthRepository();
    mockStorageInterface = MockStorageInterface();

    // Set up mock storage interface
    when(() => mockStorageInterface.init(path: any(named: "path")))
        .thenAnswer((_) async {});
    when(() => mockStorageInterface.put(any(), any(), any()))
        .thenAnswer((_) async {});
    when(() => mockStorageInterface.get(any(), any()))
        .thenAnswer((_) async => null);
    when(() => mockStorageInterface.delete(any(), any()))
        .thenAnswer((_) async {});
    when(() => mockStorageInterface.clearBox(any())).thenAnswer((_) async {});

    // Set up mock localStorageService
    when(() => mockLocalStorageService.put(any(), any(), any()))
        .thenAnswer((_) async {});
    when(() => mockLocalStorageService.get(any(), any()))
        .thenAnswer((_) async => null);
    when(() => mockLocalStorageService.delete(any(), any()))
        .thenAnswer((_) async {});
    when(() => mockLocalStorageService.clearBox(any()))
        .thenAnswer((_) async {});

    // Set up mock authRepository
    when(() => mockAuthRepository.refreshToken())
        .thenAnswer((_) async => "new_refresh_token");
    when(() => mockAuthRepository.logout()).thenAnswer((_) async {});

    // Create AuthInterceptor with mocked dependencies
    authInterceptor = AuthInterceptor(
      localStorageService: mockLocalStorageService,
      authRepository: mockAuthRepository,
    );
  });

  tearDownAll(() async {
    await TestConfig.cleanup();
  });

  group("AuthInterceptor - onRequest", () {
    test("should handle request with no token", () async {
      // Arrange
      when(() => mockRequestHandler.next(any())).thenAnswer((_) async {});
      when(
        () => mockLocalStorageService.get<String>(
          LocalStorageBoxes.user,
          LocalStorageKeys.authToken,
        ),
      ).thenAnswer((_) async => null);

      final options = RequestOptions(path: "/api/test");

      // Act
      await authInterceptor.onRequest(options, mockRequestHandler);

      // Assert
      verify(() => mockRequestHandler.next(options)).called(1);
      verifyNever(
        () => mockLocalStorageService.get<int>(
          LocalStorageBoxes.user,
          LocalStorageKeys.tokenExpiryTime,
        ),
      );
    });

    test("should handle request with valid token", () async {
      // Arrange
      when(() => mockRequestHandler.next(any())).thenAnswer((_) async {});
      when(
        () => mockLocalStorageService.get<String>(
          LocalStorageBoxes.user,
          LocalStorageKeys.authToken,
        ),
      ).thenAnswer((_) async => "valid_token");
      when(
        () => mockLocalStorageService.get<int>(
          LocalStorageBoxes.user,
          LocalStorageKeys.tokenExpiryTime,
        ),
      ).thenAnswer(
        (_) async => DateTime.now().millisecondsSinceEpoch + 3600000,
      ); // 1 hour from now

      final options = RequestOptions(path: "/api/test");

      // Act
      await authInterceptor.onRequest(options, mockRequestHandler);

      // Assert
      verify(() => mockRequestHandler.next(options)).called(1);
      expect(options.headers["Content-Type"], equals("application/json"));
      expect(options.headers["Authorization"], equals("Bearer valid_token"));
    });

    test("should handle request with expired token and refresh", () async {
      // Arrange
      when(() => mockRequestHandler.next(any())).thenAnswer((_) async {});
      when(
        () => mockLocalStorageService.get<String>(
          LocalStorageBoxes.user,
          LocalStorageKeys.authToken,
        ),
      ).thenAnswer((_) async => "expired_token");
      when(
        () => mockLocalStorageService.get<int>(
          LocalStorageBoxes.user,
          LocalStorageKeys.tokenExpiryTime,
        ),
      ).thenAnswer(
        (_) async => DateTime.now().millisecondsSinceEpoch - 3600000,
      ); // 1 hour ago
      when(() => mockAuthRepository.refreshToken())
          .thenAnswer((_) async => "new_refreshed_token");

      final options = RequestOptions(path: "/api/test");

      // Act
      await authInterceptor.onRequest(options, mockRequestHandler);

      // Assert
      verify(() => mockAuthRepository.refreshToken()).called(1);
      verify(() => mockRequestHandler.next(options)).called(1);
      expect(
        options.headers["Authorization"],
        equals("Bearer new_refreshed_token"),
      );
    });

    test("should not refresh token for refresh token calls", () async {
      // Arrange
      when(() => mockRequestHandler.next(any())).thenAnswer((_) async {});
      when(
        () => mockLocalStorageService.get<String>(
          LocalStorageBoxes.user,
          LocalStorageKeys.authToken,
        ),
      ).thenAnswer((_) async => "expired_token");
      when(
        () => mockLocalStorageService.get<int>(
          LocalStorageBoxes.user,
          LocalStorageKeys.tokenExpiryTime,
        ),
      ).thenAnswer(
        (_) async => DateTime.now().millisecondsSinceEpoch - 3600000,
      ); // 1 hour ago

      final options = RequestOptions(path: APIEndpoints.refreshToken);

      // Act
      await authInterceptor.onRequest(options, mockRequestHandler);

      // Assert
      verifyNever(() => mockAuthRepository.refreshToken());
      verify(() => mockRequestHandler.next(options)).called(1);
      expect(options.headers["Authorization"], equals("Bearer expired_token"));
    });

    test("should handle path containing refresh token endpoint", () async {
      // Arrange
      when(() => mockRequestHandler.next(any())).thenAnswer((_) async {});
      when(
        () => mockLocalStorageService.get<String>(
          LocalStorageBoxes.user,
          LocalStorageKeys.authToken,
        ),
      ).thenAnswer((_) async => "expired_token");
      when(
        () => mockLocalStorageService.get<int>(
          LocalStorageBoxes.user,
          LocalStorageKeys.tokenExpiryTime,
        ),
      ).thenAnswer(
        (_) async => DateTime.now().millisecondsSinceEpoch - 3600000,
      ); // 1 hour ago

      final options =
          RequestOptions(path: "/api/${APIEndpoints.refreshToken}/extra");

      // Act
      await authInterceptor.onRequest(options, mockRequestHandler);

      // Assert
      verifyNever(() => mockAuthRepository.refreshToken());
      verify(() => mockRequestHandler.next(options)).called(1);
      expect(options.headers["Authorization"], equals("Bearer expired_token"));
    });

    test("should handle token expiry time as string (type error)", () async {
      // Arrange
      when(() => mockRequestHandler.next(any())).thenAnswer((_) async {});
      when(
        () => mockLocalStorageService.get<String>(
          LocalStorageBoxes.user,
          LocalStorageKeys.authToken,
        ),
      ).thenAnswer((_) async => "valid_token");
      when(
        () => mockLocalStorageService.get<int>(
          LocalStorageBoxes.user,
          LocalStorageKeys.tokenExpiryTime,
        ),
      ).thenAnswer((_) async => "invalid_string_value" as int);

      final options = RequestOptions(path: "/api/test");

      // Act & Assert
      expect(
        () => authInterceptor.onRequest(options, mockRequestHandler),
        throwsA(isA<TypeError>()),
      );
    });
  });

  group("AuthInterceptor - onError", () {
    test("should handle 401 error when not on login route", () {
      // Arrange
      Globals.currentRoute = "/dashboard";

      final dioError = DioException(
        requestOptions: RequestOptions(path: "/api/test"),
        response: Response(
          requestOptions: RequestOptions(path: "/api/test"),
          statusCode: HttpStatus.unauthorized,
        ),
        type: DioExceptionType.badResponse,
      );

      when(() => mockErrorHandler.next(any())).thenAnswer((_) {});

      // Act
      authInterceptor.onError(dioError, mockErrorHandler);

      // Assert
      verify(() => mockAuthRepository.logout()).called(1);
      verify(() => mockErrorHandler.next(dioError)).called(1);
    });

    test("should handle 401 error when on login route", () {
      // Arrange
      Globals.currentRoute = Routes.login;

      final dioError = DioException(
        requestOptions: RequestOptions(path: "/api/test"),
        response: Response(
          requestOptions: RequestOptions(path: "/api/test"),
          statusCode: HttpStatus.unauthorized,
        ),
        type: DioExceptionType.badResponse,
      );

      when(() => mockErrorHandler.next(any())).thenAnswer((_) {});

      // Act
      authInterceptor.onError(dioError, mockErrorHandler);

      // Assert
      verifyNever(() => mockAuthRepository.logout());
      verify(() => mockErrorHandler.next(dioError)).called(1);
    });

    test("should handle non-401 errors normally", () {
      // Arrange
      Globals.currentRoute = "/dashboard";

      final dioError = DioException(
        requestOptions: RequestOptions(path: "/api/test"),
        response: Response(
          requestOptions: RequestOptions(path: "/api/test"),
          statusCode: HttpStatus.badRequest,
        ),
        type: DioExceptionType.badResponse,
      );

      when(() => mockErrorHandler.next(any())).thenAnswer((_) {});

      // Act
      authInterceptor.onError(dioError, mockErrorHandler);

      // Assert
      verifyNever(() => mockAuthRepository.logout());
      verify(() => mockErrorHandler.next(dioError)).called(1);
    });

    test("should handle error without response", () {
      // Arrange
      Globals.currentRoute = "/dashboard";

      final dioError = DioException(
        requestOptions: RequestOptions(path: "/api/test"),
        type: DioExceptionType.connectionTimeout,
      );

      when(() => mockErrorHandler.next(any())).thenAnswer((_) {});

      // Act
      authInterceptor.onError(dioError, mockErrorHandler);

      // Assert
      verifyNever(() => mockAuthRepository.logout());
      verify(() => mockErrorHandler.next(dioError)).called(1);
    });

    test("should handle error with null status code", () {
      // Arrange
      Globals.currentRoute = "/dashboard";

      final dioError = DioException(
        requestOptions: RequestOptions(path: "/api/test"),
        response: Response(
          requestOptions: RequestOptions(path: "/api/test"),
          statusCode: null,
        ),
        type: DioExceptionType.badResponse,
      );

      when(() => mockErrorHandler.next(any())).thenAnswer((_) {});

      // Act
      authInterceptor.onError(dioError, mockErrorHandler);

      // Assert
      verifyNever(() => mockAuthRepository.logout());
      verify(() => mockErrorHandler.next(dioError)).called(1);
    });

    test("should handle different error types", () {
      // Arrange
      Globals.currentRoute = "/dashboard";

      final errorTypes = [
        DioExceptionType.connectionTimeout,
        DioExceptionType.sendTimeout,
        DioExceptionType.receiveTimeout,
        DioExceptionType.cancel,
        DioExceptionType.unknown,
      ];

      for (final errorType in errorTypes) {
        final dioError = DioException(
          requestOptions: RequestOptions(path: "/api/test"),
          type: errorType,
        );

        when(() => mockErrorHandler.next(any())).thenAnswer((_) {});

        // Act
        authInterceptor.onError(dioError, mockErrorHandler);

        // Assert
        verify(() => mockErrorHandler.next(dioError)).called(1);
      }
    });
  });

  group("AuthInterceptor - Integration Tests", () {
    test("should handle complete request flow with token refresh", () async {
      // Arrange
      when(() => mockRequestHandler.next(any())).thenAnswer((_) async {});
      when(
        () => mockLocalStorageService.get<String>(
          LocalStorageBoxes.user,
          LocalStorageKeys.authToken,
        ),
      ).thenAnswer((_) async => "old_token");
      when(
        () => mockLocalStorageService.get<int>(
          LocalStorageBoxes.user,
          LocalStorageKeys.tokenExpiryTime,
        ),
      ).thenAnswer(
        (_) async => DateTime.now().millisecondsSinceEpoch - 1000,
      ); // Just expired
      when(() => mockAuthRepository.refreshToken())
          .thenAnswer((_) async => "new_token");

      final options = RequestOptions(path: "/api/users/profile");

      // Act
      await authInterceptor.onRequest(options, mockRequestHandler);

      // Assert
      verify(() => mockAuthRepository.refreshToken()).called(1);
      verify(() => mockRequestHandler.next(options)).called(1);
      expect(options.headers["Authorization"], equals("Bearer new_token"));
    });

    test("should handle refresh token call with expired token", () async {
      // Arrange
      when(() => mockRequestHandler.next(any())).thenAnswer((_) async {});
      when(
        () => mockLocalStorageService.get<String>(
          LocalStorageBoxes.user,
          LocalStorageKeys.authToken,
        ),
      ).thenAnswer((_) async => "expired_token");
      when(
        () => mockLocalStorageService.get<int>(
          LocalStorageBoxes.user,
          LocalStorageKeys.tokenExpiryTime,
        ),
      ).thenAnswer(
        (_) async => DateTime.now().millisecondsSinceEpoch - 1000,
      ); // Just expired

      final options = RequestOptions(path: APIEndpoints.refreshToken);

      // Act
      await authInterceptor.onRequest(options, mockRequestHandler);

      // Assert
      verifyNever(() => mockAuthRepository.refreshToken());
      verify(() => mockRequestHandler.next(options)).called(1);
      expect(options.headers["Authorization"], equals("Bearer expired_token"));
    });

    test("should handle error flow with logout", () {
      // Arrange
      Globals.currentRoute = "/dashboard";

      final dioError = DioException(
        requestOptions: RequestOptions(path: "/api/test"),
        response: Response(
          requestOptions: RequestOptions(path: "/api/test"),
          statusCode: HttpStatus.unauthorized,
        ),
        type: DioExceptionType.badResponse,
      );

      when(() => mockErrorHandler.next(any())).thenAnswer((_) {});

      // Act
      authInterceptor.onError(dioError, mockErrorHandler);

      // Assert
      verify(() => mockAuthRepository.logout()).called(1);
      verify(() => mockErrorHandler.next(dioError)).called(1);
    });
  });
}
