import 'dart:collection';
import 'package:easy_localization/easy_localization.dart';
import 'package:wcas_frontend/core/constants/constants.dart';
import 'package:wcas_frontend/core/globals.dart';
import 'package:wcas_frontend/core/services/api_service/api_manager.dart';
import 'package:wcas_frontend/core/services/api_service/base_request.dart';
import 'package:wcas_frontend/core/services/local_storage_service.dart';
import 'package:wcas_frontend/core/services/route_service.dart';
import 'package:wcas_frontend/core/utils/date_time_utils.dart';
import 'package:wcas_frontend/core/utils/encryption_helper.dart';
import 'package:wcas_frontend/core/services/session/cubit.dart';
import 'package:wcas_frontend/core/utils/logger.dart';
import 'package:wcas_frontend/core/utils/utils.dart';
import 'package:wcas_frontend/models/admin/access_right.dart';
import 'package:wcas_frontend/models/admin/page.dart';
import 'package:wcas_frontend/models/login/role.dart';
import 'package:wcas_frontend/models/login/user.dart';
import 'package:uuid/uuid.dart';
import 'package:wcas_frontend/models/request/request.dart';

class AuthRepository {
  static final _singleton = AuthRepository();
  static AuthRepository get instance => _singleton;

  final APIManager _apiManager;
  final LocalStorageService _localStorageService;

  final String Function()? _getSuccessMessage;

  AuthRepository({
    APIManager? apiManager,
    LocalStorageService? localStorageService,
    String Function(String)? encryptFunction,
    String Function()? getSuccessMessage,
  })  : _apiManager = apiManager ?? APIManager(),
        _localStorageService = localStorageService ?? LocalStorageService(),
        _getSuccessMessage = getSuccessMessage;

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
  Future<String?> login(
      {required String username, required String password}) async {
    await _localStorageService.clearBox(LocalStorageBoxes.user);
    Globals.sessionID = const Uuid().v4();
    Map data = {
      "sessionID": Globals.sessionID,
      "channelID": "WCAS",
      "rqUID": const Uuid().v4(),
      "requestData": {
        "userID": username,
        "password": EncryptionHelper.encrypt(password),
        "authType": "password"
      }
    };
    AppResponse response = await _apiManager.post(APIEndpoints.login, data);
    if (response.status == ResponseStatus.success) {
      final responseData = response.body["responseData"];
      List<Role> roles = [];
      for (var roleJson in responseData["userResponse"]["roleList"]) {
        roles.add(Role.fromJson(roleJson));
      }

      User user = User.fromJson(responseData["userResponse"]);
      user.availableRoles = roles;
      user.currentRole = roles.first;

      String accessToken = responseData["tokenResponse"]["jwtToken"];
      String refreshToken = responseData["tokenResponse"]["refreshToken"];
      await _localStorageService.put(
          LocalStorageBoxes.user, LocalStorageKeys.authToken, accessToken);
      await _localStorageService.put(
          LocalStorageBoxes.user, LocalStorageKeys.refreshToken, refreshToken);
      await _localStorageService.put(LocalStorageBoxes.user,
          LocalStorageKeys.sessionID, Globals.sessionID);
      int tokenExpiresIn =
          responseData["tokenResponse"]["expiresIn"]; //Duration in seconds
      int tokenExpiryTime = DateTimeUtils.datetimeToInt(DateTime.now()) +
          (tokenExpiresIn); // Epoch time in milliseconds
      await _localStorageService.put(LocalStorageBoxes.user,
          LocalStorageKeys.tokenExpiryTime, tokenExpiryTime);

      Globals.user = user;

      await updateUserInCache();
      SessionCubit.instance.startSession();
      return _getSuccessMessage?.call() ??
          "auth.login.success".tr(); // handling success message

      // return response.message;
    } else {
      throw response.message;
    }
  }

