import "dart:async";
import "dart:collection";

import "package:easy_localization/easy_localization.dart";
import "package:uuid/uuid.dart";

// import 'package:flutter/material.dart' as dp;
import "package:wcas_frontend/core/constants/constants.dart";
import "package:wcas_frontend/core/env_config.dart";
import "package:wcas_frontend/core/globals.dart";
import "package:wcas_frontend/core/services/api_service/api_manager.dart";
import "package:wcas_frontend/core/services/api_service/base_request.dart";
import "package:wcas_frontend/core/services/draft/browser_unload_service.dart";
import "package:wcas_frontend/core/services/local_storage_service.dart";
import "package:wcas_frontend/core/services/route_service.dart";
import "package:wcas_frontend/core/services/session/cubit.dart";
import "package:wcas_frontend/core/utils/date_time_utils.dart";
import "package:wcas_frontend/core/utils/encryption_helper.dart";
import "package:wcas_frontend/core/utils/logger.dart";
import "package:wcas_frontend/core/utils/screen_access_conditions.dart";
import "package:wcas_frontend/core/utils/utils.dart";
import "package:wcas_frontend/models/admin/access_right.dart";
import "package:wcas_frontend/models/admin/page.dart";
import "package:wcas_frontend/models/login/role.dart";
import "package:wcas_frontend/models/login/user.dart";
import "package:wcas_frontend/models/request/request.dart";

class AuthRepository {
  AuthRepository({
    APIManager? apiManager,
    LocalStorageService? localStorageService,
    String Function(String)? encryptFunction,
    String Function()? getSuccessMessage,
  })  : _apiManager = apiManager ?? APIManager(),
        _localStorageService = localStorageService ?? LocalStorageService(),
        _getSuccessMessage = getSuccessMessage;
  static final _singleton = AuthRepository();
  static AuthRepository get instance => _singleton;

  final APIManager _apiManager;
  final LocalStorageService _localStorageService;

  final String Function()? _getSuccessMessage;

  /// Authenticates the user with the provided username and password.
  ///
  /// Sends a login request to the server with the given credentials. If the
  /// login is successful, it retrieves the user's roles and updates the
  /// global user state. The user's information is also cached locally.
  ///
  /// Throws:
  ///   - [Exception] if the login fails or the response status code is not 200.
  ///
  /// Returns:
  ///   A [Future<String?>] containing a message from the server upon successful
  ///   login, or null if an error occurs.
  Future<String?> login({
    required String username,
    required String password,
  }) async {
    await _localStorageService.clearBox(LocalStorageBoxes.user);
    Globals.sessionID = const Uuid().v4();
    final String encryptedPassword = EncryptionHelper.encrypt(password);
    final Map data = {
      "sessionID": Globals.sessionID,
      "channelID": "WCAS",
      "rqUID": const Uuid().v4(),
      "requestData": {
        "userID": username,
        "password": encryptedPassword,
        "authType": "password",
      },
    };
    final AppResponse response =
        await _apiManager.post(APIEndpoints.login, data);
    if (response.status == ResponseStatus.success) {
      final responseData = response.body["responseData"];

      final User user =
          await _processUserResponse(responseData["userResponse"]);
      await _processTokenResponse(responseData["tokenResponse"]);
      await _completeAuthentication(user);

      return _getSuccessMessage?.call() ??
          "auth.login.success".tr(); // handling success message

      // return response.message;
    } else {
      throw response.message;
    }
  }

  /// Authenticates user via SSO query confirmation
  Future<String?> loginWithSSO({
    required Map<String, dynamic> tokenResponse,
    required Map<String, dynamic> userResponse,
  }) async {
    try {
      await _localStorageService.clearBox(LocalStorageBoxes.user);
      // Globals.sessionID = const Uuid().v4(); // SessionID is set from SSO parameters for SSO Flow

      final User user = await _processUserResponse(userResponse);
      await _processTokenResponse(tokenResponse);
      await _completeAuthentication(user);

      return _getSuccessMessage?.call() ?? "auth.login.success".tr();
    } catch (e) {
      rethrow;
    }
  }

