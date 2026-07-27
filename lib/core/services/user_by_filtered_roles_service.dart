import "dart:convert";
import "package:flutter/foundation.dart";
import "package:wcas_frontend/core/constants/constants.dart";
import "package:wcas_frontend/core/globals.dart";
import "package:wcas_frontend/core/services/api_service/api_manager.dart";
import "package:wcas_frontend/core/services/api_service/base_request.dart";
import "package:wcas_frontend/core/utils/api_exception.dart";
import "package:wcas_frontend/models/login/role.dart";

/// Users By Filtered Roles Service.
///
/// Retrieves roles based on role codes and application context.
/// Uses an in-memory cache to minimize API calls and supports
/// overriding dependencies for testing.
class UsersByFilteredRolesService {
  /// Returns the singleton service instance.
  factory UsersByFilteredRolesService() => _instance;
  UsersByFilteredRolesService._internal();
  static UsersByFilteredRolesService _instance =
      UsersByFilteredRolesService._internal();

  /// Returns the singleton service instance.
  @visibleForTesting
  static set overrideInstance(UsersByFilteredRolesService v) => _instance = v;

  /// Cache of roles keyed by role code.
  final Map<String, Role> _cache = {};

  APIManager? _apiManager;

  /// Sets a custom API manager.
  set apiManager(APIManager? value) => _apiManager = value;

  /// Returns the configured API manager or the default instance.
  APIManager get _resolvedApiManager => _apiManager ?? APIManager.instance;

  /// Fetches roles, returning cached values when available and
  /// requesting only missing roles from the API.
  Future<List<Role>> fetchRoles(List<String> roleCodes) async {
    final cached = <Role>[];
    final missing = <String>[];

    for (final code in roleCodes) {
      if (_cache.containsKey(code)) {
        cached.add(_cache[code]!);
      } else {
        missing.add(code);
      }
    }

    if (missing.isEmpty) {
      return cached;
    }

    final data = BaseRequest.baseRequest({
      "roles": missing.join(","),
      "segment": Globals.user?.segments?.join(","),
      "region": Globals.user?.regions?.join(","),
      "applicationRefNo": Globals.request?.applicationRefNo,
    });
    final response = await _resolvedApiManager.post(
      APIEndpoints.getFilteredUsersByrole,
      json.encode(data),
    );

    if (response.status == ResponseStatus.error) {
      throw ApiException(response.message);
    }

    final responseData = response.body["responseData"];
    final fresh = <Role>[];
    if (responseData is List) {
      for (final item in responseData) {
        final role = Role.fromJsonUsersByRoles(item as Map<String, dynamic>);
        if (role.code != null) {
          _cache[role.code!] = role;
          fresh.add(role);
        }
      }
    }

    return [...cached, ...fresh];
  }

  /// Clears all cached roles.
  void clearCache() => _cache.clear();
}
