import "dart:convert";

import "package:dio/dio.dart";
import "package:flutter_test/flutter_test.dart";
import "package:mocktail/mocktail.dart";
import "package:wcas_frontend/core/services/api_service/request_logging_interceptor.dart";

class MockRequestInterceptorHandler extends Mock
    implements RequestInterceptorHandler {}

class MockResponseInterceptorHandler extends Mock
    implements ResponseInterceptorHandler {}

class MockErrorInterceptorHandler extends Mock
    implements ErrorInterceptorHandler {}

void main() {
  late RequestLoggingInterceptor interceptor;
  late MockRequestInterceptorHandler mockRequestHandler;
  late MockResponseInterceptorHandler mockResponseHandler;
  late MockErrorInterceptorHandler mockErrorHandler;

  setUpAll(() {
    registerFallbackValue(RequestOptions());
    registerFallbackValue(Response<dynamic>(requestOptions: RequestOptions()));
    registerFallbackValue(
      DioException(
        requestOptions: RequestOptions(),
        type: DioExceptionType.badResponse,
      ),
    );
  });

  setUp(() {
    interceptor = RequestLoggingInterceptor();
    mockRequestHandler = MockRequestInterceptorHandler();
    mockResponseHandler = MockResponseInterceptorHandler();
    mockErrorHandler = MockErrorInterceptorHandler();
  });

  group("formatLoggedBody", () {
    test("returns null for null", () {
      expect(RequestLoggingInterceptor.formatLoggedBody(null), isNull);
    });

    test("re-encodes a Map as indented JSON", () {
      final result = RequestLoggingInterceptor.formatLoggedBody(
        {"name": "John", "age": 30},
      );

      expect(result, contains("\n"));
      expect(jsonDecode(result!), {"name": "John", "age": 30});
    });

    test("re-encodes a List as indented JSON", () {
      final result = RequestLoggingInterceptor.formatLoggedBody([1, 2, 3]);

      expect(jsonDecode(result!), [1, 2, 3]);
    });

    test("re-indents a String that is itself JSON text", () {
      final result = RequestLoggingInterceptor.formatLoggedBody('{"a":1}');

      expect(result, contains("\n"));
      expect(jsonDecode(result!), {"a": 1});
    });

    test("returns a non-JSON String as-is", () {
      final result =
          RequestLoggingInterceptor.formatLoggedBody("Connection timeout");

      expect(result, "Connection timeout");
    });

    test("falls back to toString() for values that can't be JSON-encoded", () {
      final dateTime = DateTime(2024);

      final result = RequestLoggingInterceptor.formatLoggedBody({
        "when": dateTime,
      });

      expect(result, contains(dateTime.toString()));
    });
  });

  group("shouldLogBody", () {
    test("returns true for a normal JSON request", () {
      final options = RequestOptions(path: "/test");

      expect(RequestLoggingInterceptor.shouldLogBody(options), isTrue);
    });

    test("returns false for a bytes response type (file download)", () {
      final options = RequestOptions(
        path: "/download",
        responseType: ResponseType.bytes,
      );

      expect(RequestLoggingInterceptor.shouldLogBody(options), isFalse);
    });

    test("returns false for a FormData body (file upload)", () {
      final options = RequestOptions(path: "/upload", data: FormData());

      expect(RequestLoggingInterceptor.shouldLogBody(options), isFalse);
    });
  });

  group("elapsedMs", () {
    test("returns -1 when no start time was stashed", () {
      final options = RequestOptions(path: "/test");

      expect(RequestLoggingInterceptor.elapsedMs(options), -1);
    });

    test("computes elapsed time from a stashed start time", () {
      final startTime = DateTime.now().millisecondsSinceEpoch - 50;
      final options = RequestOptions(
        path: "/test",
        extra: {RequestLoggingInterceptor.requestStartTimeKey: startTime},
      );

      expect(
        RequestLoggingInterceptor.elapsedMs(options),
        greaterThanOrEqualTo(50),
      );
    });
  });

  group("onRequest", () {
    test("always calls handler.next()", () {
      when(() => mockRequestHandler.next(any())).thenReturn(null);
      final options = RequestOptions(
        path: "/test",
        method: "POST",
        data: {"a": 1},
      );

      interceptor.onRequest(options, mockRequestHandler);

      verify(() => mockRequestHandler.next(options)).called(1);
    });

    test("still calls handler.next() for a file upload (FormData)", () {
      when(() => mockRequestHandler.next(any())).thenReturn(null);
      final options = RequestOptions(path: "/upload", data: FormData());

      interceptor.onRequest(options, mockRequestHandler);

      verify(() => mockRequestHandler.next(options)).called(1);
    });
  });

  group("onResponse", () {
    test("always calls handler.next()", () {
      when(() => mockResponseHandler.next(any())).thenReturn(null);
      final requestOptions = RequestOptions(path: "/test");
      final response = Response<dynamic>(
        requestOptions: requestOptions,
        statusCode: 200,
        data: {"result": "ok"},
      );

      interceptor.onResponse(response, mockResponseHandler);

      verify(() => mockResponseHandler.next(response)).called(1);
    });

    test("still calls handler.next() for a bytes response (file download)", () {
      when(() => mockResponseHandler.next(any())).thenReturn(null);
      final requestOptions = RequestOptions(
        path: "/download",
        responseType: ResponseType.bytes,
      );
      final response = Response<dynamic>(
        requestOptions: requestOptions,
        statusCode: 200,
        data: [1, 2, 3],
      );

      interceptor.onResponse(response, mockResponseHandler);

      verify(() => mockResponseHandler.next(response)).called(1);
    });
  });

  group("onError", () {
    test("always calls handler.next()", () {
      when(() => mockErrorHandler.next(any())).thenReturn(null);
      final requestOptions = RequestOptions(path: "/test");
      final error = DioException(
        requestOptions: requestOptions,
        type: DioExceptionType.badResponse,
        response: Response<dynamic>(
          requestOptions: requestOptions,
          statusCode: 500,
          data: {"error": "boom"},
        ),
      );

      interceptor.onError(error, mockErrorHandler);

      verify(() => mockErrorHandler.next(error)).called(1);
    });
  });
}
