import "dart:convert";

import "package:flutter_test/flutter_test.dart";
import "package:mocktail/mocktail.dart";
import "package:wcas_frontend/core/constants/constants.dart";
import "package:wcas_frontend/core/services/api_service/api_manager.dart";
import "package:wcas_frontend/core/services/user_by_filtered_roles_service.dart";
import "package:wcas_frontend/core/utils/api_exception.dart";
import "package:wcas_frontend/models/login/role.dart";

class MockAPIManager extends Mock implements APIManager {}

void main() {
  late UsersByFilteredRolesService service;
  late MockAPIManager mockAPIManager;

  setUp(() {
    mockAPIManager = MockAPIManager();
    service = UsersByFilteredRolesService();

    UsersByFilteredRolesService.overrideInstance = service;

    service
      ..clearCache()
      ..apiManager = mockAPIManager;
  });

  tearDown(() {
    service
      ..clearCache()
      ..apiManager = null;
  });

  group("UsersByFilteredRolesService.fetchRoles", () {
    test("role json fixture is compatible with Role.fromJsonUsersByRoles", () {
      final json = _roleJson("ADMIN");
      final role = Role.fromJsonUsersByRoles(json);

      expect(
        role.code,
        "ADMIN",
        reason:
            "The test fixture must match Role.fromJsonUsersByRoles expected API shape.",
      );
    });

    test("returns empty list and does not call API when roleCodes is empty",
        () async {
      final result = await service.fetchRoles(<String>[]);

      expect(result, isEmpty);

      verifyNever(
        () => mockAPIManager.post(
          any(),
          any(),
        ),
      );
    });

    test("calls API for missing roles and caches successful response",
        () async {
      when(
        () => mockAPIManager.post(
          APIEndpoints.getFilteredUsersByrole,
          any(),
        ),
      ).thenAnswer(
        (_) async => _successResponse([
          _roleJson("ADMIN"),
          _roleJson("MAKER"),
        ]),
      );

      final result = await service.fetchRoles(["ADMIN", "MAKER"]);

      expect(result, hasLength(2));
      expect(result.map((Role role) => role.code).toList(), ["ADMIN", "MAKER"]);

      final capturedBody = verify(
        () => mockAPIManager.post(
          APIEndpoints.getFilteredUsersByrole,
          captureAny(),
        ),
      ).captured.single as String;

      final decodedBody = jsonDecode(capturedBody);
      expect(_findValueByKey(decodedBody, "roles"), "ADMIN,MAKER");

      clearInteractions(mockAPIManager);

      final cachedResult = await service.fetchRoles(["ADMIN", "MAKER"]);

      expect(cachedResult, hasLength(2));
      expect(
        cachedResult.map((Role role) => role.code).toList(),
        ["ADMIN", "MAKER"],
      );

      verifyNever(
        () => mockAPIManager.post(
          any(),
          any(),
        ),
      );
    });

    test("returns cached roles and calls API only for missing role codes",
        () async {
      when(
        () => mockAPIManager.post(
          APIEndpoints.getFilteredUsersByrole,
          any(),
        ),
      ).thenAnswer(
        (_) async => _successResponse([
          _roleJson("ADMIN"),
        ]),
      );

      final firstResult = await service.fetchRoles(["ADMIN"]);

      expect(firstResult, hasLength(1));
      expect(firstResult.first.code, "ADMIN");

      clearInteractions(mockAPIManager);

      when(
        () => mockAPIManager.post(
          APIEndpoints.getFilteredUsersByrole,
          any(),
        ),
      ).thenAnswer(
        (_) async => _successResponse([
          _roleJson("CHECKER"),
        ]),
      );

      final secondResult = await service.fetchRoles(["ADMIN", "CHECKER"]);

      expect(secondResult, hasLength(2));
      expect(
        secondResult.map((Role role) => role.code).toList(),
        ["ADMIN", "CHECKER"],
      );

      final capturedBody = verify(
        () => mockAPIManager.post(
          APIEndpoints.getFilteredUsersByrole,
          captureAny(),
        ),
      ).captured.single as String;

      final decodedBody = jsonDecode(capturedBody);
      expect(_findValueByKey(decodedBody, "roles"), "CHECKER");
    });

    test("throws ApiException when API returns error response", () async {
      when(
        () => mockAPIManager.post(
          APIEndpoints.getFilteredUsersByrole,
          any(),
        ),
      ).thenAnswer(
        (_) async => _errorResponse("Something went wrong"),
      );

      expect(
        () => service.fetchRoles(["ADMIN"]),
        throwsA(isA<ApiException>()),
      );

      verify(
        () => mockAPIManager.post(
          APIEndpoints.getFilteredUsersByrole,
          any(),
        ),
      ).called(1);
    });

    test("returns empty list when responseData is not a List", () async {
      when(
        () => mockAPIManager.post(
          APIEndpoints.getFilteredUsersByrole,
          any(),
        ),
      ).thenAnswer(
        (_) async => _successResponse({
          "unexpected": "object",
        }),
      );

      final result = await service.fetchRoles(["ADMIN"]);

      expect(result, isEmpty);

      verify(
        () => mockAPIManager.post(
          APIEndpoints.getFilteredUsersByrole,
          any(),
        ),
      ).called(1);
    });

    test("returns empty list when responseData is null", () async {
      when(
        () => mockAPIManager.post(
          APIEndpoints.getFilteredUsersByrole,
          any(),
        ),
      ).thenAnswer(
        (_) async => _successResponse(null),
      );

      final result = await service.fetchRoles(["ADMIN"]);

      expect(result, isEmpty);

      verify(
        () => mockAPIManager.post(
          APIEndpoints.getFilteredUsersByrole,
          any(),
        ),
      ).called(1);
    });

    test("does not cache role when parsed role code is null", () async {
      when(
        () => mockAPIManager.post(
          APIEndpoints.getFilteredUsersByrole,
          any(),
        ),
      ).thenAnswer(
        (_) async => _successResponse([
          _roleJsonWithNullCode(),
        ]),
      );

      final firstResult = await service.fetchRoles(["UNKNOWN"]);

      expect(firstResult, isEmpty);

      verify(
        () => mockAPIManager.post(
          APIEndpoints.getFilteredUsersByrole,
          any(),
        ),
      ).called(1);

      clearInteractions(mockAPIManager);

      when(
        () => mockAPIManager.post(
          APIEndpoints.getFilteredUsersByrole,
          any(),
        ),
      ).thenAnswer(
        (_) async => _successResponse([
          _roleJsonWithNullCode(),
        ]),
      );

      final secondResult = await service.fetchRoles(["UNKNOWN"]);

      expect(secondResult, isEmpty);

      verify(
        () => mockAPIManager.post(
          APIEndpoints.getFilteredUsersByrole,
          any(),
        ),
      ).called(1);
    });

    test("clearCache removes cached roles", () async {
      when(
        () => mockAPIManager.post(
          APIEndpoints.getFilteredUsersByrole,
          any(),
        ),
      ).thenAnswer(
        (_) async => _successResponse([
          _roleJson("ADMIN"),
        ]),
      );

      final firstResult = await service.fetchRoles(["ADMIN"]);

      expect(firstResult, hasLength(1));
      expect(firstResult.first.code, "ADMIN");

      verify(
        () => mockAPIManager.post(
          APIEndpoints.getFilteredUsersByrole,
          any(),
        ),
      ).called(1);

      service.clearCache();
      clearInteractions(mockAPIManager);

      when(
        () => mockAPIManager.post(
          APIEndpoints.getFilteredUsersByrole,
          any(),
        ),
      ).thenAnswer(
        (_) async => _successResponse([
          _roleJson("ADMIN"),
        ]),
      );

      final secondResult = await service.fetchRoles(["ADMIN"]);

      expect(secondResult, hasLength(1));
      expect(secondResult.first.code, "ADMIN");

      verify(
        () => mockAPIManager.post(
          APIEndpoints.getFilteredUsersByrole,
          any(),
        ),
      ).called(1);
    });

    test(
        "returns duplicate cached roles when duplicate role codes are requested from cache",
        () async {
      when(
        () => mockAPIManager.post(
          APIEndpoints.getFilteredUsersByrole,
          any(),
        ),
      ).thenAnswer(
        (_) async => _successResponse([
          _roleJson("ADMIN"),
        ]),
      );

      final firstResult = await service.fetchRoles(["ADMIN"]);

      expect(firstResult, hasLength(1));
      expect(firstResult.first.code, "ADMIN");

      clearInteractions(mockAPIManager);

      final cachedDuplicateResult =
          await service.fetchRoles(["ADMIN", "ADMIN"]);

      expect(cachedDuplicateResult, hasLength(2));
      expect(
        cachedDuplicateResult.map((Role role) => role.code).toList(),
        ["ADMIN", "ADMIN"],
      );

      verifyNever(
        () => mockAPIManager.post(
          any(),
          any(),
        ),
      );
    });
  });
}

