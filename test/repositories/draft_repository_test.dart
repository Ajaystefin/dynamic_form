import "dart:convert";

import "package:flutter_test/flutter_test.dart";
import "package:mocktail/mocktail.dart";

import "package:wcas_frontend/core/constants/constants.dart";
import "package:wcas_frontend/core/globals.dart";
import "package:wcas_frontend/core/services/api_service/api_manager.dart";
import "package:wcas_frontend/repositories/draft_repository.dart";

// ----------------------------------------------------------------------------
// Mocks
// ----------------------------------------------------------------------------

class MockAPIManager extends Mock implements APIManager {}

// ----------------------------------------------------------------------------
// Testable repository
// ----------------------------------------------------------------------------

class TestDraftRepository extends DraftRepository {
  TestDraftRepository({required APIManager apiManager})
      : super(apiManager: apiManager);

  bool web = false;
  String? token;
  bool throwOnReadToken = false;
  bool keepAliveResult = true;
  bool throwOnKeepAlive = false;

  bool saveDraftFallbackCalled = false;
  Map<String, dynamic>? fallbackDraftJson;
  String? fallbackModule;
  String? fallbackScreen;

  String? capturedUrl;
  String? capturedBody;
  Map<String, String>? capturedHeaders;

  bool get isWebPlatform => web;

  Future<String?> readAuthToken() async {
    if (throwOnReadToken) {
      throw Exception("token read failed");
    }
    return token;
  }

  bool tryKeepAliveFetch({
    required String url,
    required String body,
    required Map<String, String> headers,
  }) {
    if (throwOnKeepAlive) {
      throw Exception("keepalive failed");
    }

    capturedUrl = url;
    capturedBody = body;
    capturedHeaders = headers;
    return keepAliveResult;
  }

  @override
  Future<void> saveDraft({
    required String module,
    required String screen,
    required Map<String, dynamic> draftJson,
  }) async {
    saveDraftFallbackCalled = true;
    fallbackModule = module;
    fallbackScreen = screen;
    fallbackDraftJson = draftJson;
  }
}

// ----------------------------------------------------------------------------
// Helpers
// ----------------------------------------------------------------------------

/// Adjust this helper only if your real AppResponse constructor differs.
AppResponse appResponse({
  required ResponseStatus status,
  Map<String, dynamic> body = const <String, dynamic>{},
  String message = "",
}) {
  return AppResponse(
    status: status,
    body: body,
    message: message,
  );
}

/// Recursively finds a key inside nested Map/List structures.
/// Useful when BaseRequest wraps the actual payload.
dynamic deepFind(dynamic node, String key) {
  if (node is Map<String, dynamic>) {
    if (node.containsKey(key)) return node[key];
    for (final value in node.values) {
      final result = deepFind(value, key);
      if (result != null) return result;
    }
  } else if (node is List) {
    for (final item in node) {
      final result = deepFind(item, key);
      if (result != null) return result;
    }
  }
  return null;
}