  Future<String?> refreshToken() async {
    logger.f("refreshing token");
    String? refreshToken = await _localStorageService.get(
        LocalStorageBoxes.user, LocalStorageKeys.refreshToken);
    Map data = BaseRequest.baseRequest({"refreshToken": refreshToken});
    AppResponse response =
        await _apiManager.post(APIEndpoints.refreshToken, data);
    if (response.status == ResponseStatus.success) {
      final responseData = response.body["responseData"];
      String accessToken = responseData["jwtToken"];
      await _localStorageService.put(
          LocalStorageBoxes.user, LocalStorageKeys.authToken, accessToken);

      int tokenExpiresIn = responseData["expiresIn"]; //Duration in seconds
      int tokenExpiryTime = DateTimeUtils.datetimeToInt(DateTime.now()) +
          (tokenExpiresIn * 1000); // Epoch time in milliseconds
      await _localStorageService.put(LocalStorageBoxes.user,
          LocalStorageKeys.tokenExpiryTime, tokenExpiryTime);
      return accessToken;
    } else {
      throw response.message;
    }
  }

  Future<void> logout() async {
    try {
      Map data = BaseRequest.baseRequest(null);

      AppResponse response = await _apiManager.post(
        APIEndpoints.logout,
        data,
      );
      if (response.status == ResponseStatus.error) {
        throw response.message;
      }
    } catch (e) {
      rethrow;
    } finally {
      await _localStorageService.clearBox(LocalStorageBoxes.user);
      SessionCubit.instance.stopSession();
      router.go(Routes.login);
    }
  }

  Future<void> updateUserInCache() async {
    logger.f(Globals.user?.toJson());
    await _localStorageService.put(LocalStorageBoxes.user,
        LocalStorageKeys.userInfo, Globals.user?.toJson());
  }

  Future<bool> isLoggedIn() async {
    Map? userData = await _localStorageService.get(
        LocalStorageBoxes.user, LocalStorageKeys.userInfo);
    if (userData == null) return false;
    Globals.user = User.fromLocalJson(Map<String, dynamic>.from(userData));
    Globals.sessionID = await _localStorageService.get(
            LocalStorageBoxes.user, LocalStorageKeys.sessionID) ??
        "";
    return true;
  }

  /// Call when explicitly user changes role
  Future<void> changeRole(
    Role role,
  ) async {
    await sendUpdateToServer(role);
    await updateRole(role);
  }

  Future<void> updateRole(Role role, {Request? request}) async {
    Role? updatedRole = await getRoleRights(role, request: request);
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
    Map data = {
      "baseRequest": {
        "roleID": role.roleId,
        "role": role.code,
        "bpmRole": role.bpmRole,
        "channelID": "WCAS",
        "sessionID": Globals.sessionID,
        "userID": Globals.user!.id,
        "userName": Globals.user!.name,
        "rqUID": const Uuid().v4()
      },
      "requestData": {
        "appRequestType": request?.requestType?.reference1 ?? "",
        "subType": request?.requestSubType?.reference1 ?? "",
      }
    };
    AppResponse response = await _apiManager.post(
      APIEndpoints.getAuthRoleRightMap,
      data,
    );
    if (response.status == ResponseStatus.success) {
      AccessRight accessRight =
          AccessRight.fromJson(response.body['responseData']);
      Iterable<Page> pagesWithComponent =
          accessRight.pages?.where((page) => page.componentName != null) ?? [];

      role.rights = {
        for (Page page in pagesWithComponent)
          page.componentName!: page.accessType,
      };

      // Map the routesAccesibility
      role.routesAccessibility =
          getRoutesAccessibility(accessRight.pages ?? []);
      Globals.user?.currentRole = role;
      return role;
    } else {
      throw response.message;
    }
  }

  Future<String?> sendUpdateToServer(Role role) async {
    Map data = {
      "baseRequest": {
        "roleID": role.roleId,
        "role": role.code,
        "bpmRole": role.bpmRole,
        "channelID": "WCAS",
        "sessionID": Globals.sessionID,
        "userID": Globals.user!.id,
        "userName": Globals.user!.name,
        "rqUID": const Uuid().v4()
      }
    };
    AppResponse response = await _apiManager.put(
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
    pages.sort((Page currentPage, Page nextPage) =>
        currentPage.navigationOrder!.compareTo(nextPage.navigationOrder!));
    // LinkedHashmap to maintain insertion order by Id
    final Map<String, MenuMode> accessibility = <String, MenuMode>{};

    for (Page page in pages) {
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
