import "package:connectivity_plus/connectivity_plus.dart";
import "package:dio/dio.dart";
import "package:flutter_test/flutter_test.dart";
import "package:mocktail/mocktail.dart";
import "package:wcas_frontend/core/services/api_service/connectivity_interceptor.dart";

class MockRequestInterceptorHandler extends Mock
    implements RequestInterceptorHandler {}

class MockConnectivity extends Mock implements Connectivity {}

class MockConnectivityWrapper extends Mock implements ConnectivityWrapper {}

void main() {
  late ConnectionInterceptor connectionInterceptor;
  late MockRequestInterceptorHandler mockRequestHandler;
  late MockConnectivityWrapper mockConnectivityWrapper;

  setUpAll(() {
    // Set up test environment
    TestWidgetsFlutterBinding.ensureInitialized();

    // Register fallback values
    registerFallbackValue(RequestOptions(path: ""));
    registerFallbackValue(
      DioException(
        requestOptions: RequestOptions(path: ""),
        type: DioExceptionType.badResponse,
      ),
    );

    // Set up localization for testing
    // This prevents the localization warnings in tests
  });

  setUp(() {
    mockRequestHandler = MockRequestInterceptorHandler();
    mockConnectivityWrapper = MockConnectivityWrapper();

    // Set up default mock behavior
    when(() => mockConnectivityWrapper.checkConnectivity())
        .thenAnswer((_) async => [ConnectivityResult.wifi]);

    // Create ConnectionInterceptor with mocked connectivity wrapper
    connectionInterceptor =
        ConnectionInterceptor(connectivityWrapper: mockConnectivityWrapper);
  });

  group("ConnectionInterceptor - Constructor", () {
    test(
        "should create interceptor with default"
        " connectivity wrapper when none provided", () {
      // Arrange & Act
      final interceptor = ConnectionInterceptor();

      // Assert
      expect(interceptor, isA<ConnectionInterceptor>());
    });

    test("should create interceptor with provided connectivity wrapper", () {
      // Arrange
      final mockWrapper = MockConnectivityWrapper();

      // Act
      final interceptor =
          ConnectionInterceptor(connectivityWrapper: mockWrapper);

      // Assert
      expect(interceptor, isA<ConnectionInterceptor>());
    });
  });

  group("ConnectionInterceptor - onRequest", () {
    test("should allow request when mobile connectivity is available",
        () async {
      // Arrange
      when(() => mockRequestHandler.next(any())).thenAnswer((_) async {});

      final options = RequestOptions(path: "/api/test");

      // Mock connectivity to return mobile
      when(() => mockConnectivityWrapper.checkConnectivity())
          .thenAnswer((_) async => [ConnectivityResult.mobile]);

      // Act
      await connectionInterceptor.onRequest(options, mockRequestHandler);

      // Assert
      verify(() => mockRequestHandler.next(options)).called(1);
      verifyNever(() => mockRequestHandler.reject(any()));
    });

    test("should allow request when wifi connectivity is available", () async {
      // Arrange
      when(() => mockRequestHandler.next(any())).thenAnswer((_) async {});

      final options = RequestOptions(path: "/api/test");

      // Mock connectivity to return wifi
      when(() => mockConnectivityWrapper.checkConnectivity())
          .thenAnswer((_) async => [ConnectivityResult.wifi]);

      // Act
      await connectionInterceptor.onRequest(options, mockRequestHandler);

      // Assert
      verify(() => mockRequestHandler.next(options)).called(1);
      verifyNever(() => mockRequestHandler.reject(any()));
    });

    test(
        "should allow request "
        "when both mobile "
        "and wifi connectivity are available", () async {
      // Arrange
      when(() => mockRequestHandler.next(any())).thenAnswer((_) async {});

      final options = RequestOptions(path: "/api/test");

      // Mock connectivity to return both mobile and wifi
      when(() => mockConnectivityWrapper.checkConnectivity()).thenAnswer(
        (_) async => [ConnectivityResult.mobile, ConnectivityResult.wifi],
      );

      // Act
      await connectionInterceptor.onRequest(options, mockRequestHandler);

      // Assert
      verify(() => mockRequestHandler.next(options)).called(1);
      verifyNever(() => mockRequestHandler.reject(any()));
    });

    test("should reject request when no internet connectivity is available",
        () async {
      // Arrange
      when(() => mockRequestHandler.reject(any())).thenAnswer((_) async {});

      final options = RequestOptions(path: "/api/test");

      // Mock connectivity to return no connectivity
      when(() => mockConnectivityWrapper.checkConnectivity())
          .thenAnswer((_) async => [ConnectivityResult.none]);

      // Act
      await connectionInterceptor.onRequest(options, mockRequestHandler);

      // Assert
      verify(() => mockRequestHandler.reject(any())).called(1);
      verifyNever(() => mockRequestHandler.next(any()));
    });

    test("should reject request when only bluetooth connectivity is available",
        () async {
      // Arrange
      when(() => mockRequestHandler.reject(any())).thenAnswer((_) async {});

      final options = RequestOptions(path: "/api/test");

      // Mock connectivity to return only bluetooth
      when(() => mockConnectivityWrapper.checkConnectivity())
          .thenAnswer((_) async => [ConnectivityResult.bluetooth]);

      // Act
      await connectionInterceptor.onRequest(options, mockRequestHandler);

      // Assert
      verify(() => mockRequestHandler.reject(any())).called(1);
      verifyNever(() => mockRequestHandler.next(any()));
    });

    test("should reject request when only ethernet connectivity is available",
        () async {
      // Arrange
      when(() => mockRequestHandler.reject(any())).thenAnswer((_) async {});

      final options = RequestOptions(path: "/api/test");

      // Mock connectivity to return only ethernet
      when(() => mockConnectivityWrapper.checkConnectivity())
          .thenAnswer((_) async => [ConnectivityResult.ethernet]);

      // Act
      await connectionInterceptor.onRequest(options, mockRequestHandler);

      // Assert
      verify(() => mockRequestHandler.reject(any())).called(1);
      verifyNever(() => mockRequestHandler.next(any()));
    });

    test("should reject request when only vpn connectivity is available",
        () async {
      // Arrange
      when(() => mockRequestHandler.reject(any())).thenAnswer((_) async {});

      final options = RequestOptions(path: "/api/test");

      // Mock connectivity to return only vpn
      when(() => mockConnectivityWrapper.checkConnectivity())
          .thenAnswer((_) async => [ConnectivityResult.vpn]);

      // Act
      await connectionInterceptor.onRequest(options, mockRequestHandler);

      // Assert
      verify(() => mockRequestHandler.reject(any())).called(1);
      verifyNever(() => mockRequestHandler.next(any()));
    });

    test("should reject request when only other connectivity is available",
        () async {
      // Arrange
      when(() => mockRequestHandler.reject(any())).thenAnswer((_) async {});

      final options = RequestOptions(path: "/api/test");

      // Mock connectivity to return only other
      when(() => mockConnectivityWrapper.checkConnectivity())
          .thenAnswer((_) async => [ConnectivityResult.other]);

      // Act
      await connectionInterceptor.onRequest(options, mockRequestHandler);

      // Assert
      verify(() => mockRequestHandler.reject(any())).called(1);
      verifyNever(() => mockRequestHandler.next(any()));
    });

    test(
        "should reject request when mixed "
        "non-internet connectivity is available", () async {
      // Arrange
      when(() => mockRequestHandler.reject(any())).thenAnswer((_) async {});

      final options = RequestOptions(path: "/api/test");

      // Mock connectivity to return bluetooth and ethernet (no internet)
      when(() => mockConnectivityWrapper.checkConnectivity()).thenAnswer(
        (_) async =>
            [ConnectivityResult.bluetooth, ConnectivityResult.ethernet],
      );

      // Act
      await connectionInterceptor.onRequest(options, mockRequestHandler);

      // Assert
      verify(() => mockRequestHandler.reject(any())).called(1);
      verifyNever(() => mockRequestHandler.next(any()));
    });

    test(
        "should allow request when mobile and "
        "bluetooth connectivity are available", () async {
      // Arrange
      when(() => mockRequestHandler.next(any())).thenAnswer((_) async {});

      final options = RequestOptions(path: "/api/test");

      // Mock connectivity to return mobile and bluetooth
      when(() => mockConnectivityWrapper.checkConnectivity()).thenAnswer(
        (_) async => [ConnectivityResult.mobile, ConnectivityResult.bluetooth],
      );

      // Act
      await connectionInterceptor.onRequest(options, mockRequestHandler);

      // Assert
      verify(() => mockRequestHandler.next(options)).called(1);
      verifyNever(() => mockRequestHandler.reject(any()));
    });

    test(
        "should allow request when wifi and "
        "ethernet connectivity are available", () async {
      // Arrange
      when(() => mockRequestHandler.next(any())).thenAnswer((_) async {});

      final options = RequestOptions(path: "/api/test");

      // Mock connectivity to return wifi and ethernet
      when(() => mockConnectivityWrapper.checkConnectivity()).thenAnswer(
        (_) async => [ConnectivityResult.wifi, ConnectivityResult.ethernet],
      );

      // Act
      await connectionInterceptor.onRequest(options, mockRequestHandler);

      // Assert
      verify(() => mockRequestHandler.next(options)).called(1);
      verifyNever(() => mockRequestHandler.reject(any()));
    });

    test("should handle empty connectivity result list", () async {
      // Arrange
      when(() => mockRequestHandler.reject(any())).thenAnswer((_) async {});

      final options = RequestOptions(path: "/api/test");

      // Mock connectivity to return empty list
      when(() => mockConnectivityWrapper.checkConnectivity())
          .thenAnswer((_) async => <ConnectivityResult>[]);

      // Act
      await connectionInterceptor.onRequest(options, mockRequestHandler);

      // Assert
      verify(() => mockRequestHandler.reject(any())).called(1);
      verifyNever(() => mockRequestHandler.next(any()));
    });

    test("should handle connectivity check failure gracefully", () async {
      // Arrange
      when(() => mockRequestHandler.reject(any())).thenAnswer((_) async {});

      final options = RequestOptions(path: "/api/test");

      // Mock connectivity to throw an exception
      when(() => mockConnectivityWrapper.checkConnectivity())
          .thenThrow(Exception("Connectivity check failed"));

      // Act & Assert
      expect(
        () => connectionInterceptor.onRequest(options, mockRequestHandler),
        throwsA(isA<Exception>()),
      );
    });
  });

  group("DefaultConnectivityWrapper", () {
    test("should check connectivity using real Connectivity instance",
        () async {
      // Arrange
      final mockConnectivity = MockConnectivity();
      final wrapper =
          DefaultConnectivityWrapper(connectivity: mockConnectivity);

      when(mockConnectivity.checkConnectivity)
          .thenAnswer((_) async => [ConnectivityResult.wifi]);

      // Act
      final result = await wrapper.checkConnectivity();

      // Assert
      expect(result, equals([ConnectivityResult.wifi]));
      verify(mockConnectivity.checkConnectivity).called(1);
    });

    test("should create default Connectivity instance when none provided",
        () async {
      // Arrange & Act
      final wrapper = DefaultConnectivityWrapper();

      // Assert
      expect(wrapper, isA<DefaultConnectivityWrapper>());
      expect(wrapper, isA<ConnectivityWrapper>());
    });
  });

  group("ConnectionInterceptor - Integration Tests", () {
    test("should handle different request paths with internet connectivity",
        () async {
      // Arrange
      when(() => mockRequestHandler.next(any())).thenAnswer((_) async {});

      final testPaths = [
        "/api/users",
        "/api/products",
        "/api/orders",
        "/api/auth/login",
        "/api/auth/logout",
        "/api/dashboard",
        "/api/profile",
      ];

      // Mock connectivity to return wifi
      when(() => mockConnectivityWrapper.checkConnectivity())
          .thenAnswer((_) async => [ConnectivityResult.wifi]);

      for (final path in testPaths) {
        final options = RequestOptions(path: path);

        // Act
        await connectionInterceptor.onRequest(options, mockRequestHandler);

        // Assert
        verify(() => mockRequestHandler.next(options)).called(1);
      }
    });

    test("should handle different request paths with no internet connectivity",
        () async {
      // Arrange
      when(() => mockRequestHandler.reject(any())).thenAnswer((_) async {});

      final testPaths = [
        "/api/users",
        "/api/products",
        "/api/orders",
        "/api/auth/login",
        "/api/auth/logout",
        "/api/dashboard",
        "/api/profile",
      ];

      // Mock connectivity to return no connectivity
      when(() => mockConnectivityWrapper.checkConnectivity())
          .thenAnswer((_) async => [ConnectivityResult.none]);

      for (final path in testPaths) {
        final options = RequestOptions(path: path);

        // Act
        await connectionInterceptor.onRequest(options, mockRequestHandler);

        // Assert
        verify(() => mockRequestHandler.reject(any())).called(1);
      }
    });

    test("should verify rejected request contains proper error response",
        () async {
      // Arrange
      DioException? capturedException;
      when(() => mockRequestHandler.reject(any()))
          .thenAnswer((invocation) async {
        capturedException = invocation.positionalArguments[0] as DioException;
      });

      final options = RequestOptions(path: "/api/test");

      // Mock connectivity to return no connectivity
      when(() => mockConnectivityWrapper.checkConnectivity())
          .thenAnswer((_) async => [ConnectivityResult.none]);

      // Act
      await connectionInterceptor.onRequest(options, mockRequestHandler);

      // Assert
      expect(capturedException, isNotNull);
      expect(capturedException!.requestOptions, equals(options));
      expect(capturedException!.response, isNotNull);
      expect(capturedException!.response!.data, isA<Map<String, dynamic>>());
      expect(capturedException!.response!.data["message"], isA<String>());
    });

    test("should handle all connectivity result combinations", () async {
      // Arrange
      when(() => mockRequestHandler.next(any())).thenAnswer((_) async {});
      when(() => mockRequestHandler.reject(any())).thenAnswer((_) async {});

      final options = RequestOptions(path: "/api/test");

      // Test all possible connectivity result combinations
      final testCases = [
        // Should allow (has internet)
        ([ConnectivityResult.mobile], true),
        ([ConnectivityResult.wifi], true),
        ([ConnectivityResult.mobile, ConnectivityResult.wifi], true),
        ([ConnectivityResult.mobile, ConnectivityResult.bluetooth], true),
        ([ConnectivityResult.wifi, ConnectivityResult.ethernet], true),
        ([ConnectivityResult.mobile, ConnectivityResult.vpn], true),
        ([ConnectivityResult.wifi, ConnectivityResult.other], true),

        // Should reject (no internet)
        ([ConnectivityResult.none], false),
        ([ConnectivityResult.bluetooth], false),
        ([ConnectivityResult.ethernet], false),
        ([ConnectivityResult.vpn], false),
        ([ConnectivityResult.other], false),
        ([ConnectivityResult.bluetooth, ConnectivityResult.ethernet], false),
        ([ConnectivityResult.vpn, ConnectivityResult.other], false),
        (<ConnectivityResult>[], false),
      ];

      for (final (connectivityResults, shouldAllow) in testCases) {
        // Reset mocks
        reset(mockRequestHandler);
        when(() => mockRequestHandler.next(any())).thenAnswer((_) async {});
        when(() => mockRequestHandler.reject(any())).thenAnswer((_) async {});

        // Mock connectivity
        when(() => mockConnectivityWrapper.checkConnectivity())
            .thenAnswer((_) async => connectivityResults);

        // Act
        await connectionInterceptor.onRequest(options, mockRequestHandler);

        // Assert
        if (shouldAllow) {
          verify(() => mockRequestHandler.next(options)).called(1);
          verifyNever(() => mockRequestHandler.reject(any()));
        } else {
          verify(() => mockRequestHandler.reject(any())).called(1);
          verifyNever(() => mockRequestHandler.next(any()));
        }
      }
    });
  });
}