Map<String, dynamic> _roleJson(String code) {
  final candidates = _roleJsonCandidates(code);

  for (final candidate in candidates) {
    final role = Role.fromJsonUsersByRoles(candidate);
    if (role.code == code) {
      return candidate;
    }
  }

  fail(
    "No test JSON candidate matched Role.fromJsonUsersByRoles for code: $code. "
    "Open models/login/role.dart and check which key fromJsonUsersByRoles uses "
    "to populate role.code.",
  );
}

Map<String, dynamic> _roleJsonWithNullCode() {
  final candidates = <Map<String, dynamic>>[
    <String, dynamic>{
      "code": null,
      "name": null,
      "users": <dynamic>[],
    },
    <String, dynamic>{
      "roleCode": null,
      "roleName": null,
      "users": <dynamic>[],
    },
    <String, dynamic>{
      "role": null,
      "users": <dynamic>[],
    },
  ];

  for (final candidate in candidates) {
    final role = Role.fromJsonUsersByRoles(candidate);
    if (role.code == null) {
      return candidate;
    }
  }

  return <String, dynamic>{
    "code": null,
    "name": null,
    "users": <dynamic>[],
  };
}

List<Map<String, dynamic>> _roleJsonCandidates(String code) {
  return <Map<String, dynamic>>[
    <String, dynamic>{
      "code": code,
      "name": "Role $code",
      "users": <dynamic>[],
    },
    <String, dynamic>{
      "roleCode": code,
      "roleName": "Role $code",
      "users": <dynamic>[],
    },
    <String, dynamic>{
      "roleCd": code,
      "roleName": "Role $code",
      "users": <dynamic>[],
    },
    <String, dynamic>{
      "role": code,
      "roleName": "Role $code",
      "users": <dynamic>[],
    },
    <String, dynamic>{
      "role": code,
      "name": "Role $code",
      "users": <dynamic>[],
    },
    <String, dynamic>{
      "userRole": code,
      "userRoleName": "Role $code",
      "users": <dynamic>[],
    },
    <String, dynamic>{
      "userRoleCode": code,
      "userRoleName": "Role $code",
      "users": <dynamic>[],
    },
    <String, dynamic>{
      "role_code": code,
      "role_name": "Role $code",
      "users": <dynamic>[],
    },
    <String, dynamic>{
      "ROLE_CODE": code,
      "ROLE_NAME": "Role $code",
      "users": <dynamic>[],
    },
    <String, dynamic>{
      "id": code,
      "code": code,
      "description": "Role $code",
      "users": <dynamic>[],
    },
    <String, dynamic>{
      "role": <String, dynamic>{
        "code": code,
        "name": "Role $code",
      },
      "users": <dynamic>[],
    },
    <String, dynamic>{
      "role": <String, dynamic>{
        "roleCode": code,
        "roleName": "Role $code",
      },
      "users": <dynamic>[],
    },
    <String, dynamic>{
      "roleDetails": <String, dynamic>{
        "code": code,
        "name": "Role $code",
      },
      "users": <dynamic>[],
    },
    <String, dynamic>{
      "roleDetails": <String, dynamic>{
        "roleCode": code,
        "roleName": "Role $code",
      },
      "users": <dynamic>[],
    },
    <String, dynamic>{
      "roleData": <String, dynamic>{
        "code": code,
        "name": "Role $code",
      },
      "users": <dynamic>[],
    },
  ];
}

Object? _findValueByKey(Object? source, String key) {
  if (source is Map) {
    if (source.containsKey(key)) {
      return source[key];
    }

    for (final value in source.values) {
      final found = _findValueByKey(value, key);
      if (found != null) {
        return found;
      }
    }
  }

  if (source is List) {
    for (final item in source) {
      final found = _findValueByKey(item, key);
      if (found != null) {
        return found;
      }
    }
  }

  return null;
}

AppResponse _successResponse(Object? responseData) {
  return AppResponse(
    status: ResponseStatus.success,
    message: "",
    body: <String, dynamic>{
      "responseData": responseData,
    },
  );
}

AppResponse _errorResponse(String message) {
  return AppResponse(
    status: ResponseStatus.error,
    message: message,
    body: <String, dynamic>{},
  );
}