  Future<User> _processUserResponse(Map<String, dynamic> userResponse) async {
    final List<Role> roles = [];
    if (userResponse["roleList"] != null) {
      for (final roleJson in userResponse["roleList"]) {
        roles.add(Role.fromJson(roleJson));
      }
    }

    final User user = User.fromJson(userResponse);
    user.availableRoles = roles;
    if (roles.isNotEmpty) {
      user.currentRole = roles.first;
    }
    //to test the sso segments empty routing removebelow code after testing
    //user.segments = [];
    return user;
  }

  Future<void> _processTokenResponse(Map<String, dynamic> tokenResponse) async {
    final String accessToken = tokenResponse["jwtToken"];
    final String refreshToken = tokenResponse["refreshToken"];
    await _localStorageService.put(
      LocalStorageBoxes.user,
      LocalStorageKeys.authToken,
      accessToken,
    );
    await _localStorageService.put(
      LocalStorageBoxes.user,
      LocalStorageKeys.refreshToken,
      refreshToken,
    );
    await _localStorageService.put(
      LocalStorageBoxes.user,
      LocalStorageKeys.sessionID,
      Globals.sessionID,
    );
    final int tokenExpiresIn =
        tokenResponse["expiresIn"]; //Duration in milliseconds
    final int tokenExpiryTime = DateTimeUtils.datetimeToInt(DateTime.now()) +
        (tokenExpiresIn); // Epoch time in milliseconds
    await _localStorageService.put(
      LocalStorageBoxes.user,
      LocalStorageKeys.tokenExpiryTime,
      tokenExpiryTime,
    );
  }

  Future<void> _completeAuthentication(User user) async {
    Globals.user = user;
    await updateUserInCache();
    SessionCubit.instance.startSession();
  }

  Future<void> updateLoggedinUserData(Map<String, dynamic> userResponse) async {
    final User user = await _processUserResponse(userResponse);
    Globals.user = user;
    await updateUserInCache();
  }

  Future<String?> refreshToken() async {
    logger.f("refreshing token");
    final String? refreshToken = await _localStorageService.get(
      LocalStorageBoxes.user,
      LocalStorageKeys.refreshToken,
    );
    final Map data = BaseRequest.baseRequest({"refreshToken": refreshToken});
    final AppResponse response =
        await _apiManager.post(APIEndpoints.refreshToken, data);
    if (response.status == ResponseStatus.success) {
      final responseData = response.body["responseData"];
      final String accessToken = responseData["jwtToken"];
      await _localStorageService.put(
        LocalStorageBoxes.user,
        LocalStorageKeys.authToken,
        accessToken,
      );

      final int tokenExpiresIn =
          responseData["expiresIn"]; //Duration in milliseconds
      final int tokenExpiryTime = DateTimeUtils.datetimeToInt(DateTime.now()) +
          (tokenExpiresIn); // Epoch time in milliseconds
      await _localStorageService.put(
        LocalStorageBoxes.user,
        LocalStorageKeys.tokenExpiryTime,
        tokenExpiryTime,
      );
      return accessToken;
    } else {
      throw response.message;
    }
  }

  Future<void> logout() async {
    try {
      unawaited(
        Globals.onAutoSave?.call(),
      ); // trigger any pending auto-saves before logging out

      // Stop the browser unload listener so it doesn't fire on the login
      // redirect.
      BrowserUnloadService.instance.unregister();
      Globals.onAutoSaveSync = null;

      final Map data = BaseRequest.baseRequest(null);

      final AppResponse response = await _apiManager.post(
        APIEndpoints.logout,
        data,
      );
      if (response.status == ResponseStatus.error) {
        throw response.message;
      }
    } catch (e) {
      rethrow;
    } finally {
      await clearCacheAndStopSession();
      if (EnvConfig.isSSOEnabled) {
        router.go(Routes.logout);
      } else {
        router.go(Routes.login);
      }
    }
  }

