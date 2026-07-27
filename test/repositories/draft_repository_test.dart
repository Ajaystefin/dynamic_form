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
// Test repository
// ----------------------------------------------------------------------------

class TestDraftRepository extends DraftRepository {
  TestDraftRepository({required APIManager apiManager})
      : super(apiManager: apiManager);

  bool saveDraftFallbackCalled = false;
  String? fallbackModule;
  String? fallbackScreen;
  Map<String, dynamic>? fallbackDraftJson;

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
/// This is useful because BaseRequest may wrap the actual request payload.
dynamic deepFind(Object? node, String key) {
  if (node is Map) {
    if (node.containsKey(key)) {
      return node[key];
    }

    for (final Object? value in node.values) {
      final dynamic result = deepFind(value, key);
      if (result != null) {
        return result;
      }
    }
  } else if (node is List) {
    for (final Object? item in node) {
      final dynamic result = deepFind(item, key);
      if (result != null) {
        return result;
      }
    }
  }

  return null;
}

Matcher throwsWithMessage(String message) {
  return throwsA(
    predicate<Object>(
      (Object error) => error.toString().contains(message),
      'throws error containing "$message"',
    ),
  );
}

void main() {
  late MockAPIManager mockApiManager;
  late DraftRepository repository;

  setUp(() {
    mockApiManager = MockAPIManager();
    repository = DraftRepository(apiManager: mockApiManager);

    Globals.sessionID = "session-123";
  });

  tearDown(() {
    DraftRepository.overrideInstance = DraftRepository(apiManager: mockApiManager);
  });

  group("singleton", () {
    test("instance returns DraftRepository singleton", () {
      final DraftRepository instance = DraftRepository.instance;

      expect(instance, isA<DraftRepository>());
    });

    test("overrideInstance replaces singleton", () {
      final DraftRepository repo = DraftRepository(apiManager: mockApiManager);

      DraftRepository.overrideInstance = repo;

      expect(DraftRepository.instance, same(repo));
    });
  });

  group("getDraft()", () {
    test("posts getDraft request with module and screen", () async {
      when(() => mockApiManager.post(any(), any())).thenAnswer(
        (_) async => appResponse(
          status: ResponseStatus.success,
          body: <String, dynamic>{},
        ),
      );

      await repository.getDraft(module: "mod1", screen: "screen1");

      final Map<String, dynamic> captured = verify(
        () => mockApiManager.post(APIEndpoints.getDraft, captureAny()),
      ).captured.single as Map<String, dynamic>;

      expect(deepFind(captured, "module"), "mod1");
      expect(deepFind(captured, "screen"), "screen1");
    });

    test("throws when API response status is error", () async {
      when(() => mockApiManager.post(any(), any())).thenAnswer(
        (_) async => appResponse(
          status: ResponseStatus.error,
          message: "get draft failed",
        ),
      );

      await expectLater(
        repository.getDraft(module: "mod1", screen: "screen1"),
        throwsWithMessage("get draft failed"),
      );

      verify(() => mockApiManager.post(APIEndpoints.getDraft, any())).called(1);
    });

    test("returns null when response body is empty", () async {
      when(() => mockApiManager.post(any(), any())).thenAnswer(
        (_) async => appResponse(
          status: ResponseStatus.success,
          body: <String, dynamic>{},
        ),
      );

      final Map<String, dynamic>? result =
          await repository.getDraft(module: "mod1", screen: "screen1");

      expect(result, isNull);
      verify(() => mockApiManager.post(APIEndpoints.getDraft, any())).called(1);
    });

    test("returns null when responseData exists but autoSaveList is missing",
        () async {
      when(() => mockApiManager.post(any(), any())).thenAnswer(
        (_) async => appResponse(
          status: ResponseStatus.success,
          body: <String, dynamic>{
            "responseData": <String, dynamic>{},
          },
        ),
      );

      final Map<String, dynamic>? result =
          await repository.getDraft(module: "mod1", screen: "screen1");

      expect(result, isNull);
      verify(() => mockApiManager.post(APIEndpoints.getDraft, any())).called(1);
    });

    test("returns null when autoSaveList is null", () async {
      when(() => mockApiManager.post(any(), any())).thenAnswer(
        (_) async => appResponse(
          status: ResponseStatus.success,
          body: <String, dynamic>{
            "responseData": <String, dynamic>{
              "autoSaveList": null,
            },
          },
        ),
      );

      final Map<String, dynamic>? result =
          await repository.getDraft(module: "mod1", screen: "screen1");

      expect(result, isNull);
      verify(() => mockApiManager.post(APIEndpoints.getDraft, any())).called(1);
    });

    test("returns null when autoSaveList is List", () async {
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

      final Map<String, dynamic>? result =
          await repository.getDraft(module: "mod1", screen: "screen1");

      expect(result, isNull);
      verify(() => mockApiManager.post(APIEndpoints.getDraft, any())).called(1);
    });

    test("returns null when autoSaveList is String", () async {
      when(() => mockApiManager.post(any(), any())).thenAnswer(
        (_) async => appResponse(
          status: ResponseStatus.success,
          body: <String, dynamic>{
            "responseData": <String, dynamic>{
              "autoSaveList": "not-a-map",
            },
          },
        ),
      );

      final Map<String, dynamic>? result =
          await repository.getDraft(module: "mod1", screen: "screen1");

      expect(result, isNull);
      verify(() => mockApiManager.post(APIEndpoints.getDraft, any())).called(1);
    });

    test("returns decoded payload when payload is valid JSON map string",
        () async {
      final Map<String, dynamic> draftPayload = <String, dynamic>{
        "field1": "value1",
        "field2": 2,
        "nested": <String, dynamic>{
          "flag": true,
        },
      };

      when(() => mockApiManager.post(any(), any())).thenAnswer(
        (_) async => appResponse(
          status: ResponseStatus.success,
          body: <String, dynamic>{
            "responseData": <String, dynamic>{
              "autoSaveList": <String, dynamic>{
                "moduleKey": "mod1",
                "formKey": "screen1",
                "payload": json.encode(draftPayload),
              },
            },
          },
        ),
      );

      final Map<String, dynamic>? result =
          await repository.getDraft(module: "mod1", screen: "screen1");

      expect(result, isNotNull);
      expect(result!["moduleKey"], "mod1");
      expect(result["formKey"], "screen1");
      expect(result["payload"], draftPayload);

      verify(() => mockApiManager.post(APIEndpoints.getDraft, any())).called(1);
    });

    test("keeps all entry fields and replaces payload string with decoded map",
        () async {
      when(() => mockApiManager.post(any(), any())).thenAnswer(
        (_) async => appResponse(
          status: ResponseStatus.success,
          body: <String, dynamic>{
            "responseData": <String, dynamic>{
              "autoSaveList": <String, dynamic>{
                "id": 101,
                "moduleKey": "mod1",
                "formKey": "screen1",
                "createdBy": "tester",
                "updatedBy": "tester2",
                "payload": json.encode(<String, dynamic>{
                  "x": "y",
                }),
              },
            },
          },
        ),
      );

      final Map<String, dynamic>? result =
          await repository.getDraft(module: "mod1", screen: "screen1");

      expect(result, isNotNull);
      expect(result!["id"], 101);
      expect(result["moduleKey"], "mod1");
      expect(result["formKey"], "screen1");
      expect(result["createdBy"], "tester");
      expect(result["updatedBy"], "tester2");
      expect(result["payload"], <String, dynamic>{"x": "y"});

      verify(() => mockApiManager.post(APIEndpoints.getDraft, any())).called(1);
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

      final Map<String, dynamic>? result =
          await repository.getDraft(module: "mod1", screen: "screen1");

      expect(result, isNotNull);
      expect(result!["payload"], <String, dynamic>{});

      verify(() => mockApiManager.post(APIEndpoints.getDraft, any())).called(1);
    });

    test("returns empty payload map when payload decodes to List JSON",
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

      final Map<String, dynamic>? result =
          await repository.getDraft(module: "mod1", screen: "screen1");

      expect(result, isNotNull);
      expect(result!["payload"], <String, dynamic>{});

      verify(() => mockApiManager.post(APIEndpoints.getDraft, any())).called(1);
    });

    test("returns empty payload map when payload decodes to primitive JSON",
        () async {
      when(() => mockApiManager.post(any(), any())).thenAnswer(
        (_) async => appResponse(
          status: ResponseStatus.success,
          body: <String, dynamic>{
            "responseData": <String, dynamic>{
              "autoSaveList": <String, dynamic>{
                "moduleKey": "mod1",
                "formKey": "screen1",
                "payload": json.encode(10),
              },
            },
          },
        ),
      );

      final Map<String, dynamic>? result =
          await repository.getDraft(module: "mod1", screen: "screen1");

      expect(result, isNotNull);
      expect(result!["payload"], <String, dynamic>{});

      verify(() => mockApiManager.post(APIEndpoints.getDraft, any())).called(1);
    });

    test("returns empty payload map when payload decodes to bool JSON",
        () async {
      when(() => mockApiManager.post(any(), any())).thenAnswer(
        (_) async => appResponse(
          status: ResponseStatus.success,
          body: <String, dynamic>{
            "responseData": <String, dynamic>{
              "autoSaveList": <String, dynamic>{
                "moduleKey": "mod1",
                "formKey": "screen1",
                "payload": json.encode(true),
              },
            },
          },
        ),
      );

      final Map<String, dynamic>? result =
          await repository.getDraft(module: "mod1", screen: "screen1");

      expect(result, isNotNull);
      expect(result!["payload"], <String, dynamic>{});

      verify(() => mockApiManager.post(APIEndpoints.getDraft, any())).called(1);
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

      final Map<String, dynamic>? result =
          await repository.getDraft(module: "mod1", screen: "screen1");

      expect(result, isNotNull);
      expect(result!["payload"], <String, dynamic>{});

      verify(() => mockApiManager.post(APIEndpoints.getDraft, any())).called(1);
    });

    test("returns empty payload map when payload is whitespace string",
        () async {
      when(() => mockApiManager.post(any(), any())).thenAnswer(
        (_) async => appResponse(
          status: ResponseStatus.success,
          body: <String, dynamic>{
            "responseData": <String, dynamic>{
              "autoSaveList": <String, dynamic>{
                "moduleKey": "mod1",
                "formKey": "screen1",
                "payload": "   ",
              },
            },
          },
        ),
      );

      final Map<String, dynamic>? result =
          await repository.getDraft(module: "mod1", screen: "screen1");

      expect(result, isNotNull);
      expect(result!["payload"], <String, dynamic>{});

      verify(() => mockApiManager.post(APIEndpoints.getDraft, any())).called(1);
    });

    test("returns empty payload map when payload is not String", () async {
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

      final Map<String, dynamic>? result =
          await repository.getDraft(module: "mod1", screen: "screen1");

      expect(result, isNotNull);
      expect(result!["payload"], <String, dynamic>{});

      verify(() => mockApiManager.post(APIEndpoints.getDraft, any())).called(1);
    });

    test("returns empty payload map when payload key is missing", () async {
      when(() => mockApiManager.post(any(), any())).thenAnswer(
        (_) async => appResponse(
          status: ResponseStatus.success,
          body: <String, dynamic>{
            "responseData": <String, dynamic>{
              "autoSaveList": <String, dynamic>{
                "moduleKey": "mod1",
                "formKey": "screen1",
              },
            },
          },
        ),
      );

      final Map<String, dynamic>? result =
          await repository.getDraft(module: "mod1", screen: "screen1");

      expect(result, isNotNull);
      expect(result!["moduleKey"], "mod1");
      expect(result["formKey"], "screen1");
      expect(result["payload"], <String, dynamic>{});

      verify(() => mockApiManager.post(APIEndpoints.getDraft, any())).called(1);
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

    test("posts empty draftJson successfully", () async {
      when(() => mockApiManager.post(any(), any())).thenAnswer(
        (_) async => appResponse(status: ResponseStatus.success),
      );

      await repository.saveDraft(
        module: "mod-empty",
        screen: "screen-empty",
        draftJson: <String, dynamic>{},
      );

      final Map<String, dynamic> captured = verify(
        () => mockApiManager.post(APIEndpoints.saveDraft, captureAny()),
      ).captured.single as Map<String, dynamic>;

      expect(deepFind(captured, "module"), "mod-empty");
      expect(deepFind(captured, "screen"), "screen-empty");
      expect(deepFind(captured, "draftJson"), json.encode(<String, dynamic>{}));
    });

    test("posts nested draftJson as JSON string", () async {
      when(() => mockApiManager.post(any(), any())).thenAnswer(
        (_) async => appResponse(status: ResponseStatus.success),
      );

      final Map<String, dynamic> draftJson = <String, dynamic>{
        "name": "Azeem",
        "items": <Map<String, dynamic>>[
          <String, dynamic>{"id": 1, "selected": true},
          <String, dynamic>{"id": 2, "selected": false},
        ],
        "details": <String, dynamic>{
          "amount": 100,
          "active": true,
        },
      };

      await repository.saveDraft(
        module: "module-x",
        screen: "screen-x",
        draftJson: draftJson,
      );

      final Map<String, dynamic> captured = verify(
        () => mockApiManager.post(APIEndpoints.saveDraft, captureAny()),
      ).captured.single as Map<String, dynamic>;

      expect(deepFind(captured, "module"), "module-x");
      expect(deepFind(captured, "screen"), "screen-x");
      expect(deepFind(captured, "draftJson"), json.encode(draftJson));
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
        throwsWithMessage("save failed"),
      );

      verify(() => mockApiManager.post(APIEndpoints.saveDraft, any())).called(1);
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

    test("posts delete successfully with different values", () async {
      when(() => mockApiManager.post(any(), any())).thenAnswer(
        (_) async => appResponse(status: ResponseStatus.success),
      );

      await repository.deleteDraft(module: "module-delete", screen: "screen-delete");

      final Map<String, dynamic> captured = verify(
        () => mockApiManager.post(APIEndpoints.deleteDraft, captureAny()),
      ).captured.single as Map<String, dynamic>;

      expect(deepFind(captured, "module"), "module-delete");
      expect(deepFind(captured, "screen"), "screen-delete");
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
        throwsWithMessage("delete failed"),
      );

      verify(() => mockApiManager.post(APIEndpoints.deleteDraft, any()))
          .called(1);
    });
  });

  group("saveDraftBeacon()", () {
    test("returns immediately on non-web and does not call APIManager", () async {
      final TestDraftRepository repo =
          TestDraftRepository(apiManager: mockApiManager);

      await expectLater(
        repo.saveDraftBeacon(
          module: "mod1",
          screen: "screen1",
          draftJson: <String, dynamic>{"a": 1},
        ),
        completes,
      );

      expect(repo.saveDraftFallbackCalled, isFalse);
      expect(repo.fallbackModule, isNull);
      expect(repo.fallbackScreen, isNull);
      expect(repo.fallbackDraftJson, isNull);

      verifyNever(() => mockApiManager.post(any(), any()));
    });

    test("returns immediately on non-web for empty draftJson", () async {
      final TestDraftRepository repo =
          TestDraftRepository(apiManager: mockApiManager);

      await expectLater(
        repo.saveDraftBeacon(
          module: "mod-empty",
          screen: "screen-empty",
          draftJson: <String, dynamic>{},
        ),
        completes,
      );

      expect(repo.saveDraftFallbackCalled, isFalse);
      verifyNever(() => mockApiManager.post(any(), any()));
    });

    test("returns immediately on non-web for large draftJson", () async {
      final TestDraftRepository repo =
          TestDraftRepository(apiManager: mockApiManager);

      final String largeText = List<String>.filled(5000, "x").join();

      await expectLater(
        repo.saveDraftBeacon(
          module: "mod-large",
          screen: "screen-large",
          draftJson: <String, dynamic>{
            "largeText": largeText,
          },
        ),
        completes,
      );

      expect(repo.saveDraftFallbackCalled, isFalse);
      verifyNever(() => mockApiManager.post(any(), any()));
    });
  });
}