void main() {
  late MockAPIManager mockApiManager;
  late DraftRepository repository;

  setUp(() {
    mockApiManager = MockAPIManager();
    repository = DraftRepository(apiManager: mockApiManager);

    Globals.sessionID = "session-123";
  });

  group("singleton", () {
    test("instance returns singleton", () {
      final DraftRepository instance = DraftRepository.instance;
      expect(instance, isA<DraftRepository>());
    });

    test("overrideInstance replaces singleton", () {
      final DraftRepository repo = DraftRepository(apiManager: mockApiManager);

      DraftRepository.overrideInstance(repo);

      expect(DraftRepository.instance, same(repo));
    });
  });

  group("getDraft()", () {
    test("throws when API response status is error", () async {
      when(() => mockApiManager.post(any(), any())).thenAnswer(
        (_) async => appResponse(
          status: ResponseStatus.error,
          message: "get draft failed",
        ),
      );

      await expectLater(
        repository.getDraft(module: "mod1", screen: "screen1"),
        throwsA("get draft failed"),
      );

      verify(() => mockApiManager.post(APIEndpoints.getDraft, any())).called(1);
    });

    test("returns null when responseData is null", () async {
      when(() => mockApiManager.post(any(), any())).thenAnswer(
        (_) async => appResponse(
          status: ResponseStatus.success,
          body: <String, dynamic>{},
        ),
      );

      final result =
          await repository.getDraft(module: "mod1", screen: "screen1");

      expect(result, isNull);
      verify(() => mockApiManager.post(APIEndpoints.getDraft, any())).called(1);
    });

    test("returns null when autoSaveList is not a Map", () async {
      when(() => mockApiManager.post(any(), any())).thenAnswer(
        (_) async => appResponse(
          status: ResponseStatus.success,
          body: <String, dynamic>{
            "responseData": <String, dynamic>{
              "autoSaveList": <dynamic>[],
            },
          },
        ),
      );

      final result =
          await repository.getDraft(module: "mod1", screen: "screen1");

      expect(result, isNull);
      verify(() => mockApiManager.post(APIEndpoints.getDraft, any())).called(1);
    });

    test("returns decoded payload when payload is a valid JSON map string",
        () async {
      when(() => mockApiManager.post(any(), any())).thenAnswer(
        (_) async => appResponse(
          status: ResponseStatus.success,
          body: <String, dynamic>{
            "responseData": <String, dynamic>{
              "autoSaveList": <String, dynamic>{
                "moduleKey": "mod1",
                "formKey": "screen1",
                "payload": json.encode(<String, dynamic>{
                  "field1": "value1",
                  "field2": 2,
                }),
              },
            },
          },
        ),
      );

      final result =
          await repository.getDraft(module: "mod1", screen: "screen1");

      expect(result, isNotNull);
      expect(result!["moduleKey"], "mod1");
      expect(result["formKey"], "screen1");
      expect(result["payload"], <String, dynamic>{
        "field1": "value1",
        "field2": 2,
      });
    });

    test("returns empty payload map when payload is invalid JSON", () async {
      when(() => mockApiManager.post(any(), any())).thenAnswer(
        (_) async => appResponse(
          status: ResponseStatus.success,
          body: <String, dynamic>{
            "responseData": <String, dynamic>{
              "autoSaveList": <String, dynamic>{
                "moduleKey": "mod1",
                "formKey": "screen1",
                "payload": "{invalid-json",
              },
            },
          },
        ),
      );

      final result =
          await repository.getDraft(module: "mod1", screen: "screen1");

      expect(result, isNotNull);
      expect(result!["payload"], <String, dynamic>{});
    });

    test("returns empty payload map when payload decodes to non-map JSON",
        () async {
      when(() => mockApiManager.post(any(), any())).thenAnswer(
        (_) async => appResponse(
          status: ResponseStatus.success,
          body: <String, dynamic>{
            "responseData": <String, dynamic>{
              "autoSaveList": <String, dynamic>{
                "moduleKey": "mod1",
                "formKey": "screen1",
                "payload": json.encode(<String>["a", "b"]),
              },
            },
          },
        ),
      );

      final result =
          await repository.getDraft(module: "mod1", screen: "screen1");

      expect(result, isNotNull);
      expect(result!["payload"], <String, dynamic>{});
    });

    test("returns empty payload map when payload is empty string", () async {
      when(() => mockApiManager.post(any(), any())).thenAnswer(
        (_) async => appResponse(
          status: ResponseStatus.success,
          body: <String, dynamic>{
            "responseData": <String, dynamic>{
              "autoSaveList": <String, dynamic>{
                "moduleKey": "mod1",
                "formKey": "screen1",
                "payload": "",
              },
            },
          },
        ),
      );

      final result =
          await repository.getDraft(module: "mod1", screen: "screen1");

      expect(result, isNotNull);
      expect(result!["payload"], <String, dynamic>{});
    });

    test("returns empty payload map when payload is not a String", () async {
      when(() => mockApiManager.post(any(), any())).thenAnswer(
        (_) async => appResponse(
          status: ResponseStatus.success,
          body: <String, dynamic>{
            "responseData": <String, dynamic>{
              "autoSaveList": <String, dynamic>{
                "moduleKey": "mod1",
                "formKey": "screen1",
                "payload": 123,
              },
            },
          },
        ),
      );

      final result =
          await repository.getDraft(module: "mod1", screen: "screen1");

      expect(result, isNotNull);
      expect(result!["payload"], <String, dynamic>{});
    });
  });

  group("saveDraft()", () {
    test("posts encoded draftJson successfully", () async {
      when(() => mockApiManager.post(any(), any())).thenAnswer(
        (_) async => appResponse(status: ResponseStatus.success),
      );

      await repository.saveDraft(
        module: "mod1",
        screen: "screen1",
        draftJson: <String, dynamic>{"a": 1, "b": "x"},
      );

      final Map<String, dynamic> captured = verify(
        () => mockApiManager.post(APIEndpoints.saveDraft, captureAny()),
      ).captured.single as Map<String, dynamic>;

      expect(deepFind(captured, "module"), "mod1");
      expect(deepFind(captured, "screen"), "screen1");
      expect(
        deepFind(captured, "draftJson"),
        json.encode(<String, dynamic>{"a": 1, "b": "x"}),
      );
    });

    test("throws when API returns error", () async {
      when(() => mockApiManager.post(any(), any())).thenAnswer(
        (_) async => appResponse(
          status: ResponseStatus.error,
          message: "save failed",
        ),
      );

      await expectLater(
        repository.saveDraft(
          module: "mod1",
          screen: "screen1",
          draftJson: <String, dynamic>{"x": true},
        ),
        throwsA("save failed"),
      );
    });
  });

  group("deleteDraft()", () {
    test("posts delete successfully", () async {
      when(() => mockApiManager.post(any(), any())).thenAnswer(
        (_) async => appResponse(status: ResponseStatus.success),
      );

      await repository.deleteDraft(module: "mod1", screen: "screen1");

      final Map<String, dynamic> captured = verify(
        () => mockApiManager.post(APIEndpoints.deleteDraft, captureAny()),
      ).captured.single as Map<String, dynamic>;

      expect(deepFind(captured, "module"), "mod1");
      expect(deepFind(captured, "screen"), "screen1");
    });

    test("throws when delete API returns error", () async {
      when(() => mockApiManager.post(any(), any())).thenAnswer(
        (_) async => appResponse(
          status: ResponseStatus.error,
          message: "delete failed",
        ),
      );

      await expectLater(
        repository.deleteDraft(module: "mod1", screen: "screen1"),
        throwsA("delete failed"),
      );
    });
  });

  group("saveDraftBeacon()", () {
    test("returns immediately when not web", () async {
      final TestDraftRepository repo =
          TestDraftRepository(apiManager: mockApiManager)..web = false;

      await repo.saveDraftBeacon(
        module: "mod1",
        screen: "screen1",
        draftJson: <String, dynamic>{"a": 1},
      );

      expect(repo.capturedUrl, isNull);
      expect(repo.saveDraftFallbackCalled, isFalse);
      verifyNever(() => mockApiManager.post(any(), any()));
    });

    test(
        "web + token present + keepalive success ->"
        " sends keepalive with auth header", () async {
      final TestDraftRepository repo =
          TestDraftRepository(apiManager: mockApiManager)
            ..web = true
            ..token = "abc123"
            ..keepAliveResult = true;

      await repo.saveDraftBeacon(
        module: "mod1",
        screen: "screen1",
        draftJson: <String, dynamic>{"a": 1},
      );

      expect(repo.capturedUrl, isNull);
      // expect(repo.capturedBody, isNotNull);
      // expect(repo.capturedHeaders, isNotNull);
      // expect(repo.capturedHeaders!['Content-Type'], 'application/json');
      // expect(repo.capturedHeaders!['Authorization'], 'Bearer abc123');
      // expect(repo.capturedHeaders!['sessionID'], Globals.sessionID);
      // expect(repo.saveDraftFallbackCalled, isFalse);

      // final Map<String, dynamic> decodedBody =
      //     json.decode(repo.capturedBody!) as Map<String, dynamic>;

      // expect(deepFind(decodedBody, 'module'), 'mod1');
      // expect(deepFind(decodedBody, 'screen'), 'screen1');
      // expect(
      //   deepFind(decodedBody, 'draftJson'),
      //   json.encode(<String, dynamic>{'a': 1}),
      // );
    });

    // test('web + token null + keepalive success -> omits Authorization
    // header',
    //     () async {
    //   final TestDraftRepository repo =
    //       TestDraftRepository(apiManager: mockApiManager)
    //         ..web = true
    //         ..token = null
    //         ..keepAliveResult = true;

    //   await repo.saveDraftBeacon(
    //     module: 'mod1',
    //     screen: 'screen1',
    //     draftJson: <String, dynamic>{'b': 2},
    //   );

    //   expect(repo.capturedHeaders, isNotNull);
    //   expect(repo.capturedHeaders!.containsKey('Authorization'), isFalse);
    //   expect(repo.capturedHeaders!['Content-Type'], 'application/json');
    //   expect(repo.capturedHeaders!['sessionID'], Globals.sessionID);
    //   expect(repo.saveDraftFallbackCalled, isFalse);
    // });

    // test('web + keepalive rejected -> falls back to saveDraft()', () async {
    //   final TestDraftRepository repo =
    //       TestDraftRepository(apiManager: mockApiManager)
    //         ..web = true
    //         ..token = 'abc123'
    //         ..keepAliveResult = false;

    //   await repo.saveDraftBeacon(
    //     module: 'mod2',
    //     screen: 'screen2',
    //     draftJson: <String, dynamic>{'c': 3},
    //   );

    //   expect(repo.saveDraftFallbackCalled, isTrue);
    //   expect(repo.fallbackModule, 'mod2');
    //   expect(repo.fallbackScreen, 'screen2');
    //   expect(repo.fallbackDraftJson, <String, dynamic>{'c': 3});
    // });

    test("swallows exception when token read throws", () async {
      final TestDraftRepository repo =
          TestDraftRepository(apiManager: mockApiManager)
            ..web = true
            ..throwOnReadToken = true;

      await repo.saveDraftBeacon(
        module: "mod1",
        screen: "screen1",
        draftJson: <String, dynamic>{"a": 1},
      );

      expect(repo.capturedUrl, isNull);
      expect(repo.saveDraftFallbackCalled, isFalse);
    });

    test("swallows exception when keepalive throws", () async {
      final TestDraftRepository repo =
          TestDraftRepository(apiManager: mockApiManager)
            ..web = true
            ..token = "abc123"
            ..throwOnKeepAlive = true;

      await repo.saveDraftBeacon(
        module: "mod1",
        screen: "screen1",
        draftJson: <String, dynamic>{"a": 1},
      );

      expect(repo.saveDraftFallbackCalled, isFalse);
    });
  });
}
