import "dart:convert";
import "package:flutter/foundation.dart";
import "package:wcas_frontend/core/constants/constants.dart";
import "package:wcas_frontend/core/globals.dart";
import "package:wcas_frontend/core/services/api_service/api_manager.dart";
import "package:wcas_frontend/core/services/api_service/base_request.dart";
import "package:wcas_frontend/core/utils/api_exception.dart";
import "package:wcas_frontend/models/login/role.dart";

/// Service responsible for fetching and caching role information by role code

class UsersByRolesService {
  /// Returns the singleton instance.
  factory UsersByRolesService() => _instance;
  UsersByRolesService._internal();
  static UsersByRolesService _instance = UsersByRolesService._internal();

  /// Overrides the singleton instance for testing purposes.
  @visibleForTesting
  static set overrideInstance(UsersByRolesService v) => _instance = v;

  /// In-memory cache of roles keyed by role code.
  final Map<String, Role> _cache = {};

  APIManager? _apiManager;

  /// Sets a custom API manager instance.
  set apiManager(APIManager? value) => _apiManager = value;

  /// Returns the configured API manager or the default singleton instance.
  APIManager get _resolvedApiManager => _apiManager ?? APIManager.instance;

  /// Fetches roles by code, returning cached entries and only calling the API
  /// for role codes not already available in the cache.
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
    });
    final response = await _resolvedApiManager.post(
      APIEndpoints.getUsersByRoles,
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

  /// Clears all cached role data.
  void clearCache() => _cache.clear();
}