  Future<void> clearCacheAndStopSession() async {
    await _localStorageService.clearBox(LocalStorageBoxes.user);
    await _localStorageService.clearBox(LocalStorageBoxes.referenceData);
    SessionCubit.instance.stopSession();
  }

  Future<void> updateUserInCache() async {
    logger.f(Globals.user?.toJson());
    await _localStorageService.put(
      LocalStorageBoxes.user,
      LocalStorageKeys.userInfo,
      Globals.user?.toJson(),
    );
  }

  Future<bool> isLoggedIn() async {
    final Map? userData = await _localStorageService.get(
      LocalStorageBoxes.user,
      LocalStorageKeys.userInfo,
    );
    if (userData == null) return false;
    Globals.user = User.fromLocalJson(Map<String, dynamic>.from(userData));
    Globals.sessionID = await _localStorageService.get(
          LocalStorageBoxes.user,
          LocalStorageKeys.sessionID,
        ) ??
        "";
    return true;
  }

  /// Call when explicitly user changes role
  Future<void> changeRole(
    Role role,
  ) async {
    await sendUpdateToServer(role);
    await _localStorageService.clearBox(LocalStorageBoxes.referenceData);
    await updateRole(role);
  }

  Future<void> updateRole(Role role, {Request? request}) async {
    final Role? updatedRole = await getRoleRights(role, request: request);
    Globals.user?.currentRole = updatedRole;
    await updateUserInCache();
  }

  /// Updates the access rights for a given [Role] by making an API call.
  ///
  /// This asynchronous function sends a request to the backend to retrieve
  /// updated access rights for the specified [role]. It constructs a request
  /// payload using global user and environment data, and sends it via a POST
  /// request to the role rights mapping endpoint.
  ///
  /// If the response is successful and contains valid access rights data,
  /// the function updates the [role]'s `rights` and `routesAccesibility`
  /// properties accordingly, and sets it as the current role in [Globals.user].
  ///
  /// Throws an error if the API response indicates failure or if an exception
  /// occurs during the process.
  Future<Role?> getRoleRights(Role role, {Request? request}) async {
    final Map data = {
      "baseRequest": {
        "roleID": role.roleId,
        "role": role.code,
        "bpmRole": role.bpmRole,
        "channelID": "WCAS",
        "sessionID": Globals.sessionID,
        "userID": Globals.user!.id,
        "userName": Globals.user!.name,
        "rqUID": const Uuid().v4(),
      },
      "requestData": {
        "appRequestType": request?.requestType?.reference1 ?? "",
        "subType": request?.requestSubType?.reference1 ?? "",
      },
    };
    final AppResponse response = await _apiManager.post(
      APIEndpoints.getAuthRoleRightMap,
      data,
    );
    if (response.status == ResponseStatus.success) {
      final AccessRight accessRight =
          AccessRight.fromJson(response.body["responseData"]);
      final Iterable<Page> pagesWithComponent =
          accessRight.pages?.where((page) => page.componentName != null) ?? [];
      // dp.debugPrint(
      //     "pagesWithComponent : ${pagesWithComponent.map((page) =>
      // page.toJson().toString())}");

      role.rights = {
        for (final Page page in pagesWithComponent)
          page.componentName!: page.accessType,
      };

      // Apply screen access conditions when inside an application context.
      if (request != null) {
        _applyConditions(role.rights!);
      }

      // Sync the backend Page objects with our newly updated rights map
      if (accessRight.pages != null) {
        for (final Page page in accessRight.pages!) {
          final AccessType? updatedRight =
              role.rights![page.componentName ?? page.name ?? ""];
          if (updatedRight != null) {
            page.accessType = updatedRight;
          }
        }
      }

      // Map the routesAccesibility
      role.routesAccessibility =
          getRoutesAccessibility(accessRight.pages ?? []);
      Globals.user?.currentRole = role;
      return role;
    } else {
      throw response.message;
    }
  }

