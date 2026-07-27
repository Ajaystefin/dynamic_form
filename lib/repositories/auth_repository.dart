import "dart:async";
import "package:easy_localization/easy_localization.dart";
import "package:uuid/uuid.dart";
import "package:wcas_frontend/core/constants/constants.dart";
import "package:wcas_frontend/core/env_config.dart";
import "package:wcas_frontend/core/globals.dart";
import "package:wcas_frontend/core/services/api_service/api_manager.dart";
import "package:wcas_frontend/core/services/api_service/base_request.dart";
import "package:wcas_frontend/core/services/draft/browser_unload_service.dart";
import "package:wcas_frontend/core/services/local_storage_service.dart";
import "package:wcas_frontend/core/services/route_service.dart";
import "package:wcas_frontend/core/services/session/cubit.dart";
import "package:wcas_frontend/core/services/user_by_filtered_roles_service.dart";
import "package:wcas_frontend/core/services/user_by_roles_service.dart";
import "package:wcas_frontend/core/utils/api_exception.dart";
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

/// Repository responsible for authentication, user session management,
/// and role-related operations.
///
/// Provides functionality for user authentication, role switching,
/// session persistence, and retrieval of user-specific access and
/// security information.
class AuthRepository {
  /// Creates an [AuthRepository] instance.
  ///
  /// If dependencies are not provided, default implementations are
  /// created and used.
  AuthRepository({
    APIManager? apiManager,
    LocalStorageService? localStorageService,
    String Function()? getSuccessMessage,
  })  : _apiManager = apiManager ?? APIManager(),
        _localStorageService = localStorageService ?? LocalStorageService(),
        _getSuccessMessage = getSuccessMessage;

  static final _singleton = AuthRepository();

  /// Returns the singleton instance of [AuthRepository].
  static AuthRepository get instance => _singleton;

  final APIManager _apiManager;
  final LocalStorageService _localStorageService;

  /// Provides a custom success message resolver when required.
  final String Function()? _getSuccessMessage;