  /// Applies per-screen extra conditions from
  /// [ScreenAccessConditions.resolveAccess]
  /// to the server-granted [rights] map.
  ///
  /// Iterates all entries that are not already [AccessType.none] (those are
  /// fully blocked by the server and can never be upgraded).
  ///
  /// A safety guard prevents accidental privilege escalation: the resolved
  /// access type may only stay the same or decrease in privilege.
  ///
  /// Privilege order: edit (highest) > view > none (lowest).
  ///
  /// Only called when [getRoleRights] has a non-null [request].
  static void _applyConditions(Map<String, AccessType?> rights) {
    // ensure we have the latest data and conditions are re-evaluated
    ScreenAccessConditions.invalidateCache();
    for (final String rightKey in rights.keys.toList()) {
      final AccessType? current = rights[rightKey];

      // Skip screens already fully blocked by the server — nothing to
      // downgrade.
      if (current == null || current == AccessType.none) continue;

      final AccessType resolved =
          ScreenAccessConditions.resolveAccess(rightKey, current);

      // Safety guard: only allow same or lower access — never upgrade.
      // edit   may become → view or none
      // view   may become → none
      // (resolveAccess returning a higher type than serverGranted is ignored)
      if (_isDowngradeOrSame(from: current, to: resolved)) {
        rights[rightKey] = resolved;
      }
    }
  }

  /// Returns true when [to] is the same privilege level or lower than [from].
  /// Privilege order: edit > view > none.
  static bool _isDowngradeOrSame({
    required AccessType from,
    required AccessType to,
  }) {
    if (from == to) return true;
    if (from == AccessType.edit) {
      return to == AccessType.view || to == AccessType.none;
    }
    if (from == AccessType.view) {
      return to == AccessType.none;
    }
    return false;
  }

  Future<String?> sendUpdateToServer(Role role) async {
    final Map data = {
      "baseRequest": {
        "roleID": role.roleId,
        "role": role.code,
        "bpmRole": role.bpmRole,
        "channelID": "WCAS",
        "sessionID": Globals.sessionID,
        "userID": Globals.user!.id,
        "userName": Globals.user!.name,
        "rqUID": const Uuid().v4(),
      },
    };
    final AppResponse response = await _apiManager.put(
      APIEndpoints.updateUserRole,
      data,
    );
    if (response.status == ResponseStatus.success) {
      return response.message;
    } else {
      throw response.message;
    }
  }

  /// Generates a map of route accessibility settings for a list of pages.
  ///
  /// This function takes a list of [Page] objects, sorts them by their `id`
  /// in ascending order, and constructs a [Map] where each key is the
  /// `componentName` of a page (or its `name` if `componentName` is null),
  /// and each value is set to [MenuMode.disabled].
  ///
  /// The resulting map maintains the insertion order based on the sorted IDs,
  /// using a [LinkedHashMap].
  Map<String, MenuMode> getRoutesAccessibility(List<Page> pages) {
    // Sorting Pages by their Id
    pages.sort(
      (Page currentPage, Page nextPage) =>
          currentPage.navigationOrder!.compareTo(nextPage.navigationOrder!),
    );
    // LinkedHashmap to maintain insertion order by Id
    final Map<String, MenuMode> accessibility = <String, MenuMode>{};

    for (final Page page in pages) {
      if (page.accessType != AccessType.none) {
        accessibility[page.componentName ?? (page.name ?? "")] =
            MenuMode.disabled;
      }
    }

    return accessibility;
  }

  static bool hasRight(String? right) {
    if (Globals.user == null) return false;
    return Globals.user?.currentRole?.rights?[right] == AccessType.view ||
        Globals.user?.currentRole?.rights?[right] == AccessType.edit;
  }

  // static bool isMenuHidden(String? right) {
  //   if (Globals.user == null) return false;
  //   if (right == null) return false;
  //   return Globals.user?.currentRole?.rights?[right] == AccessType.none;
  // }

  static PageMode getPageMode(String? right) {
    if (Globals.user?.currentRole?.rights?[right] == AccessType.view) {
      return PageMode.view;
    } else if (Globals.user?.currentRole?.rights?[right] == AccessType.edit) {
      return PageMode.edit;
    } else {
      return PageMode.na;
    }
  }
}