  /// Authenticates a user using a username and password.
  ///
  /// Sends the supplied credentials to the authentication service and,
  /// upon successful authentication, initializes the user session,
  /// stores authentication tokens, loads available roles, and updates
  /// the global user context.
  ///
  /// This method also clears any existing user session data before
  /// starting a new session and persists the authenticated user
  /// information in local storage.
  ///
  /// Returns a localized success message when authentication completes
  /// successfully.
  ///
  /// Throws an [ApiException] if authentication fails or the login
  /// request is rejected by the server.
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
      //throw Exception("response.message");
      throw ApiException(response.message);
    }
  }

  /// Authenticates a user using SSO-provided token and user
  /// information.
  ///
  /// Clears any existing user session data, processes the SSO token and
  /// user details, initializes the authenticated user context, and
  /// starts a new application session.
  ///
  /// Returns a localized success message when authentication completes
  /// successfully.
  ///
  /// Throws an exception if any step of the authentication process
  /// fails.
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
    } on Object {
      rethrow;
    }
  }

  /// Converts the authentication response into a [User] object.
  ///
  /// Creates the user profile and associated role information from the
  /// authentication response payload. When one or more roles are
  /// available, the first role is assigned as the user's active role.
  ///
  /// Returns the fully initialized [User] instance for use in the
  /// application session.
  Future<User> _processUserResponse(Map<String, dynamic> userResponse) async {
    final List<Role> roles = [];
    if (userResponse["roleList"] != null) {
      for (final roleJson in userResponse["roleList"]) {
        roles.add(Role.fromJson(roleJson));
      }
    }

    final User user = User.fromJson(userResponse)..availableRoles = roles;
    if (roles.isNotEmpty) {
      user.currentRole = roles.first;
    }
    //to test the sso segments empty routing removebelow code after testing
    //user.segments = [];
    return user;
  }

  /// Processes and stores authentication token information returned by
  /// the login or token refresh service.
  ///
  /// Persists the access token, refresh token, session identifier, and
  /// calculated token expiry time in local storage to support
  /// authenticated requests and session management.
  ///
  /// The token expiry time is derived from the token lifetime returned
  /// by the service and stored as an epoch timestamp in milliseconds.
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
        tokenExpiresIn; // Epoch time in milliseconds
    await _localStorageService.put(
      LocalStorageBoxes.user,
      LocalStorageKeys.tokenExpiryTime,
      tokenExpiryTime,
    );
  }

  /// Completes the user authentication process.
  ///
  /// Sets the authenticated user as the active user in the global
  /// application context, persists the user information to local
  /// storage, and starts the application session tracking mechanism.
  ///
  /// This method is typically invoked after a successful login or
  /// authentication flow.
  Future<void> _completeAuthentication(User user) async {
    Globals.user = user;
    await updateUserInCache();
    SessionCubit.instance.startSession();
  }

  /// Updates the currently logged-in user's profile information.
  ///
  /// Processes the latest user data returned from the authentication
  /// service, refreshes user-specific attributes in the global
  /// application context, and persists the updated user information to
  /// local storage.
  ///
  /// Updated attributes include:
  /// - Business segments
  /// - Regions
  /// - Approval permissions
  /// - Delegated approval permissions
  /// - Islamic banking access
  /// - Transaction approval permissions
  Future<void> updateLoggedinUserData(Map<String, dynamic> userResponse) async {
    final User user = await _processUserResponse(userResponse);
    Globals.user
      ?..segments = user.segments
      ..regions = user.regions
      ..approvalAccess = user.approvalAccess
      ..approveOnBehalfOf = user.approveOnBehalfOf
      ..isIslamic = user.isIslamic
      ..tranApprovalAccess = user.tranApprovalAccess;
    await updateUserInCache();
  }

  /// Refreshes the user's authentication token.
  ///
  /// Uses the stored refresh token to obtain a new access token from the
  /// authentication service. On successful refresh, the new access token
  /// and its expiry time are updated in local storage.
  ///
  /// Returns the newly issued access token.
  ///
  /// Throws an [ApiException] if the token refresh request fails.
  Future<String?> refreshToken() async {
    logger.i("refreshing token");
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
          tokenExpiresIn; // Epoch time in milliseconds
      await _localStorageService.put(
        LocalStorageBoxes.user,
        LocalStorageKeys.tokenExpiryTime,
        tokenExpiryTime,
      );
      return accessToken;
    } else {
      //throw Exception(response.message);
      throw ApiException(response.message);
    }
  }

  /// Logs out the current user and ends the active application session.
  ///
  /// Before logging out, any pending auto-save operation is triggered and
  /// browser unload listeners are removed to prevent unintended actions
  /// during navigation. The logout request is then sent to the backend.
  ///
  /// Regardless of the logout response, all cached user data, reference
  /// data, and session information are cleared, and the user is
  /// redirected to the appropriate login or logout page based on the
  /// application's authentication configuration.
  ///
  /// Throws an [ApiException] if the logout request fails.
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
        //throw Exception(response.message);
        throw ApiException(response.message);
      }
    } on Object {
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

  /// Clears cached user session data and terminates the active session.
  ///
  /// Removes user and reference-data caches, clears user-assignment
  /// caches, and stops the current application session. This method is
  /// typically used during logout or when a complete session reset is
  /// required.
  Future<void> clearCacheAndStopSession() async {
    await _localStorageService.clearBox(LocalStorageBoxes.user);
    await _localStorageService.clearBox(LocalStorageBoxes.referenceData);
    UsersByRolesService().clearCache();
    UsersByFilteredRolesService().clearCache();
    SessionCubit.instance.stopSession();
  }

  /// Updates the cached user information in local storage.
  ///
  /// Persists the current user state from the global application context
  /// to local storage, ensuring that user details and permissions remain
  /// available across application launches and session restores.
  Future<void> updateUserInCache() async {
    logger.i(Globals.user?.toJson());
    await _localStorageService.put(
      LocalStorageBoxes.user,
      LocalStorageKeys.userInfo,
      Globals.user?.toJson(),
    );
  }

  /// Determines whether a user is currently authenticated.
  ///
  /// Loads the user session information from local storage and restores
  /// the cached user and session context when available.
  ///
  /// Returns `true` if valid user information exists in local storage;
  /// otherwise returns `false`.
  Future<bool> isLoggedIn() async {
    final Map? userData = await _localStorageService.get(
      LocalStorageBoxes.user,
      LocalStorageKeys.userInfo,
    );
    if (userData == null) {
      return false;
    }
    Globals.user = User.fromLocalJson(Map<String, dynamic>.from(userData));
    Globals.sessionID = await _localStorageService.get(
          LocalStorageBoxes.user,
          LocalStorageKeys.sessionID,
        ) ??
        "";
    return true;
  }

  /// Changes the active role for the current user.
  ///
  /// Updates the user's role on the server, clears cached permission and
  /// reference data, refreshes the user's access rights, and persists
  /// the updated role configuration.
  ///
  /// Any application-specific context from a previously opened
  /// application is cleared to ensure navigation and permissions are
  /// reloaded using the newly selected role.
  Future<void> changeRole(
    Role role,
  ) async {
    await sendUpdateToServer(role);
    await _localStorageService.clearBox(LocalStorageBoxes.referenceData);
    UsersByRolesService().clearCache();
    UsersByFilteredRolesService().clearCache();
    await updateRole(role);
    // to clear the historical data visible in side menu
    Globals.applicationDetails = null;
  }

  /// Updates the current user's active role and refreshes the cached
  /// user session information.
  ///
  /// Retrieves the latest permissions and access rights for the
  /// specified [role], applies any request-specific access rules, and
  /// sets the updated role as the user's current role.
  ///
  /// The updated user information is then persisted to local cache to
  /// ensure the latest role configuration is available across the
  /// application.
  Future<void> updateRole(Role role, {Request? request}) async {
    final Role? updatedRole = await getRoleRights(role, request: request);
    Globals.user?.currentRole = updatedRole;
    await updateUserInCache();
  }

  /// Retrieves and applies access rights for the specified role.
  ///
  /// Loads the role's screen permissions from the backend, maps them to
  /// application rights, and updates route accessibility settings.
  ///
  /// When an application [request] is provided, additional screen access
  /// conditions are evaluated and applied. These conditions can only
  /// maintain or reduce permissions and never grant access beyond what
  /// the server has provided.
  ///
  /// On success:
  /// - Populates the role's rights map.
  /// - Applies screen-level access restrictions.
  /// - Updates route accessibility settings.
  /// - Sets the role as the current user role.
  ///
  /// Returns the updated [Role] with all resolved permissions.
  ///
  /// Throws an [ApiException] if the access rights cannot be retrieved.
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
      // dp.logger.i(
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
      //throw Exception(response.message);
      throw ApiException(response.message);
    }
  }

  /// Applies screen-specific access rules to the permissions returned by
  /// the server.
  ///
  /// Each screen permission is evaluated against additional business
  /// rules defined in [ScreenAccessConditions]. Access can only remain
  /// unchanged or be reduced; permissions granted by the server are
  /// never elevated.
  ///
  /// Examples:
  /// - `edit` may become `view` or `none`.
  /// - `view` may become `none`.
  /// - `none` remains `none`.
  ///
  /// This ensures that runtime conditions can further restrict access
  /// without overriding server-side security decisions.
  static void _applyConditions(Map<String, AccessType?> rights) {
    // ensure we have the latest data and conditions are re-evaluated
    ScreenAccessConditions.invalidateCache();
    for (final String rightKey in rights.keys.toList()) {
      final AccessType? current = rights[rightKey];

      // Skip screens already fully blocked by the server — nothing to
      // downgrade.
      if (current == null || current == AccessType.none) {
        continue;
      }

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

  /// Determines whether a target access level is equal to or less
  /// privileged than the current access level.
  ///
  /// Access levels are evaluated using the following hierarchy:
  /// `edit > view > none`.
  ///
  /// Returns `true` when [to] represents the same permission level as
  /// [from] or a lower permission level. Returns `false` when [to]
  /// represents a higher permission level.
  static bool _isDowngradeOrSame({
    required AccessType from,
    required AccessType to,
  }) {
    if (from == to) {
      return true;
    }
    if (from == AccessType.edit) {
      return to == AccessType.view || to == AccessType.none;
    }
    if (from == AccessType.view) {
      return to == AccessType.none;
    }
    return false;
  }

  /// Updates the current user's active role on the server.
  ///
  /// Sends the selected [Role] information to the backend and updates
  /// the user's session context to reflect the new role assignment.
  ///
  /// Returns the response message when the role update is successful.
  ///
  /// Throws an [ApiException] if the role update request fails.
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
      //throw Exception(response.message);
      throw ApiException(response.message);
    }
  }

  /// Builds the route accessibility configuration for the provided pages.
  ///
  /// Pages are ordered by their navigation sequence and added to the
  /// returned map when the user has access to them. Each route is
  /// initialized with [MenuMode.disabled], allowing accessibility state
  /// to be updated during menu and navigation processing.
  ///
  /// Returns a map where:
  /// - Key: Route or component name.
  /// - Value: Initial menu accessibility state.
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

  /// Checks whether the current user has access to the specified
  /// permission.
  ///
  /// Returns `true` if the user has either view or edit access for the
  /// provided permission key. Returns `false` when the user is not
  /// authenticated or does not have the required access rights.
  static bool hasRight(String? right) {
    if (Globals.user == null) {
      return false;
    }
    return Globals.user?.currentRole?.rights?[right] == AccessType.view ||
        Globals.user?.currentRole?.rights?[right] == AccessType.edit;
  }

  // static bool isMenuHidden(String? right) {
  //   if (Globals.user == null) return false;
  //   if (right == null) return false;
  //   return Globals.user?.currentRole?.rights?[right] == AccessType.none;
  // }

  /// Determines the page access mode for the specified permission key.
  ///
  /// Evaluates the current user's access rights and returns the
  /// corresponding /// - [PageMode.view] when the user has view access.
  /// - [PageMode.edit] when the user has edit access.
  /// - [PageMode.na] when no access is granted or the permission is not
  ///   defined.
  ///
  /// The [right] parameter represents the permission key configured for
  /// the page or feature.
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
